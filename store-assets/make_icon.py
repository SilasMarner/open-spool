"""OpenSpool icon — a bowed-over fishing rod with a reel ("spool") and line into
the water. Same navy/cyan family as OpenTides. Renders a master 1024 plus a
512 Play icon, small-size legibility tiles, and a rounded preview."""
import math, os
from PIL import Image, ImageDraw, ImageFilter

OUT = "/home/matt/reel-capacity-planner/store-assets/icon-preview"
os.makedirs(OUT, exist_ok=True)

NAVY_TOP   = (12, 26, 46)
NAVY_BOT   = (7, 16, 30)
CYAN       = (0, 188, 212)
CYAN_LIGHT = (77, 208, 225)
WHITE      = (236, 244, 248)
ROD        = (232, 240, 246)


def vgradient(w, h, top, bot):
    base = Image.new("RGB", (w, h))
    px = base.load()
    for y in range(h):
        t = y / max(1, h - 1)
        t2 = t * t * (3 - 2 * t)
        px_row = (int(top[0] + (bot[0]-top[0])*t2),
                  int(top[1] + (bot[1]-top[1])*t2),
                  int(top[2] + (bot[2]-top[2])*t2))
        for x in range(w):
            px[x, y] = px_row
    return base


def bez(p0, p1, p2, p3, t):
    mt = 1 - t
    x = (mt**3)*p0[0] + 3*(mt**2)*t*p1[0] + 3*mt*(t**2)*p2[0] + (t**3)*p3[0]
    y = (mt**3)*p0[1] + 3*(mt**2)*t*p1[1] + 3*mt*(t**2)*p2[1] + (t**3)*p3[1]
    return x, y


def tapered(draw, p0, p1, p2, p3, r0, r1, color, n=240):
    for i in range(n + 1):
        t = i / n
        x, y = bez(p0, p1, p2, p3, t)
        r = r0 + (r1 - r0) * (t ** 0.85)
        draw.ellipse([x-r, y-r, x+r, y+r], fill=color)


def waves(img, S):
    w, h = img.size
    ov = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    od = ImageDraw.Draw(ov)
    for color, alpha, amp, base, phase, width in [
        (CYAN,       70, 11*S, 0.885, 0.0, 5*S),
        (CYAN,       48, 8*S,  0.925, 2.3, 4*S),
        (CYAN_LIGHT, 32, 6*S,  0.955, 4.1, 3*S),
    ]:
        baseline = h * base
        pts = [(x, baseline + amp*math.sin((x/w*2*math.pi*1.6)+phase))
               for x in range(0, w+1, 2)]
        od.line(pts, fill=color+(alpha,), width=width, joint="curve")
    img.alpha_composite(ov)


def reel(d, cx, cy, R, S):
    """Conventional reel = the 'spool': concentric line disc + handle."""
    d.ellipse([cx-R, cy-R, cx+R, cy+R], fill=CYAN)
    d.ellipse([cx-R*0.72, cy-R*0.72, cx+R*0.72, cy+R*0.72], outline=CYAN_LIGHT, width=int(4*S))
    d.ellipse([cx-R*0.46, cy-R*0.46, cx+R*0.46, cy+R*0.46], outline=CYAN_LIGHT, width=int(3*S))
    d.ellipse([cx-R*0.18, cy-R*0.18, cx+R*0.18, cy+R*0.18], fill=NAVY_BOT)
    # handle knob off the lower-left
    hx, hy = cx - R*1.05, cy + R*0.62
    d.line([(cx, cy), (hx, hy)], fill=CYAN_LIGHT, width=int(7*S))
    d.ellipse([hx-9*S, hy-9*S, hx+9*S, hy+9*S], fill=WHITE)


def draw_rod(d, box, S, scale=1.0, with_ripple=True):
    """Draw the bent rod + reel + line into a target box (x0,y0,w,h), in pixels.
    Fractions are relative to the box so the emblem can be placed anywhere."""
    bx, by, bw, bh = box

    def P(fx, fy):
        return (bx + bw*fx, by + bh*fy)

    sc = scale  # stroke scale tied to box size already via S; extra knob if needed
    p0 = P(0.288, 0.720)   # butt (tucks under the reel)
    p1 = P(0.330, 0.225)
    p2 = P(0.645, 0.085)
    p3 = P(0.865, 0.415)   # tip under load
    tapered(d, p0, p1, p2, p3, r0=25*S*sc, r1=5.5*S*sc, color=ROD)

    for t in (0.42, 0.62, 0.80):
        gx, gy = bez(p0, p1, p2, p3, t)
        gr = 9*S*sc * (1 - 0.4*t)
        d.ellipse([gx-gr, gy-gr, gx+gr, gy+gr], outline=CYAN, width=max(1, int(3*S*sc)))

    tipx, tipy = bez(p0, p1, p2, p3, 1.0)
    wx, wy = P(0.785, 0.86)
    lp1 = P(0.93, 0.58)
    lp2 = P(0.86, 0.78)
    line_pts = [bez((tipx, tipy), lp1, lp2, (wx, wy), tt/40) for tt in range(41)]
    d.line(line_pts, fill=CYAN_LIGHT, width=int(4*S*sc), joint="curve")
    if with_ripple:
        for rr in (16*S*sc, 27*S*sc):
            d.arc([wx-rr, wy-rr*0.45, wx+rr, wy+rr*0.45], 200, 340,
                  fill=CYAN_LIGHT, width=int(3*S*sc))

    rcx, rcy = P(0.285, 0.715)
    reel(d, rcx, rcy, R=58*S*sc, S=S*sc)


