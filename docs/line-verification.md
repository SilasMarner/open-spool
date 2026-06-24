# Line diameters still needing verification

These catalog entries are tagged `VERIFY` in `assets/data/lines.json` because the
manufacturer does not publish a per-size diameter and no retailer or review lists
one. Values currently in the catalog are best estimates. Confirm by contacting the
manufacturer, then update `diameter_in` (inches) and replace the `source` string
with the manufacturer figure.

_Last web search: 2026-06-24 (deep sweep of manufacturer + ~15 retailer/review sites — no published diameters found)._

## What to ask for

> "Please send the **line diameter** (in inches or mm) for each pound test of the
> following products. I need the actual line diameter, not the equivalent-mono or
> leader-fit rating."

### 1. PowerPro Hollow-Ace (hollow-core braid) — 6 sizes
Need diameter for: **40, 60, 80, 100, 130, 200 lb**
Current estimates (in): 40=.016, 60=.019, 80=.021, 100=.024, 130=.028, 200=.033

### 2. Beyond Braid 8X (8-strand solid braid) — 2 sizes
Need diameter for: **80, 100 lb** (15–60 lb already verified from the published chart)
Current estimates (in): 80=.0177 (~0.45 mm), 100=.0197 (~0.50 mm)

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

---

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
