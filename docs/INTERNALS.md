# OpenSpool — internal app reference

The living, behavior-level reference for the app. The README covers the *what* and the math; this
covers *how the UI behaves and where each thing lives*, so the non-obvious flow decisions survive.

> **Keep this current.** Updating this file is part of the pre-build process (see
> [`PREBUILD.md`](PREBUILD.md)). Any change that alters a flow, a screen, or a persisted shape must
> update the matching section here in the same change.

App brand is **OpenSpool**; the hosted repo is **OpenReel** (intentional split). App id
`com.mbettinger.reel_planner` (do not change). Dark-only Material 3.

## Architecture map

| Concern | Lives in |
|---|---|
| Capacity engine (pure Dart, no Flutter) | `lib/services/capacity_calculator.dart` (+ goldens in `test/`) |
| Unit conversion (in↔mm, yd↔m, lb↔kg) | `lib/services/unit_converter.dart` |
| Settings / unit prefs | `lib/services/settings.dart` (`settings` in `app_state.dart`) |
| Read-only catalog (reels + lines) | `assets/data/reels.json`, `assets/data/lines.json` → `lib/data/catalog.dart` (`catalog`) |
| User data (favorites + custom catalog) | SQLite via `lib/data/db.dart`; favorites via `lib/data/loadout_repository.dart` (`loadoutRepo`) |
| Global singletons | `lib/app_state.dart` exposes `settings`, `catalog`, `loadoutRepo` |
| Screens | `lib/ui/screens/` — `home_screen` (calculator), `reel_picker_screen`, `line_picker_screen`, `loadouts_screen` (favorites), `settings_screen` |
| Result card | `lib/ui/widgets/capacity_result_card.dart` |

## The math (summary — full detail in README)

`K = anchorYards × anchorDiameter²(in)`; for any line `yards = K / d²`. Topshot pins one segment to a
fixed length, subtracts its volume from `K`, fills the remainder with the other line. `packingFactor`
(default 1.0) is reserved for braid-vs-mono tuning. Catalog entries whose `source` contains `VERIFY`
are unconfirmed placeholders.

## Calculator flow (`home_screen.dart`)

Three numbered step cards:
1. **Pick your reel** → `reel_picker_screen`.
2. **How are you filling it?** — segmented **Straight / Topshot / Backing-Topshot**.
3. **Pick your line** → `line_picker_screen`.

The **Capacity** result card (`capacity_result_card.dart`) renders below once enough is chosen. In
topshot modes it shows two segments; editing either length auto-adjusts the other to fill the spool.
The card's bottom-right has **Save favorite** (shown when `onSave != null`) and **Share** (when
`onShare != null`).

### Saving a favorite (`_saveLoadout`, home_screen.dart:482)
1. Build a candidate `Loadout` (name `''`).
2. `loadoutRepo.findDuplicate(candidate)` — matches **reel + mode + segments** (name ignored). If a
   match exists, toast `Already saved as "<name>"` and stop. **This is the duplicate-prevention
   guard** — do not bypass it.
3. Else prompt for a name (`_askName`, reel-based default), then `loadoutRepo.save(...)`, toast
   `Saved "<name>"`.

The app-bar **star action was removed**; saving is only via the result card button.

## Line picker — type-first flow (`line_picker_screen.dart`)

Deliberately two-stage to avoid the original "all line types on screen at once / chips cut off"
problem:
- **Stage 1 — "What kind of line?"**: four cards (Mono / Fluorocarbon / Braid (solid core) /
  Braid (hollow core)) each with a live count, plus "Show all lines instead".
- **Stage 2**: search field + "Showing <type> · change type" affordance + the **single-type** list.
  No type chip row. Back arrow: list→chooser, chooser→pop. "Add custom line" drops the user into the
  new line's type list.

`LineType { mono, fluoro, braidSolid, braidHollow }` — `.label` = Mono / Fluorocarbon /
Braid (solid core) / Braid (hollow core); `.shortLabel` = Mono / Fluoro / Solid braid / Hollow braid.

## Reel picker (`reel_picker_screen.dart`)

Searchable list; top filter chips **All / Conventional / Spinning** laid out in a `Wrap` (so they
**wrap instead of clipping** — regression guard). VERIFY-sourced reels show a badge. "Add custom reel"
in the app bar.

## Saved favorites (`loadouts_screen.dart`)

`ReorderableListView.builder` of `Loadout` rows. Each row is a **keyed `ListTile`** (`ValueKey(l.id)`)
with trailing **Share / Delete (trash) / drag-handle** and `onTap` → pop the loadout back to the
calculator to load it.

- **Delete + Undo.** The trash button calls `_delete`: remove from the in-memory list (`setState`),
  `loadoutRepo.delete`, re-persist order, then show a `Deleted "<name>"` snackbar with **Undo**
  (`_restore` re-inserts at the original index and re-persists). Deleting must remove the row
  **immediately and visually**.
- **Reorder.** Drag the handle; `onReorderItem` reorders the list (no manual `-1` index fixup — the
  callback pre-adjusts), then `_persistOrder()` writes the new `position` column order.
- **No swipe-to-dismiss.** Deletion is the explicit trash button only.

### Why there is no `Dismissible` here (regression note)
A `Dismissible` nested as the direct child of `ReorderableListView` caused two bugs: (1) the swipe
gesture fought the reorder drag, and (2) a trash-button `setState` removal did **not** reliably retire
the keyed Dismissible widget, so the row stayed on screen even though it was deleted from SQLite —
the "deleted but it persists" report. Fix: drop the `Dismissible`, put the key on the `ListTile`,
keep delete as the explicit button. **Do not re-introduce a `Dismissible` in this list.**

### Snackbar leak fix
The screen caches `ScaffoldMessengerState` in `didChangeDependencies` and calls `clearSnackBars()` in
`dispose`, so the `Deleted …` snackbar (on the app-root messenger) does not linger onto the calculator
after you navigate back.

## Persistence (`db.dart`, `loadout.dart`, `loadout_repository.dart`)

- SQLite db `reel_planner.db`, **version 2**.
- `loadouts(id, name, reel_id, mode, segments, position)`. `position` (INTEGER, default 0) drives
  manual ordering; v1→v2 `onUpgrade` adds it and seeds positions from the prior name order.
- `Loadout` carries `position`; `fromRow`/`toRow`/`copyWith` round-trip it.
- Repo: `all()` orders by `position ASC, name COLLATE NOCASE`; `save()` appends new favorites at
  `MAX(position)+1`; `findDuplicate()` (reel+mode+segments); `restore()` (re-insert for Undo, keeps
  id/position); `reorder(orderedIds)` (batch-writes positions); `delete(id)`.
- `custom_reels` / `custom_lines` tables hold user-added catalog entries, merged with the seed at load.

## Settings / units

`settings` (SharedPreferences-backed) holds the US/Metric unit choice; the result card and pickers
read it through `unit_converter.dart`. US default (yd / in / lb), metric = m / mm / kg.

## Build / deploy quick ref

Flutter lives in the `ubuntu-chrome` container at `/root/flutter/bin`; the project is `docker cp`-ed
to `/root/reel_planner` (repo not mounted). Build the **release** APK for the emulator (`/data` is
tight; the debug APK is ~155 MB and often fails to install). See [`PREBUILD.md`](PREBUILD.md) and the
`reel-qa` skill for the full sync/build/install/verify loop. Commit to **`dev`** first, push **both**
remotes (`origin` + `gitea`, mask the gitea token).
