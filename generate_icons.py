import math
import os
from PIL import Image, ImageDraw, ImageFilter

def create_vpn_icon(size=1024):
    # Create high-res canvas
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    center = size / 2
    r_outer = size * 0.44
    
    # 1. Background Squircle / Rounded Circle
    # Outer ambient glow
    glow_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow_img)
    
    # Gradient radial aura
    for r in range(int(r_outer * 1.05), int(r_outer * 0.7), -4):
        alpha = int(35 * (1 - (r - r_outer * 0.7) / (r_outer * 0.35)))
        if alpha > 0:
            glow_draw.ellipse(
                [center - r, center - r, center + r, center + r],
                fill=(0, 229, 255, alpha)
            )
    glow_img = glow_img.filter(ImageFilter.GaussianBlur(size * 0.04))
    img.paste(glow_img, (0, 0), glow_img)
    
    # Main dark body
    body_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    body_draw = ImageDraw.Draw(body_img)
    
    # Deep obsidian circular background
    for i in range(int(r_outer)):
        factor = i / r_outer
        # Dark slate to deep obsidian
        red = int(10 + factor * 12)
        green = int(16 + factor * 18)
        blue = int(28 + factor * 35)
        body_draw.ellipse(
            [center - (r_outer - i), center - (r_outer - i), center + (r_outer - i), center + (r_outer - i)],
            fill=(red, green, blue, 255)
        )
    
    # Outer Neon Border
    border_width = int(size * 0.022)
    for b in range(border_width):
        t = b / border_width
        # Cyan to Emerald gradient
        cr = int(0)
        cg = int(229 + (245 - 229) * t)
        cb = int(255 - (255 - 155) * t)
        cur_r = r_outer - b
        body_draw.ellipse(
            [center - cur_r, center - cur_r, center + cur_r, center + cur_r],
            outline=(cr, cg, cb, int(220 * (1 - t * 0.3))),
            width=2
        )
        
    img.paste(body_img, (0, 0), body_img)
    
    # 2. Draw Futuristic Shield & Lock Emblem
    emblem_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    emblem_draw = ImageDraw.Draw(emblem_img)
    
    # Shield Path Coordinates
    s_top = center - size * 0.22
    s_bottom = center + size * 0.24
    s_left = center - size * 0.23
    s_right = center + size * 0.23
    
    shield_pts = [
        (center, s_top - size * 0.02),
        (s_right, s_top + size * 0.05),
        (s_right - size * 0.03, center + size * 0.08),
        (center, s_bottom),
        (s_left + size * 0.03, center + size * 0.08),
        (s_left, s_top + size * 0.05),
    ]
    
    # Inner Shield Glow
    emblem_draw.polygon(shield_pts, fill=(0, 245, 155, 30))
    emblem_draw.line(shield_pts + [shield_pts[0]], fill=(0, 245, 155, 240), width=int(size * 0.02))
    
    # 3. Inner Power / Lock Core
    c_rad = size * 0.11
    # Glowing power ring
    emblem_draw.ellipse(
        [center - c_rad, center - c_rad + size * 0.02, center + c_rad, center + c_rad + size * 0.02],
        outline=(0, 229, 255, 255),
        width=int(size * 0.025)
    )
    
    # Power vertical notch
    notch_w = int(size * 0.025)
    notch_h = int(size * 0.08)
    emblem_draw.rounded_rectangle(
        [center - notch_w // 2, center - size * 0.12, center + notch_w // 2, center - size * 0.12 + notch_h],
        radius=int(size * 0.01),
        fill=(0, 245, 155, 255)
    )
    
    # Central lightning / speed beam
    core_star = [
        (center, center + size * 0.01),
        (center + size * 0.035, center + size * 0.05),
        (center, center + size * 0.14),
        (center - size * 0.01, center + size * 0.07),
    ]
    emblem_draw.polygon(core_star, fill=(255, 255, 255, 250))
    
    # Blend glow
    emblem_glow = emblem_img.filter(ImageFilter.GaussianBlur(size * 0.02))
    img.paste(emblem_glow, (0, 0), emblem_glow)
    img.paste(emblem_img, (0, 0), emblem_img)
    
    return img

if __name__ == '__main__':
    icon = create_vpn_icon(1024)
    out_dir = r"c:\Users\Admin\Desktop\vpn\android\app\src\main\res"
    
    sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }
    
    for folder, px in sizes.items():
        fpath = os.path.join(out_dir, folder)
        os.makedirs(fpath, exist_ok=True)
        resized = icon.resize((px, px), Image.Resampling.LANCZOS)
        resized.save(os.path.join(fpath, 'ic_launcher.png'))
        print(f"Saved {folder}/ic_launcher.png ({px}x{px})")
        
    # Also save 512x512 preview in brain directory
    preview_path = r"C:\Users\Admin\.gemini\antigravity\brain\0193c30f-e7f1-4388-be7e-db606bea01d8\app_icon_preview.png"
    icon.resize((512, 512), Image.Resampling.LANCZOS).save(preview_path)
    print("Saved preview to:", preview_path)
