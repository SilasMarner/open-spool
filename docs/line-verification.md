# Line diameters still needing verification

These catalog entries are tagged `VERIFY` in `assets/data/lines.json` because the
manufacturer does not publish a per-size diameter and no retailer or review lists
one. Values currently in the catalog are best estimates. Confirm by contacting the
manufacturer, then update `diameter_in` (inches) and replace the `source` string
with the manufacturer figure.

_Last web search: 2026-06-26 (added LP + Tasline; pulled Jerry Brown/BMC + Tasline published charts; researched hollow-core behaviour under tension — see the research note at the bottom). Later same day: verified Shimano Trinidad A capacities (added Trinidad 30A) and Sufix 832 diameters off Rapala's official chart (extended 832 to 100/130 lb and removed a duplicate `sufix832-solid-*` set that listed the product twice). Also added Penn Squall Low Profile 300/400 (published braid capacities) and PowerPro Super 8 Slick V2 braid (15/30/50/65/80 lb, off PowerPro's official chart)._

_Last web search: 2026-09-11 — a full re-pass over every remaining VERIFY line diameter and VERIFY reel anchor capacity. **Lines resolved:** all 4 SpiderWire Stealth VERIFY sizes (15/20/50/80 lb, confirmed off retailer spec listings — 80 lb corrected .017→.016 in); the Tasline Elite 8X 100 lb anomaly (pe12.com's independent PE-rating table gives 100 lb = 0.545 mm/.0215 in — turns out tasline.com.au's own chart mislabels PE numbers against marketed lb-test, which is what produced the apparent PE8/PE6 typo); added a confirmed TUF-Line Guide's Choice 150 lb size (0.636 mm/.025 in) and re-derived the 40/80/130/200 lb estimates via sqrt(lb) scaling anchored on the two confirmed points (60 lb, 150 lb) instead of ad hoc guesses (still VERIFY, just tighter). **No new data found** for PowerPro Hollow-Ace, Tight Line 12 Strand Hollow Core, Seaguar Threadlock 200 lb, or LP Hollow/Solid Spectra — sections below are unchanged. **Reel anchors:** see the new "Reel anchor capacities" section below for the full list of what got confirmed vs. what's still estimated.

