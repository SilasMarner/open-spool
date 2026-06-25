# OpenSpool — Google Play store listing

Ready-to-paste copy and asset specs for the Play Console listing. App package
`com.mattbettinger.openspool`. Keep this in sync when the listing changes.

> Field length limits are Google's. Character counts for the constrained fields are noted inline.

## App name (≤30 chars)

```
OpenSpool
```

Descriptive alternative (keywords in title): `OpenSpool – Reel Line Planner` (30)

## Short description (≤80 chars)

```
Plan how much line your saltwater reel holds — braid, mono, and topshots.
```

Alternatives:
- `Know exactly how much braid or mono your fishing reel will hold. Offline.` (72)
- `Saltwater reel line-capacity calculator for braid, mono & topshot mixes.` (71)

## Full description (≤4000 chars; this is ~1,950)

```
Stop guessing how much line your reel holds.

OpenSpool is a fast, offline line-capacity planner for saltwater anglers. Pick your reel, pick your line, and get the yardage — including topshot and backing mixes — before you ever spool up.

Reel capacities are published for one line, but you almost never fish that exact line. OpenSpool solves this the way the industry does: it anchors each reel to a known published capacity, then converts to any line using the diameter-squared rule (a spool holds yards proportional to 1 / diameter²). Change the line and the yardage updates instantly.

What you can do
• Pick from 200+ spinning reels, conventionals, and low-profile baitcasters across Avet, Shimano, Penn, Daiwa, Okuma, Accurate, Van Staal, Quantum, Tsunami, Abu Garcia, Lew's, Maxel, Fin-Nor and more.
• Choose any line — monofilament, fluorocarbon, solid-core braid, or hollow-core braid — by brand and test.
• Plan three ways: straight fill, a fixed topshot over backing, or a full backing-and-topshot mix.
• Set your mix by length or by percentage of the spool, and see how much of the spool each segment takes.
• Save your go-to setups as named favorites and reload them in a tap.
• Work in US (yd / lb / in) or metric (m / kg / mm).

Built for the boat
• 100% offline — no signal needed at the dock or offshore.
• No account, no ads, no tracking.
• Clean, dark interface that's easy to read in the sun.

A note on accuracy
Results are estimates. Real-world fill depends on how evenly and tightly line is laid on the spool. A few catalog entries are marked as unverified where the manufacturer hasn't published an exact diameter — those carry a badge so you know to double-check. Spotted a wrong number or want a reel or line added? There's an email link in Settings — corrections are welcome.

Made by the developer of OpenTides, the free tide, current, and marine-weather app.

Tight lines.
```

## What's new / release notes (first release, ≤500 chars)

```
First release of OpenSpool. Plan line capacity for 200+ saltwater reels across braid, mono, and fluorocarbon — straight fills or topshot/backing mixes, by length or percentage. Save your favorite setups, switch between US and metric units, fully offline. Found a wrong spec? Email us from Settings.
```

## Surrounding Play Console fields

- **Category:** Tools (alt: Sports). **Tags:** fishing, boating.
- **Contact email:** `openspool.sandbar377@passmail.com` (in-app author address).
- **Data safety:** No data collected — no account, fully local; the Settings mailto link opens the
  user's own email app. Answer "No data collected / No data shared."
- **Content rating (IARC questionnaire):** Everyone.
- **Privacy policy URL:** `https://silasmarner.github.io/open-spool/privacy.html` (GitHub Pages,
  served from `/docs/privacy.html` on `dev`; source also at [`../PRIVACY.md`](../PRIVACY.md)).
  States OpenSpool collects no data.

## Graphic assets

Generated assets live in [`../store-assets/`](../store-assets/), reproducible via
`python3 store-assets/make_graphics.py` (Pillow + DejaVuSans-Bold). They use the OpenTides
palette (navy `#0A1628`, cyan `#00BCD4`, cyan-light `#4DD0E1`) and wave motif so OpenSpool reads as
the same family.

| Asset | Spec | Status |
|---|---|---|
| **Feature graphic** | 1024×500 PNG, no alpha | ✅ `store-assets/feature-graphic-1024x500.png` — navy gradient, cyan `WaveHeader`-style waves, "Open" (white) + "Spool" (cyan) wordmark, tagline. |
| **App icon** | 512×512 PNG, no alpha | ✅ `store-assets/app-icon-512x512.png` — spool-of-line emblem on navy with a trailing leader + family waves. (Also wire as the in-app launcher icon for consistency.) |
| **Phone screenshots** | 2–8 PNG/JPG, 16:9 or 9:16, min 320 px short side | ✅ `store-assets/screenshots/` — 7 shots at 1080×1920 captured on `emulator-5554` (home, straight result, topshot mix, by-%, reel picker, line-type chooser, favorites). |
| **Tablet screenshots** (optional) | 7" and 10" | ⬜ Only if you want tablet featuring; not required to publish. |

### Suggested screenshot sequence (caption ideas)
1. Calculator with a reel + straight braid result — "Know your yardage instantly."
2. Topshot mix (mono topshot over braid backing) showing both segments + spool share — "Plan topshot + backing mixes."
3. By-% mix slider — "Split the spool by length or percentage."
4. Reel picker with brand filter chips — "200+ saltwater reels, spinning & conventional."
5. Line picker type chooser — "Mono, fluoro, solid & hollow braid."
6. Saved favorites list — "Save your go-to setups."

> Screenshot grab: on `emulator-5554`, walk each screen and `adb exec-out screencap -p > shotN.png`.
> Optionally frame them with a device bezel + caption banner before upload.