def build_icon(px=1024, S=2, inset=1.0):
    W = H = px * S
    img = vgradient(W, H, NAVY_TOP, NAVY_BOT).convert("RGBA")
    waves(img, S)
    d = ImageDraw.Draw(img)
    side = W*inset
    box = ((W-side)/2, (H-side)/2, side, side)
    draw_rod(d, box, S)
    img = img.convert("RGB").resize((px, px), Image.LANCZOS)
    return img


def rounded(img, rad_frac=0.18):
    w, h = img.size
    mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, w, h], radius=int(w*rad_frac), fill=255)
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    out.paste(img, (0, 0), mask)
    return out


def _fit_font(path, text, target_w):
    from PIL import ImageFont
    size = 10
    while True:
        f = ImageFont.truetype(path, size)
        w = f.getbbox(text)[2]
        if w >= target_w or size > 1000:
            return ImageFont.truetype(path, max(10, size - 2))
        size += 2


def feature_graphic(master=None):
    """1024x500 Play feature graphic: rod emblem on the left, wordmark on the right."""
    from PIL import ImageFont
    S = 2
    W, H = 1024*S, 500*S
    img = vgradient(W, H, NAVY_TOP, NAVY_BOT).convert("RGBA")
    waves(img, S)
    d = ImageDraw.Draw(img)

    # rod drawn directly into a left square box (no composite seam)
    box = (int(W*0.01), int(H*0.02), int(H*0.96), int(H*0.96))
    draw_rod(d, box, S)

    # wordmark sized to fit the right area
    x0 = int(W*0.42)
    avail = W - x0 - int(W*0.04)
    f_word = _fit_font(FONT_BOLD, "OpenSpool", avail)
    open_w = f_word.getbbox("Open")[2]
    full_h = f_word.getbbox("OpenSpool")[3]
    y0 = int(H*0.40) - full_h // 2
    d.text((x0, y0), "Open", font=f_word, fill=WHITE)
    d.text((x0 + open_w, y0), "Spool", font=f_word, fill=CYAN)
    tag = "Saltwater line-capacity planner"
    f_tag = _fit_font(FONT_REG, tag, avail)
    d.text((x0 + 4, y0 + full_h + int(H*0.04)), tag, font=f_tag, fill=CYAN_LIGHT)

    return img.convert("RGB").resize((1024, 500), Image.LANCZOS)


FONT_BOLD = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
FONT_REG  = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"

# Android launcher densities (legacy square ic_launcher.png)
MIPMAP = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
RES = "/home/matt/reel-capacity-planner/android/app/src/main/res"
STORE = "/home/matt/reel-capacity-planner/store-assets"


def emit_all():
    master = build_icon(1024, S=2, inset=0.94)
    # 1) Play store listing icon (512, square)
    master.resize((512, 512), Image.LANCZOS).save(f"{STORE}/app-icon-512x512.png")
    print("wrote app-icon-512x512.png")
    # 2) launcher mipmaps (legacy square)
    for d_name, px in MIPMAP.items():
        master.resize((px, px), Image.LANCZOS).save(f"{RES}/mipmap-{d_name}/ic_launcher.png")
        print(f"wrote mipmap-{d_name}/ic_launcher.png ({px}px)")
    # 3) feature graphic
    feature_graphic(master).save(f"{STORE}/feature-graphic-1024x500.png")
    print("wrote feature-graphic-1024x500.png")


if __name__ == "__main__":
    import sys
    if "--emit" in sys.argv:
        emit_all()
    else:
        master = build_icon(1024, S=2, inset=0.94)
        master.save(f"{OUT}/icon-1024.png")
        master.resize((512, 512), Image.LANCZOS).save(f"{OUT}/icon-512.png")
        rounded(master.resize((512, 512), Image.LANCZOS)).save(f"{OUT}/icon-512-rounded.png")
        sizes = [192, 96, 72, 48]
        strip = Image.new("RGB", (sum(sizes) + 20*len(sizes) + 20, max(sizes)+40), (60, 66, 74))
        x = 20
        for s in sizes:
            tile = rounded(master.resize((s, s), Image.LANCZOS), 0.22)
            strip.paste(tile, (x, 20), tile)
            x += s + 20
        strip.save(f"{OUT}/icon-legibility.png")
        print("wrote", OUT)