**Same-day follow-up pass (2026-09-11):** re-searched the entries the first pass above left open. **Lines still unresolved** after a second search — PowerPro Hollow-Ace (checked PowerPro.com, Shimano fishshop, Melton/TackleDirect/J&H — no per-size chart exists), Tight Line 12 Strand Hollow Core (tightlinebraid.com confirmed to list tests/yardages only), Seaguar Threadlock 200 lb (seaguar.com/TackleDirect/Melton — Seaguar's own chart still omits this size). **LP Hollow/Solid Spectra**: confirmed LP = Lindgren-Pitman (lindgren-pitman.com), which itself publishes no diameter chart; found BHP Tackle's Jerry Brown "Line One" hollow-spectra chart as the closest still-comparable published reference (40/.014in, 60/.015in, 80/.018in, 100/.017in — non-monotonic in JB's own chart, 130/.021in, 200/.024in) and cited it explicitly, but did not overwrite LP's existing estimated values since JB's chart has its own known anomaly and is a different manufacturer/construction. **Reel anchors resolved:** Avet EXW 30/2 (850 yd/100 lb braid, off a charkbait.com spec listing — replaces an unconfirmed 500 yd/50lb-mono forum estimate) and all three Daiwa BG MQ entries (4000/8000/14000 — each has its own published J-Braid chart that turned out to match the prior sister-model estimate exactly). **Still open:** Avet MXL 5.8 (found a chart for the newer-generation MXL Raptor, 50/770 65/500 80/400, but didn't substitute since it's a different product generation), Maxel Rage 60 (only unrelated capacity figures found), Accurate BV2-500, Shimano TwinPower SW 6000, Okuma Azores Z-65S (all three re-confirmed unresolved, no new search run since the first pass already exhausted the obvious sources)._

## What to ask for

> "Please send the **line diameter** (in inches or mm) for each pound test of the
> following products. I need the actual line diameter, not the equivalent-mono or
> leader-fit rating."

### 1. PowerPro Hollow-Ace (hollow-core braid) — 6 sizes
Need diameter for: **40, 60, 80, 100, 130, 200 lb**
Current estimates (in): 40=.016, 60=.019, 80=.021, 100=.024, 130=.028, 200=.033

### 2. Beyond Braid 8X (8-strand solid braid) — ✅ RESOLVED 2026-06-25
Beyond Braid emailed their full diameter/strength chart. Catalog now carries the published
diameters for **10–100 lb** with no estimates (added 10/70/90 lb; corrected 80=0.48 mm/.0189 in,
100=0.55 mm/.0217 in). Chart (mm): 10=0.12, 15=0.16, 20=0.20, 30=0.28, 40=0.32, 50=0.37,
60=0.40, 70=0.44, 80=0.48, 90=0.50, 100=0.55.

### 3. Tight Line 12 Strand Hollow Core (hollow-core braid) — 8 sizes
Need diameter for: **30, 50, 65, 80, 100, 130, 150, 200 lb**
Current estimates (in): 30=.011, 50=.014, 65=.016, 80=.018, 100=.020, 130=.022, 150=.024, 200=.028
Note: tightlinebraid.com lists tests/yardages only — no per-size diameters published.

### 4. SpiderWire Stealth (solid braid) — ✅ RESOLVED 2026-09-11
All previously-interpolated sizes confirmed off retailer spec listings (Walmart/Target/TackleDirect/
generalstorespokane): 15=.008 (0.20mm), 20=.010 (0.25mm), 50=.014 (0.35mm), 80=.016 (0.40mm — corrected
from a .017 interpolation). Combined with the pre-existing confirmed sizes (10=.006, 30=.012, 65=.015),
every SpiderWire Stealth entry is now a confirmed spec value.

### 5. Seaguar Threadlock (hollow-core braid) — 1 size
Confirmed from spec: 50=.015, 60=.016, 80=.019, 100=.020, 130=.022. Estimated (VERIFY): **200=.026**.
Note: Seaguar's spec chart omits the 200 lb diameter.

### 6. TUF-Line Guide's Choice Hollow (hollow-core braid) — 4 sizes still estimated
Confirmed from spec: 60=.016, and (added 2026-09-11) **150=.025 (0.636mm)**. Re-derived via sqrt(lb)
scaling between those two confirmed points (VERIFY, tighter than before): **40=.013, 80=.0185,
130=.0236, 200=.0293**. Note: Mustad/TUF-Line still publishes a diameter only for select sizes;
40/80/130/200 remain unconfirmed.

### 7-9. Reel anchor capacities (Abu Garcia / Akios / Penn Authority, and more)
These are reel-anchor entries, not line diameters — moved to the dedicated
**"Reel anchor capacities"** section below, which now covers the full VERIFY inventory in
`assets/data/reels.json` (not just these three).

### 10. LP Hollow Core + Solid Spectra — ALL sizes estimated (added 2026-06-26)
LP (the SoCal long-range tuna braid) **publishes no per-test diameter chart** anywhere we could find
(manufacturer + retailer + BloodyDecks/360Tuna sweep). All LP entries are interpolated from comparable
genuine-Spectra lines (Jerry Brown Line One / Izorline) and tagged `VERIFY`.
- Hollow estimates (in): 50=.014, 60=.016, 80=.018, 100=.020, 130=.023, 200=.027
- Solid estimates (in): 40=.011, 50=.013, 65=.015, 80=.017, 100=.019, 130=.022
Confirm with whoever LP sources/labels through (the West-Coast tackle shops that carry it), or replace
with a measured set. Low confidence until then.

**Re-searched 2026-09-11:** confirmed LP is the brand Lindgren-Pitman (lindgren-pitman.com), which
still publishes no diameter chart. The closest published comparable found is BHP Tackle's Jerry Brown
"Line One" hollow-spectra chart: 40=.014in, 60=.015in, 80=.018in, 100=.017in (non-monotonic in JB's
own chart — likely a JB chart quirk, not corrected here), 130=.021in, 200=.024in. Cited in each LP
hollow entry's `source` field as the reference point, but LP's own estimated values were left
unchanged since JB is a different manufacturer/construction and its chart has that known anomaly.

### 11. Tasline Elite 8X — ✅ RESOLVED 2026-09-11
Was built from Tasline's own PE→diameter→lb chart (tasline.com.au/line-diameter-chart), which lists
PE8 / 100 lb at **0.407 mm** — essentially identical to PE6 / 80 lb (0.405 mm) and clearly wrong.
**Resolution:** pe12.com independently publishes a Tasline Elite White PE-rating table keyed directly
to marketed lb-test (not Tasline's own PE numbering) that is cleanly monotonic: 80 lb = 0.48 mm,
100 lb = **0.545 mm**. The two charts turn out to use different PE-numbering conventions for the same
physical products (tasline.com.au's "PE8" ≠ pe12.com's "PE8"), which is what produced the apparent
typo. Catalog now carries the confirmed **100 lb = 0.545 mm / .0215 in**, VERIFY removed.

---

## Reel anchor capacities

These entries in `assets/data/reels.json` anchor the spool-fill math (`K = anchorYards ×
anchorDiameter² × anchorPackingFactor`) to one real published (or estimated) capacity per reel.
Confirm by finding the manufacturer's own line-capacity chart, then update `anchor_label`,
`anchor_diameter_in`, and `anchor_yards`, and drop `VERIFY` from `source`.

### Resolved 2026-09-11
- **Abu Garcia Revo Toro Beast 50** — confirmed 200 yd/50 lb braid off Abu Garcia's own capacity
  chart (200/50, 285/30, 380/20 yd/lb).
- **Akios Shuttle 555** — confirmed 240 yd/15 lb mono (was a ~250 yd scale-down from the 656).
- **Akios Shuttle 666** — confirmed 330 yd/15 lb mono, STR KURO chart (was a ~350 yd scale-up).
- **Penn Authority 10500** — confirmed 845 yd/50 lb braid. The old estimate (780 yd) had actually
  used the reel's published **60 lb** figure by mistake; the real 50 lb figure is 845 yd (chart:
  845/50, 780/60, 540/80 yd/lb).
- **Avet EX 30/2** — confirmed 310 yd/50 lb mono off a real retailer chart (was estimated from the
  EXW 30/2 by ratio). Full chart: mono 40/420, 50/310, 60/270; braid 80/750, 100/670, 130/460 yd/lb.
- **Avet EX 50/2** — confirmed chart found, but only at 60/80/100 lb mono (no 50 lb point), so
  re-anchored from "50 lb mono" to **60 lb mono / 500 yd**. Full chart: mono 60/500, 80/370,
  100/290; braid 80/1380, 100/1240, 130/850 yd/lb.
- **Daiwa Lexa 400** — confirmed 330 yd/40 lb J-Braid (owner/dealer-reported figure matched the
  existing estimate exactly); Daiwa's own spec sheet still only publishes metric PE.
- **Accurate BV-500** — re-anchored from an unconfirmed "65 lb/230 yd" guess to Accurate's own
  published **50 lb braid / 500 yd** figure.
- **Shimano Torium 30** — confirmed 415 yd/80 lb braid off Shimano's chart (50/1015, 65/515,
  80/415 yd/lb); was a 460 yd forum estimate.
- **Penn Squall II 25N** — confirmed 475 yd/50 lb braid off Penn's chart (30/675, 40/555, 50/475).
- **Accurate BV2-400** — confirmed 325 yd/50 lb braid (Izorline reference), up from a 300 yd guess.
- **Accurate BV2-600** — confirmed 400 yd/65 lb braid, corrected down from a 500 yd real-world guess.
- **Daiwa Saltiga LD50** — re-anchored from a vague "65-80 lb, 460-610 yd" range to the confirmed
  J-Braid chart's 80 lb point (460 yd); chart also gives 100/360.
- **Okuma Azores Z-55S** — confirmed 250 yd/40 lb braid off Okuma's chart (30/320, 40/250, 50/210).
- **Shimano Nasci 4000** — confirmed 180 yd/30 lb braid off the Nasci 4000XG's published PowerPro
  capacity (same physical spool as the standard 4000): 15/230, 30/180, 50/120.
- **Penn Pursuit IV 6000** — confirmed 390 yd/40 lb braid off Penn's own chart (30/490, 40/390,
  50/335); was estimated as "one size up from the 5000."

