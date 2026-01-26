# Socratic Journal - Project Guide

## Firebase Configuration

### Environment Switching (Emulator vs Production)

The app uses xcconfig files to switch between Firebase emulator and production:

**Configuration Files:**
- `Configuration/Debug.xcconfig` - Debug build settings
- `Configuration/Release.xcconfig` - Release build settings (always production)

**To switch to emulator (Debug builds):**
```
// In Configuration/Debug.xcconfig
FIREBASE_USE_EMULATOR = YES
```

**To switch to production (Debug builds):**
```
// In Configuration/Debug.xcconfig
FIREBASE_USE_EMULATOR = NO
```

Release builds always use production Firebase (hardcoded in Release.xcconfig).

### How It Works

1. xcconfig values are injected into `Info.plist` via variable substitution:
   - `$(FIREBASE_USE_EMULATOR)` → `FirebaseUseEmulator`
   - `$(FIREBASE_EMULATOR_HOST)` → `FirebaseEmulatorHost`
   - `$(FIREBASE_FUNCTIONS_EMULATOR_PORT)` → `FirebaseFunctionsEmulatorPort`

2. `AppEnvironment.swift` reads these values from the bundle:
   ```swift
   AppEnvironment.Firebase.useEmulator  // Bool
   AppEnvironment.Firebase.emulatorHost // String (127.0.0.1)
   AppEnvironment.Firebase.functionsEmulatorPort // Int (5001)
   ```

3. Firebase services check `AppEnvironment.Firebase.useEmulator` to configure the emulator.

### Running the Firebase Emulator

```bash
cd Firebase/functions
npm run serve
```

This starts the emulator at:
- Functions: http://127.0.0.1:5001
- Firestore: http://127.0.0.1:8080
- Auth: http://127.0.0.1:9099

### Deploying Firebase Functions

```bash
cd Firebase/functions
npx firebase deploy --only functions
```

The default project is configured in `Firebase/.firebaserc` as `socratic-journal`.

## Firebase Cloud Functions

Located in `Firebase/functions/src/index.ts`:

| Function | Description |
|----------|-------------|
| `helloWorld` | Health check endpoint |
| `getQuestion` | Get journaling prompts |
| `generateFollowUpQuestions` | AI-generated follow-up questions |
| `generatePromptQuestion` | Generate new prompt questions |
| `generateInsight` | Generate insights from journal entries |
| `generateDailyMotivation` | Daily motivational content |
| `matchFictionalCharacter` | Character quiz matching (uses GPT-4o-mini) |
| `fetchCharacterMetadata` | Get character metadata |
| `fetchUniverseCharacters` | Get characters for a universe |

## Character Quiz

The character quiz uses OpenAI GPT-4o-mini to match journal entries to fictional characters.

**Request format:**
```typescript
{
  journalEntries: [{ question: string, answer: string }],
  universeId: string
}
```

**Response format:**
```typescript
{
  match: {
    characterId: string,
    characterName: string,
    confidence: number,  // 0.0-1.0 decimal
    reasoning: string,
    excerpts: [{ text: string, relevance: string }]
  },
  universe: string,
  analysisSummary: string,
  analyzedAt: string
}
```

## Project Structure

- `Sources/SocraticJournal/` - Main iOS app code
  - `App/` - App entry point and environment config
  - `Domain/` - Business logic and protocols
  - `Data/` - Services and data sources
  - `Presentation/` - SwiftUI views and view models
- `Firebase/functions/` - Cloud Functions (TypeScript)
- `Configuration/` - xcconfig files for build settings

## Build Commands

```bash
# Generate Xcode project
xcodegen generate

# Build the app
xcodebuild -scheme SocraticJournal -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```
