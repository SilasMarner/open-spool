# Line diameters still needing verification

These catalog entries are tagged `VERIFY` in `assets/data/lines.json` because the
manufacturer does not publish a per-size diameter and no retailer or review lists
one. Values currently in the catalog are best estimates. Confirm by contacting the
manufacturer, then update `diameter_in` (inches) and replace the `source` string
with the manufacturer figure.

_Last web search: 2026-06-26 (added LP + Tasline; pulled Jerry Brown/BMC + Tasline published charts; researched hollow-core behaviour under tension — see the research note at the bottom)._

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

### 4. SpiderWire Stealth (solid braid) — 4 interpolated sizes
Confirmed from spec: 10=.006, 30=.012, 65=.015. Interpolated (VERIFY): **15=.008, 20=.010, 50=.014, 80=.017**.
Note: published numbers are spotty across sizes; confirm the in-between tests.

### 5. Seaguar Threadlock (hollow-core braid) — 1 size
Confirmed from spec: 50=.015, 60=.016, 80=.019, 100=.020, 130=.022. Estimated (VERIFY): **200=.026**.
Note: Seaguar's spec chart omits the 200 lb diameter.

### 6. TUF-Line Guide's Choice Hollow (hollow-core braid) — 4 sizes
Confirmed from spec: 60=.016. Estimated from comparable hollow core (VERIFY): **40=.013, 80=.019, 130=.024, 200=.030**.
Note: Mustad/TUF-Line publishes a diameter only for select sizes.

### 7. Abu Garcia Revo Toro Beast 50 (reel anchor) — 1 estimate
Anchored to **~200 yd of 50 lb braid** (Abu Garcia states "over 200 yd of #50 PowerPro" but
gives no exact figure for the 50 size). The 60 size is anchored to its published 30 lb braid /
285 yd. Confirm the 50's exact 50 lb-braid capacity, or re-anchor to a published mono figure.

### 9. Penn Authority 10500 (reel anchor) — 1 estimate
Anchored to **~780 yd of 50 lb braid**, scaled from the published 8500 spool (600 yd / 50 lb).
Penn doesn't cleanly publish the 10500's braid capacity. Confirm against Penn's spec sheet.

### 8. Akios Shuttle 555 / 666 (reel anchors) — 2 estimates
The 656 spool is published at **300 yd / 15 lb mono** (used for Shuttle/Tourno/S-Line 656).
The narrow 555 (~250 yd) and wide 666 (~350 yd) are scaled from the 656 spool, not published
figures. Confirm with Akios/Breakaway Tackle (Corpus Christi, TX) — they publish the 656 only.

### 10. LP Hollow Core + Solid Spectra — ALL sizes estimated (added 2026-06-26)
LP (the SoCal long-range tuna braid) **publishes no per-test diameter chart** anywhere we could find
(manufacturer + retailer + BloodyDecks/360Tuna sweep). All LP entries are interpolated from comparable
genuine-Spectra lines (Jerry Brown Line One / Izorline) and tagged `VERIFY`.
- Hollow estimates (in): 50=.014, 60=.016, 80=.018, 100=.020, 130=.023, 200=.027
- Solid estimates (in): 40=.011, 50=.013, 65=.015, 80=.017, 100=.019, 130=.022
Confirm with whoever LP sources/labels through (the West-Coast tackle shops that carry it), or replace
with a measured set. Low confidence until then.

### 11. Tasline Elite 8X — PE8 / 100 lb size needs confirming (added 2026-06-26)
Built from Tasline's **own published PE→diameter→lb chart** (tasline.com.au/line-diameter-chart) — so
most sizes are confirmed, not estimated. **One anomaly:** the chart lists PE8 / 100 lb at **0.407 mm**,
which is essentially identical to PE6 / 80 lb (0.405 mm) and clearly a typo. The 100 lb entry uses an
interpolated **0.0179 in** and is tagged `VERIFY` — confirm the real PE8 diameter (likely ~0.45 mm) with
Tasline. Every other Tasline size is straight off the published chart.

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
