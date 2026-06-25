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

The body is a `Column`: a full-width **`WaveHeader`** band on top, then an `Expanded` `ListView` of
three numbered step cards:
1. **Pick your reel** → `reel_picker_screen`.
2. **How are you filling it?** — segmented **Straight / Topshot / Backing-Topshot**.
3. **Pick your line** → `line_picker_screen`.

**Wave header (`ui/widgets/wave_header.dart`).** An animated cyan sine-wave band (`CustomPaint`)
with the tagline "Saltwater line-capacity planner" and the picked reel as its subtitle. Ported
straight from OpenTides' `WaveHeader` (same navy/cyan palette) **on purpose, so the two apps read as
one family** — keep it visually in step with OpenTides. It is purely decorative; do not gate any
logic on it.

**Start over (app-bar refresh action).** A `refresh` icon leads the calculator's app-bar actions
(`_reset`). It clears the in-progress plan — reel, all line picks, lengths, mix-input mode, and the
percent slider back to their initial defaults — and toasts "Started a new plan". It is **disabled
when there's nothing to clear** (`_hasSelections`: a reel or any line picked). It only resets the
calculator's transient state; **saved favorites are untouched**.

The **Capacity** result card (`capacity_result_card.dart`) renders below once enough is chosen. In
topshot modes it shows two segments; editing either length auto-adjusts the other to fill the spool.
The card's bottom-right has **Save favorite** (shown when `onSave != null`) and **Share** (when
`onShare != null`).

**Per-segment spool share (mix results).** Each segment's `sub` line includes how much of the spool
that segment occupies — e.g. `fixed · ~53% of spool`. Computed in `loadout_result.dart`
(`_spoolShare` = `yards × diameter²·packing ÷ spoolK`, formatted by `_pct`) and appended to the
existing `sub` ("fixed" / "computed fill" / "you set"). It flows through to both the card and the
share summary unchanged. This exists to explain *why* a fat mono topshot leaves little braid backing:
the diameter² law means a thick line eats far more spool per yard than thin braid (e.g. 50 yd of
0.035" mono ≈ the volume of ~212 yd of 0.017" braid), so the backing number can look surprisingly low
even though the math is correct. Straight fills don't show a share (always ~100%, covered by the fill
note).

**Mix input — by length or by %.** In the Topshot and Backing/Topshot modes a **By length / By %**
toggle (`_MixInput`) sits atop the length card. *By %* shows a slider that sets the **topshot's share
of the spool volume**; the backing takes the rest, and `computeMixSplit` (loadout_result.dart) turns
the split into each segment's yardage (`yards = share × spoolK ÷ diameter²·packing`) — a full-spool
split, so it never overflows. Saving a percent split resolves it to concrete pinned yards (both
`fixedYards` set), so it persists and reloads exactly like a both-lengths plan; the percentage itself
is just an input convenience and is not stored.

**Test rating in result labels.** Each result row carries the line's `lbTest`; the card and the share
summary render it after the line name as `· 80 lb` (or kg in metric, via `units.test`). Keeps the
result naming the line's *strength*, not just its product.

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
read it through `unit_converter.dart`. **US is the default** (yd / in / lb); metric = m / mm / kg.
`Settings.load()` only flips to metric on a stored `'metric'`, so a fresh install is US.

`settings` is a `ChangeNotifier`. The root `ListenableBuilder` in `main.dart` rebuilds the home tree,
but **pushed routes don't rebuild from it** — `home_screen` listens to `settings` directly
(`addListener`) and `settings_screen` wraps its unit `RadioGroup` in a `ListenableBuilder`. **This is
required**: without it the settings radio is frozen on whatever value the route opened with — tapping
a unit persists the change but the dot never moves (the "clicking US doesn't select it" bug).

## Build / deploy quick ref

Flutter lives in the `ubuntu-chrome` container at `/root/flutter/bin`; the project is `docker cp`-ed
to `/root/reel_planner` (repo not mounted). Build the **release** APK for the emulator (`/data` is
tight; the debug APK is ~155 MB and often fails to install). See [`PREBUILD.md`](PREBUILD.md) and the
`reel-qa` skill for the full sync/build/install/verify loop. Commit to **`dev`** first, push **both**
remotes (`origin` + `gitea`, mask the gitea token).
