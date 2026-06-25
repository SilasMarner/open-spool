# Contributing to OpenSpool

Thanks for helping make OpenSpool more accurate and more useful. The single most
valuable kind of contribution here is **good data** — correct line diameters and
reel capacity anchors.

## Ways to contribute

### 1. Fix or add catalog data (no coding needed)

The catalog lives in plain JSON:

- `assets/data/reels.json` — one entry per reel, anchored to a single published capacity.
- `assets/data/lines.json` — one entry per line/test, with its diameter.

Each reel is anchored to **one** published capacity and everything else is computed by the
diameter-squared rule. So the two numbers that matter are:

- a reel's `anchor_yards` at a stated `anchor_diameter_in` (with an `anchor_label` like `"50 lb braid"`), and
- a line's diameter in inches.

**To add or correct an entry:**

1. Find the manufacturer's published spec (spool capacity chart, line diameter chart, or spec sheet).
2. Edit the JSON. Keep the existing key order:
   `id, brand, model, type, anchor_label, anchor_diameter_in, anchor_yards, source`.
3. Put a real citation in `source` (e.g. `"Shimano 2024 spec chart"`). If the number is an
   estimate or unconfirmed, include `VERIFY` in `source` — the app shows an "unverified" badge
   for those.
4. `type` is `spinning` or `conventional` (low-profile baitcasters are `conventional`).

A data-only change does **not** require rebuilding the APK — just keep the JSON valid
(`python3 -m json.tool assets/data/reels.json` should succeed) and the ids unique.

### 2. Report a wrong number

Open an issue with the reel/line, the value the app shows, the value you believe is correct,
and a link to the manufacturer source. In-app, there's also an email link in **Settings**.

### 3. Code

The capacity engine is pure Dart in `lib/services/capacity_calculator.dart` and is covered by
`test/capacity_calculator_test.dart`. Run `flutter test` before opening a PR. See
[`docs/INTERNALS.md`](docs/INTERNALS.md) for the model and code layout.

## Ground rules

- One logical change per pull request; describe the source for any data change.
- Don't commit secrets. The release keystore (`android/app/*.jks`) and `android/key.properties`
  are intentionally gitignored and must never be committed.
- Be excellent to each other.

## A note on accuracy

Every result is an estimate — real-world fill depends on how evenly and tightly line is laid on
the spool. The goal is to be close enough to spool with confidence, and to be honest (via the
`VERIFY` badge) about which numbers still need confirming.
