import Foundation
import CryptoKit

/// An example service for fetching LiveKit authentication tokens
///
/// To use the LiveKit Cloud sandbox (development only)
/// - Enable your sandbox here https://cloud.livekit.io/projects/p_/sandbox/templates/token-server
/// - Create .env.xcconfig with your LIVEKIT_SANDBOX_ID
///
/// To use a hardcoded token (development only)
/// - Generate a token: https://docs.livekit.io/home/cli/cli-setup/#generate-access-token
/// - Set `hardcodedServerUrl` and `hardcodedToken` below
///
/// To use your own server (production applications)
/// - Add a token endpoint to your server with a LiveKit Server SDK https://docs.livekit.io/home/server/generating-tokens/
/// - Modify or replace this class as needed to connect to your new token server
/// - Rejoice in your new production-ready LiveKit application!
///
/// See [docs](https://docs.livekit.io/home/get-started/authentication) for more information.
actor TokenService {
    struct ConnectionDetails: Codable {
        let serverUrl: String
        let roomName: String
        let participantName: String
        let participantToken: String
    }

    func fetchConnectionDetails(roomName: String, participantName: String) async throws -> ConnectionDetails? {
        if let hardcodedConnectionDetails = fetchHardcodedConnectionDetails(roomName: roomName, participantName: participantName) {
            return hardcodedConnectionDetails
        }

        return try await fetchConnectionDetailsFromSandbox(roomName: roomName, participantName: participantName)
    }

    // LiveKit credentials from w-jarvis backend
    private let hardcodedServerUrl: String? = "wss://jarvis-p4fs5144.livekit.cloud"
    private let apiKey: String = "APIt4YTzRzdvVej"
    private let apiSecret: String = "TeU2L4vPqqeVWB2ni2mIAO3s4p7Effn4nPeGVP2VB0kE"

    private let sandboxId: String? = {
        if let value = Bundle.main.object(forInfoDictionaryKey: "LiveKitSandboxId") as? String {
            // LK CLI will add unwanted double quotes
            return value.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        }
        return nil
    }()

    private let sandboxUrl: String = "https://cloud-api.livekit.io/api/sandbox/connection-details"
    private func fetchConnectionDetailsFromSandbox(roomName: String, participantName: String) async throws -> ConnectionDetails? {
        guard let sandboxId else {
            return nil
        }

        var urlComponents = URLComponents(string: sandboxUrl)!
        urlComponents.queryItems = [
            URLQueryItem(name: "roomName", value: roomName),
            URLQueryItem(name: "participantName", value: participantName),
        ]

        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        request.addValue(sandboxId, forHTTPHeaderField: "X-Sandbox-ID")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            debugPrint("Failed to connect to LiveKit Cloud sandbox")
            return nil
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            debugPrint("Error from LiveKit Cloud sandbox: \(httpResponse.statusCode), response: \(httpResponse)")
            return nil
        }

        guard let connectionDetails = try? JSONDecoder().decode(ConnectionDetails.self, from: data) else {
            debugPrint("Error parsing connection details from LiveKit Cloud sandbox, response: \(httpResponse)")
            return nil
        }

        return connectionDetails
    }

    private func fetchHardcodedConnectionDetails(roomName: String, participantName: String) -> ConnectionDetails? {
        guard let serverUrl = hardcodedServerUrl else {
            return nil
        }

        // Generate token using LiveKit credentials
        let token = generateToken(roomName: roomName, participantName: participantName)

        return .init(
            serverUrl: serverUrl,
            roomName: roomName,
            participantName: participantName,
            participantToken: token
        )
    }
    
    private func generateToken(roomName: String, participantName: String) -> String {
        // Generate JWT token for LiveKit
        // Using the w-jarvis LiveKit credentials
        let header = ["alg": "HS256", "typ": "JWT"]
        let now = Date()
        let exp = now.addingTimeInterval(3600) // 1 hour expiry
        
        let claims: [String: Any] = [
            "exp": Int(exp.timeIntervalSince1970),
            "iss": apiKey,
            "nbf": Int(now.timeIntervalSince1970),
            "sub": participantName,
            "video": [
                "room": roomName,
                "roomJoin": true,
                "canPublish": true,
                "canSubscribe": true
            ]
        ]
        
        // Create JWT
        let headerData = try! JSONSerialization.data(withJSONObject: header)
        let claimsData = try! JSONSerialization.data(withJSONObject: claims)
        
        let headerB64 = headerData.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        
        let claimsB64 = claimsData.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        
        let message = "\(headerB64).\(claimsB64)"
        
        // Sign with HMAC-SHA256
        let signature = hmacSHA256(message: message, key: apiSecret)
        
        return "\(message).\(signature)"
    }
    
    private func hmacSHA256(message: String, key: String) -> String {
        let messageData = message.data(using: .utf8)!
        let keyData = SymmetricKey(data: key.data(using: .utf8)!)
        
        let signature = HMAC<SHA256>.authenticationCode(for: messageData, using: keyData)
        let signatureData = Data(signature)
        
        return signatureData.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