### Resolved 2026-09-11 (same-day follow-up)
- **Avet EXW 30/2** — confirmed 850 yd/100 lb braid off a charkbait.com spec listing for the reel;
  re-anchored from an unconfirmed ~500 yd/50-lb-mono forum estimate (which was also fighting
  retailer searches that kept returning the narrow EX 30/2's chart instead).
- **Daiwa BG MQ 4000** — confirmed 280 yd/20 lb J-Braid off the BG MQ 4000D-XH's own published
  chart (20/280, 30/200) — matches the prior sister-Saltist-MQ estimate exactly.
- **Daiwa BG MQ 8000** — confirmed 280 yd/50 lb J-Braid off the BG MQ 8000-H's own chart
  (40/330, 50/280) — matches the prior estimate exactly.
- **Daiwa BG MQ 14000** — confirmed 330 yd/65 lb J-Braid off the BG MQ 14000-H's own chart
  (65/330, 80/280) — matches the prior estimate exactly.

### Still open (re-searched 2026-09-11, no confirmed figure found)
- **Avet MXL 5.8** — kept at ~600 yd/50 lb braid; now corroborated by multiple retailer/forum
  listings (G2 MXL cites 620 yd) but still no Avet factory chart located. Found a published chart
  for the newer-generation **MXL Raptor** (50/770, 65/500, 80/400 yd/lb) but did not substitute —
  Raptor is a different product generation from the classic MXL 5.8.
- **Accurate BV2-500** — only a vague "rated 50-65 lb braid" range found; no specific yardage.
- **Shimano Twin Power SW 6000** — refined via 1/lb interpolation between confirmed bracketing
  points on its own chart (30 lb/290 yd, 50 lb/195 yd → ~230 yd at 40 lb), but the 40 lb point
  itself still isn't published.
- **Okuma Azores Z-65S** — found the sister Z-55S's full confirmed chart but nothing for the Z-65S.
- **Maxel Rage 60** — only unrelated Rage 60H figures found (1320 yd/20 lb mono, ~400 yd/65 lb
  braid real-world) that don't cleanly corroborate or replace the current PE6/500m conversion.

---

## Research note — does hollow-core braid shrink under tension? (2026-06-26)

The question: hollow braid flattens/compresses on a loaded spool, so should the capacity math add a
"diameter-shrinks-under-tension" term? **Finding: there is no verified, quantitative model to bolt on,
and the app already handles this the way the industry does.**

- **No published tension→diameter coefficient exists.** Manufacturers, professional spoolers, and every
  capacity calculator surveyed treat packed capacity as empirical: "variables of tension, lay and
  material type affect capacity and should be verified with actual put-ups." Nobody publishes "diameter
  reduces X% at Y lb of spooling tension."
- **The direction is also counter-intuitive.** Forum/captain consensus (BDOutdoors, 360Tuna) is that
  *solid* braid actually packs ~10–12% **more** than hollow when wound tight because it stays rounder;
  hollow flattens and lays flat but its *stated* diameter is the most optimistic of any line. So hollow's
  big real-world capacity comes mostly from an optimistic stated diameter, not from compressing on the
  spool.
- **Our model already absorbs both effects.** The diameter²-volume law with a per-type `packingFactor`
  (mono/fluoro 1.0, solid 1.2, hollow 1.85), calibrated to a real put-up (Avet T-RX 80W ≈ 1,900 yd of
  100 lb hollow), is mathematically the same volume law the pro calculators use — the packing factor is
  exactly the empirical "true packed volume ÷ stated-diameter volume" correction. Adding a separate
  tension term would double-count what the factor already captures.
- **Conclusion / where accuracy actually comes from:** don't change the engine. The accuracy lever is
  (a) better *verified* line diameters (e.g. the Jerry Brown/BMC and Tasline charts now in the catalog)
  and (b) more real reel put-ups to re-check the per-type packing factors. If we ever want to refine the
  hollow factor, the right method is to gather several published hollow-core reel capacities and
  back-solve the factor that best fits — an empirical calibration, not a tension formula.

## Manufacturer contacts

### PowerPro  →  Shimano North America Fishing, Inc.
- **Phone (line/reel support):** 1-877-577-0600 — Mon–Fri, 5:30 a.m.–5:00 p.m. Pacific
- **Fax:** 1-949-951-5071
- **Mail:** Shimano North America Fishing, Inc., Reel Support Services, One Holland, Irvine, CA 92618
- **Web contact form:** https://fishshop.shimano.com/pages/contact-us
  (also https://www.powerpro.com → Contact)
- Note: Shimano routes written inquiries through the web form rather than a public
  support email. Phone is the fastest route for a spec question.

### Beyond Braid
- **Email:** info@beyondbraid.com
- **Web contact form:** https://beyondbraid.com/pages/contact-us
- **Social (responsive):** Instagram @beyond.braid · Facebook @beyondbraidline
- Note: no public phone number; email/form/DM only.

### Tight Line Braid
- **Email:** customersupport@tightlinebraid.com (owner Jeff Nugent: jnugent@tightlinebraid.com)
- **Phone:** (346) 808-7607
- **Web contact form:** https://tightlinebraid.com/pages/contact
- Based in Tomball/Cypress, TX.

---

## Draft email (copy/paste)

> Subject: Line diameter spec request — [product name]
>
> Hi,
>
> I'm building a line-capacity tool and need the published **line diameter** for
> each pound test of your [PowerPro Hollow-Ace / Beyond Braid 8X / Tight Line
> 12 Strand Hollow Core]. Could you send the diameter (inches or mm) for:
> [40, 60, 80, 100, 130, 200 lb] / [80 and 100 lb] /
> [30, 50, 65, 80, 100, 130, 150, 200 lb]?
>
> I'm after the actual line diameter, not the equivalent-mono or leader-fit
> rating. Thanks very much.
>
> — Matt
