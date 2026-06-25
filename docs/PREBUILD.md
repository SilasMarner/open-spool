# Pre-build checklist

Run this before every build/install of OpenSpool. It is short on purpose — the point is that
**documentation stays in sync with the code as a standing step**, not an afterthought.

## 1. Docs sync (do this first)

- [ ] Did this change alter a **flow, screen, persisted shape, or behavior**? If yes, update the
      matching section of [`INTERNALS.md`](INTERNALS.md) in the **same** change.
- [ ] New/changed **regression guard** (a bug you just fixed)? Add a one-line note in `INTERNALS.md`
      so it can't silently regress, and add/adjust the matching check in the `reel-qa` skill.
- [ ] Catalog data changed (`assets/data/*.json`)? Reflect counts/notes where the docs cite them; log
      unverified diameters in [`line-verification.md`](line-verification.md).
- [ ] README still accurate (layout, math, build steps)?

## 2. Static checks

- [ ] `flutter analyze lib` → **No issues found**.
- [ ] `flutter test` → capacity-engine goldens pass (only needed when Dart changed).

## 3. Build (only when Dart/assets-wired code changed)

- **Data-only catalog edits** (`assets/data/*.json`) do **not** need an APK rebuild — just validate the
  JSON. (See the `feedback-reel-no-rebuild` memory.)
- Dart changes **do** need a rebuild. Build the **release** APK for the emulator (`/data` is tight;
  the debug APK is ~155 MB and often fails to install).

## 4. Verify on the emulator

- [ ] Install, launch, and walk the screens you touched. For a full pass, run the **`reel-qa`** skill.

## 5. Commit

- [ ] Commit to the **`dev`** branch first (not main).
- [ ] Push to **BOTH** remotes — `origin` (GitHub) and `gitea` — masking the gitea token in any printed
      URL: `sed -E 's#//[^@]*@#//***@#'`.
