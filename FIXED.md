# Fixed: Swift App → w-jarvis Backend

## What Was Fixed

### 1. Token Generation
- Swift app now generates LiveKit tokens using w-jarvis credentials
- No more sandbox or external token server needed
- Uses same LiveKit Cloud instance: `wss://jarvis-p4fs5144.livekit.cloud`

### 2. Credentials
```swift
// TokenService.swift now has:
serverUrl: "wss://jarvis-p4fs5144.livekit.cloud"
apiKey: "APIt4YTzRzdvVej"
apiSecret: "TeU2L4vPqqeVWB2ni2mIAO3s4p7Effn4nPeGVP2VB0kE"
```

### 3. JWT Generation
- Generates proper LiveKit JWT tokens locally
- Uses CryptoKit for HMAC-SHA256 signing
- 1 hour token expiry

## To Run

### Start Backend:
```bash
cd /Users/samaylakhani/w-jarvis
source venv/bin/activate
python main.py dev
```

### Run Swift App:
- Open Xcode
- Build and run
- Click "Connect"

Should work now! The Swift app connects to the same LiveKit server as the backend agent.

