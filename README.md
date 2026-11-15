# Tally Mark

An iPhone app for counting distractions. Each time you notice a pull toward distraction, tap once:
**Distracted** if you gave in, **Resisted** if you didn't. Today's counts are drawn as tally marks and
reset at midnight; History shows a chart and a per-day list.

You can log without opening the app:

- **Live Activity** — log buttons on the Lock Screen and in the Dynamic Island.
- **Widget** — today's counts on the Home Screen (small, medium) or Lock Screen (rectangular, inline),
  with log buttons on the medium size.

## Requirements

- Xcode 26 or later
- iOS 26.0 or later (iPhone)

## Building

Open `TallyMarkiOS.xcodeproj` and run the `TallyMarkiOS` scheme, or from the command line:

```sh
xcodebuild -scheme TallyMarkiOS -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
xcodebuild -scheme TallyMarkiOSTests -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

To run on a device, set your own development team for the `TallyMarkiOS` and `TallyLiveActivityExtension`
targets, and change the bundle identifiers and the App Group (`group.com.hyperstellarlabs.TallyMarkiOS`) to ones
your team owns. The App Group is referenced in both entitlements files and in `Shared/TallyStore.swift`.

## Project layout

| Path | Contents |
| --- | --- |
| `TallyMarkiOS/` | The app: today's tally, history, tally-mark drawing, one-time import from the old Core Data store |
| `Shared/` | Compiled into the app and the widget extension: SwiftData model, store, data manager, Live Activity attributes, log intent |
| `TallyLiveActivity/` | Widget extension: the Live Activity and the Home/Lock Screen widget |
| `TallyMarkiOSTests/` | Swift Testing unit tests |
| `Design/` | App icon source; `swift Design/make_icon.swift <output-dir>` regenerates the icon PNGs |

Data is stored with SwiftData in a shared App Group container so the widget extension can read it.
See [AGENTS.md](AGENTS.md) for architecture notes and conventions.

## License

MIT — see [LICENSE](LICENSE).
