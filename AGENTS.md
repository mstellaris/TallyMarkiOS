# Repository Guidelines

## Project Structure & Module Organization
The SwiftUI entry point lives in `TallyMarkiOS/TallyMarkiOSApp.swift`, bootstrapping the main scene with the shared `PersistenceController`. Feature views are under `TallyMarkiOS/`, with `ContentView.swift` orchestrating tally state and delegating rendering to `TallyMarkViews.swift`. Persistent storage is defined in `TallyMarkiOS.xcdatamodeld` and surfaced through helper code in `Persistence.swift`. Assets for icons and colors belong in `TallyMarkiOS/Assets.xcassets`, while preview mocks sit under `TallyMarkiOS/Preview Content`.

## Build, Test, and Development Commands
Open the project in Xcode via `open TallyMarkiOS.xcodeproj` to run on a simulator. For headless CI, run `xcodebuild -scheme TallyMarkiOS -destination 'platform=iOS Simulator,name=iPhone 15' build` to verify compilation. Execute the Core Data-backed UI tests with `xcodebuild -scheme TallyMarkiOS -destination 'platform=iOS Simulator,name=iPhone 15' test` once the test target exists. Use `swift run` sparingly; this app is Xcode-driven.

## Coding Style & Naming Conventions
Adopt Swift's standard four-space indentation and 100-character soft wrap. Favor SwiftUI's declarative naming—e.g., `TallyMarksView` and `DistractionEvent`—and keep view structs noun-based. Run Xcode's `Editor > Format > Re-Indent` or `Shift+Option+F` before committing to stay consistent. Keep Core Data entity names singular and align attributes with camelCase properties.

## Testing Guidelines
Add unit or snapshot tests under a `TallyMarkiOSTests` target, using `XCTestCase` subclasses named `<Feature>Tests` (e.g., `TallyMarksViewTests`). Stub Core Data dependencies via in-memory containers modeled after `PersistenceController.preview`. Ensure new behavior is covered by at least one test or SwiftUI preview scenario, and document simulator requirements in the test method comments.

## Commit & Pull Request Guidelines
Commits in this repo are short and in present tense (see `First commit`), so continue writing concise imperative subjects under 65 characters, optionally prefixed with the touched area (`UI: Add animated tally marks`). Each PR should summarize scope, list key testing steps (`xcodebuild … test`), note Core Data migrations, and include before/after screenshots whenever UI changes are visible. Link issues using GitHub keywords (`Fixes #123`) so automation can close them on merge.

## Core Data & State Tips
When editing `TallyMarkiOS.xcdatamodeld`, bump model versions and run lightweight migrations through Xcode before pushing. Keep tally counts source-of-truth in a single SwiftUI state owner and persist via `DistractionEvent` writes; avoid duplicating managed object contexts across views to prevent merge conflicts.
