# MIDAS — Jarvis-style voice assistant for iPhone

A black-and-gold SwiftUI iPhone assistant with an animated gold orb, voice conversation, AI backend, and shortcuts to WhatsApp, TikTok, Instagram, Discord and Spotify.

## What is included
- Native iOS SwiftUI app.
- Home screen: animated MIDAS orb + call button + gold app shortcuts.
- Call screen: only the animated orb. Tap the orb to hang up.
- Spanish speech recognition and spoken answers.
- Conversation memory during the current backend process.
- OpenAI Responses API backend with web search for fresh questions such as weather/news/current facts.
- MIDAS personality: concise, capable, witty, with occasional jokes and funny facts.
- API key stays on the server, never inside the iPhone app or public GitHub repo.

## Requirements
- macOS + Xcode 16 or newer.
- iPhone/iOS 17+ recommended.
- Node.js 20+ for the backend.
- An OpenAI API key with billing enabled.

## 1. Start the AI backend
```bash
cd backend
cp .env.example .env
# Edit .env and put your real OPENAI_API_KEY there
npm install
npm start
```
The local server runs on port 8787.

## 2. Point the iPhone app at the backend
Open `MidasJarvis/APIClient.swift` and change `baseURL`.

- iOS Simulator on the same Mac: `http://127.0.0.1:8787`
- Physical iPhone for local testing: use your Mac's LAN IP, e.g. `http://192.168.1.50:8787`
- For GitHub/real use: deploy `backend/` to a HTTPS Node host and use that HTTPS URL.

Do **not** put an OpenAI API key directly in Swift code.

## 3. Open in Xcode
Open `MidasJarvis.xcodeproj`, select the `MidasJarvis` target, choose your Apple Development Team under Signing & Capabilities, then run on your iPhone.

The first call asks for Microphone and Speech Recognition permissions.

## App shortcuts
The app first tries the installed app URL scheme and falls back to the website. iOS may change/limit third-party URL schemes; the web fallback keeps the buttons useful.

## Make it more like a full Jarvis later
Good next upgrades: Realtime/WebRTC audio for lower latency and interruptions, Siri/App Intents, Calendar/Reminders integrations, HomeKit, custom wake phrase, widgets/Live Activities, authentication, database-backed long-term memory, and server-side tool functions.

## Security
- `.env` is gitignored.
- Never commit your API key.
- For a public app, add user authentication, rate limits, abuse controls, request size limits, logs/monitoring and a persistent conversation store.

## Notes
This is an original MIDAS interface; it does not use Marvel/JARVIS branding or assets. The orb and app icon are original black/gold designs generated for this project.
