# Run the Voice Agent

## Backend (Required First)

```bash
cd /Users/samaylakhani/w-jarvis
source venv/bin/activate  
python3 main.py dev
```

## Frontend (After backend is running)

Open Xcode:
```bash
open /Users/samaylakhani/agent-starter-swift/VoiceAgent.xcodeproj
```

Build and run (Cmd+R)

Click "Connect"

## Done!

The Swift app now:
- Connects to `wss://jarvis-p4fs5144.livekit.cloud`
- Generates LiveKit tokens locally using w-jarvis credentials
- No token server needed
- Backend agent handles all the MCP stuff
