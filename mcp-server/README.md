# Gmail & Google Calendar MCP Server Setup

This directory contains the configuration for the Gmail & Google Calendar MCP server that provides email and calendar functionality to the LiveKit agent.

## Prerequisites

1. Node.js 18+ and npm
2. Google Cloud Project with Gmail API and Calendar API enabled
3. OAuth2 credentials (Desktop application type)

## Setup Instructions

### 1. Clone the MCP Server

```bash
cd mcp-server
git clone https://github.com/ftaricano/mcp-gmail-calendar.git .
npm install
```

### 2. Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable Gmail API: https://console.cloud.google.com/apis/library/gmail.googleapis.com
4. Enable Google Calendar API: https://console.cloud.google.com/apis/library/calendar-json.googleapis.com

### 3. Create OAuth2 Credentials

1. Go to "Credentials" → "Create Credentials" → "OAuth client ID"
2. Application type: "Desktop application"
3. Name: "LiveKit Email Calendar Agent"
4. Download JSON file and save as `credentials.json` in this directory

### 4. Configure OAuth Consent Screen

1. Add your email as a test user
2. Configure app information and scopes:
   - Gmail API: `https://www.googleapis.com/auth/gmail.modify`
   - Calendar API: `https://www.googleapis.com/auth/calendar`

### 5. Configure Environment Variables

Copy `.env.example` to `.env` and update with your configuration:

```bash
cp .env.example .env
```

Edit `.env` and set:
- `GOOGLE_CREDENTIALS_PATH=./credentials.json`
- Other configuration as needed

### 6. Run the MCP Server

```bash
npm run build
npm start
```

The server will run on `http://localhost:3000` by default.

## Security Notes

- **Never commit `credentials.json` or `.env` files to version control**
- OAuth tokens are stored temporarily in the `tokens` directory
- Use HTTPS in production
- Implement rate limiting for production use

## Testing the Server

You can test the MCP server endpoints directly:

```bash
# Authenticate an account
curl -X POST http://localhost:3000/authenticate \
  -H "Content-Type: application/json" \
  -d '{"email": "your-email@gmail.com", "accountType": "personal"}'

# List emails (after authentication)
curl -X POST http://localhost:3000/email_list \
  -H "Content-Type: application/json" \
  -d '{"maxResults": 10}'
```

## Integration with LiveKit Agent

The LiveKit agent connects to this MCP server using the MCP HTTP protocol. User OAuth tokens are passed from the Swift frontend through the agent to the MCP server.

See `../agent/README.md` for agent integration details.

