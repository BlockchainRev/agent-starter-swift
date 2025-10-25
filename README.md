# Voice Agent - Swift Frontend

Swift iOS/macOS/visionOS client for the Jarvis voice agent.

## Backend

This is just the frontend. The backend agent is located at:
```
/Users/samaylakhani/w-jarvis
```

## Quick Start

### 1. Start Backend Agent

```bash
cd /Users/samaylakhani/w-jarvis
source venv/bin/activate
python main.py dev
```

### 2. Run Swift App

```bash
open VoiceAgent.xcodeproj
# Build and run (Cmd+R)
```

## Architecture

- **Swift App** → LiveKit Room → **Python Agent** (w-jarvis)
- Backend handles: MCP servers, Gmail, Calendar, Contacts, all auth

## Development

The Swift app connects to LiveKit and interacts with the Jarvis agent running at `/Users/samaylakhani/w-jarvis`. No backend code is stored in this repository.
