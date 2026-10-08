# D2R Terror Zones for Noctalia

This Noctalia bar widget shows the current and next online Terror Zones in *Diablo II: Resurrected: Reign of the Warlock*, with XP and loot grades. It reads the [D2Runewizard tracker](https://d2runewizard.com/terror-zone-tracker) every 120 seconds. No D2Runewizard account or token is needed. Clicking the widget opens the tracker through `xdg-open`.

Requires Noctalia 5.0.1 or another build supporting plugin API 24, plus `xdg-open` on the host. Add `https://github.com/bioinformatist/noctalia-d2r` as a Git source in **Settings → Plugins → Add source**, or use a local path while developing. Enable `bioinformatist/d2r-tz`, then add its `tz` widget to a bar. The interface targets mainland Chinese players and uses Simplified Chinese even when Noctalia's interface is English. The plugin setting **区域名称** defaults to Simplified Chinese area names and can select English names. Noctalia rebuilds the widget when that setting changes.

The service makes one request at startup and then polls every two minutes. All widget instances use its shared in-memory result. If a refresh fails, the last successful result remains visible with an update-failure label; before the first success, the widget shows unavailable. The tooltip contains only the current and next zone names with XP and loot grades. An absent next zone appears as “尚未公布.” Area names are matched regardless of case, leading “The,” group order, or comma, slash, “and,” plus and ampersand separators. Known combinations have Chinese names and use the existing group or area grades. A combination containing an unknown area remains as supplied with `?` grades.

Grades are subjective references, not measured XP rates or drop probabilities. Individual-area grades come unchanged from [the earlier Eww data](https://github.com/bioinformatist/dotfiles/blob/efe768bc00aef31dc44f013bc97726b6bc453c82/home/desktop/eww-features/d2r/terror-zones.json); its original external source is unknown. For five full RotW groups, the plugin uses [D2TZ's group ratings](https://www.d2tz.info/online), checked on 2026-10-02. Other recognized groups use the best known grade among their individual areas, independently for XP and loot. Rating provenance remains in the shipped data; clicking the widget opens D2Runewizard.

The pinned development shell contains Luau, Python, Noctalia, nixfmt, curl and xdg-utils. From the repository root:

```sh
nix develop --command noctalia plugins lint d2r-tz
nix develop --command python3 -B tests/run.py
nix develop --command python3 -B tests/run.py --live
nix flake check
```

The normal tests use a pinned copy of the migrated ratings and do not access the network. `--live` makes one request to D2Runewizard and passes the response through the plugin's Luau parser. The plugin makes no runtime requests to D2TZ.

Released under the MIT license. The migrated ratings retain the 2024 Yu Sun attribution in [LICENSE](LICENSE).
