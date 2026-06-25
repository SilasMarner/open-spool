import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

OUT = "/home/matt/reel-capacity-planner/store-assets"
import os; os.makedirs(OUT, exist_ok=True)

# OpenTides / OpenSpool palette
NAVY      = (10, 22, 40)
NAVY_TOP  = (8, 18, 34)
NAVY_BOT  = (13, 33, 55)
CYAN      = (0, 188, 212)
CYAN_LIGHT= (77, 208, 225)
WHITE     = (236, 244, 248)

FONT_BOLD = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
FONT_REG  = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"

def vgradient(w, h, top, bot):
    base = Image.new("RGB", (w, h))
    px = base.load()
    for y in range(h):
        t = y / max(1, h - 1)
        # ease for a softer middle
        t2 = t * t * (3 - 2 * t)
        r = int(top[0] + (bot[0] - top[0]) * t2)
        g = int(top[1] + (bot[1] - top[1]) * t2)
        b = int(top[2] + (bot[2] - top[2]) * t2)
        for x in range(w):
            px[x, y] = (r, g, b)
    return base

def draw_waves(img, S, bands):
    """bands: list of (color_rgb, alpha, amp, baseline_frac, phase, width)"""
    w, h = img.size
    overlay = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    od = ImageDraw.Draw(overlay)
    for color, alpha, amp, base_frac, phase, width in bands:
        baseline = h * base_frac
        pts = []
        for x in range(0, w + 1, 2):
            y = baseline + amp * math.sin((x / w * 2 * math.pi * 1.5) + phase)
            pts.append((x, y))
        od.line(pts, fill=color + (alpha,), width=width, joint="curve")
    img.alpha_composite(overlay)

# ---------------------------------------------------------------- feature graphic
def feature_graphic():
    S = 2  # supersample
    W, H = 1024 * S, 500 * S
    img = vgradient(W, H, NAVY_TOP, NAVY_BOT).convert("RGBA")

    # waves in the lower portion, echoing the in-app WaveHeader
    draw_waves(img, S, [
        (CYAN,       64, 26*S, 0.74, 0.0,  4*S),
        (CYAN,       46, 20*S, 0.80, 2.4,  4*S),
        (CYAN_LIGHT, 32, 14*S, 0.86, 4.1,  3*S),
    ])
    # a faint high wave for balance
    draw_waves(img, S, [(CYAN, 22, 12*S, 0.20, 1.2, 3*S)])

    d = ImageDraw.Draw(img)
    # wordmark: "Open" white + "Spool" cyan
    f_word = ImageFont.truetype(FONT_BOLD, 132*S)
    f_tag  = ImageFont.truetype(FONT_REG, 40*S)
    open_t, spool_t = "Open", "Spool"
    wA = d.textbbox((0,0), open_t,  font=f_word)
    wB = d.textbbox((0,0), spool_t, font=f_word)
    wA_w = wA[2]-wA[0]; wB_w = wB[2]-wB[0]
    total = wA_w + wB_w
    x0 = (W - total)//2
    y0 = int(H*0.30)
    d.text((x0, y0), open_t,  font=f_word, fill=WHITE)
    d.text((x0+wA_w, y0), spool_t, font=f_word, fill=CYAN)

    # tagline
    tag = "Saltwater line-capacity planner"
    tb = d.textbbox((0,0), tag, font=f_tag)
    d.text(((W-(tb[2]-tb[0]))//2, y0 + 150*S), tag, font=f_tag, fill=CYAN_LIGHT)

    img = img.convert("RGB").resize((1024, 500), Image.LANCZOS)
    img.save(f"{OUT}/feature-graphic-1024x500.png")
    print("wrote feature-graphic-1024x500.png")

# ---------------------------------------------------------------- app icon (spool emblem)
def app_icon():
    S = 2
    W = H = 512 * S
    img = vgradient(W, H, (12,26,46), (8,18,34)).convert("RGBA")

    # subtle bottom waves to tie to the family
    draw_waves(img, S, [
        (CYAN,       40, 10*S, 0.88, 0.0, 4*S),
        (CYAN_LIGHT, 26, 7*S,  0.93, 2.2, 3*S),
    ])

    d = ImageDraw.Draw(img)
    cx = W//2
    # spool of line, viewed from the side: two flanges + wound-line core
    flange_w = 250*S
    flange_h = 46*S
    core_w   = 150*S
    top_y    = 150*S
    bot_y    = 320*S
    rad      = 18*S

    # wound line core (between flanges)
    core_x0 = cx - core_w//2
    core_x1 = cx + core_w//2
    d.rounded_rectangle([core_x0, top_y+flange_h-6*S, core_x1, bot_y+6*S],
                        radius=8*S, fill=CYAN[:3]+( ) if False else (0,150,170))
    # line wraps
    yy = top_y + flange_h + 6*S
    i = 0
    while yy < bot_y:
        col = CYAN if i % 2 == 0 else CYAN_LIGHT
        d.line([(core_x0+8*S, yy), (core_x1-8*S, yy)], fill=col, width=6*S)
        yy += 14*S
        i += 1

    # flanges (top & bottom)
    for fy in (top_y, bot_y):
        d.rounded_rectangle([cx-flange_w//2, fy, cx+flange_w//2, fy+flange_h],
                            radius=rad, fill=CYAN)
    # a trailing line coming off the spool
    d.line([(core_x1-10*S, bot_y-40*S),
            (cx+flange_w//2+40*S, bot_y+10*S),
            (cx+flange_w//2+90*S, bot_y-30*S)],
           fill=CYAN_LIGHT, width=7*S, joint="curve")

    img = img.convert("RGB").resize((512, 512), Image.LANCZOS)
    img.save(f"{OUT}/app-icon-512x512.png")
    print("wrote app-icon-512x512.png")

feature_graphic()
app_icon()
