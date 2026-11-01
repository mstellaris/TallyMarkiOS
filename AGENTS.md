# Repository Guidelines

## Project Structure
- `TallyMarkiOS/` — the app target. `TallyMarkiOSApp.swift` runs the one-time legacy import and injects
  `TallyDataManager.shared`. `ContentView.swift` is today's tally, `HistoryView.swift` the chart and per-day list,
  `DaySummary.swift` the day-grouping logic, `TallyMarkViews.swift` the tally-mark drawing.
- `Shared/` — compiled into **both** the app and the widget extension: the SwiftData model (`DistractionEvent`,
  `DayCounts`), `TallyStore` (App Group container and queries), `TallyDataManager`, `TallyActivityAttributes`,
  `EventType`, and `LogEventIntent`.
- `TallyLiveActivity/` — the widget extension: the Live Activity (`TallyActivityWidget.swift`) and the
  Home/Lock Screen widget (`TodayWidget.swift`).
- `TallyMarkiOSTests/` — Swift Testing unit tests, hosted in the app.
- `Design/` — app icon source (`AppIcon-foreground.svg` for Icon Composer, `make_icon.swift` to regenerate the PNGs).

## Data
- Storage is SwiftData in the App Group `group.com.hyperstellarlabs.TallyMarkiOS`, so the extension can read it.
- `TallyMarkiOS.xcdatamodeld` is the **legacy** Core Data model, kept only so `LegacyStoreImporter` can copy
  pre-SwiftData history once. Don't add to it. Its old store file is left on disk as a backup.
- `TallyDataManager` is the single owner of today's counts. `LogEventIntent` is a `LiveActivityIntent`, so it runs
  in the app process and calls `TallyDataManager.shared` — keep writes going through it.

## Build & Test
- Requires Xcode 26+; deployment target iOS 26.0; Swift 6 with `MainActor` default isolation in every target.
  Types used by ActivityKit, WidgetKit timeline providers, or SwiftData off the main actor are marked `nonisolated`.
- Build: `xcodebuild -scheme TallyMarkiOS -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`
- Test: `xcodebuild -scheme TallyMarkiOSTests -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test`
- Pass an explicit `calendar` and `now` to `TallyDataManager` in tests (see `TallyDataManagerTests`).

## Style
- Four-space indentation; SwiftUI views are noun-named structs. Use `#Preview(traits: .sampleTallies)` for previews
  that need data.
- Commits: short imperative subjects under 65 characters, optionally prefixed with the area (`UI: …`, `Data: …`).
