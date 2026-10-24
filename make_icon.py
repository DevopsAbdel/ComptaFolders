from PIL import Image, ImageDraw, ImageFont
import os

sizes = [16,32,48,64,128,256]
imgs = []

def draw_icon(size):
    img = Image.new('RGBA', (size, size), (0,0,0,0))
    d = ImageDraw.Draw(img)
    # background rounded
    r = size//6
    d.rounded_rectangle([0,0,size-1,size-1], radius=r, fill=(14,14,14,255))
    # folder body
    pad = size//8
    fw = size - 2*pad
    fh = size//2
    fx = pad
    fy = size//3
    d.rounded_rectangle([fx, fy, fx+fw, fy+fh], radius=size//16, fill=(120,86,255,255))
    # folder tab
    tw = fw//2
    th = size//8
    d.rounded_rectangle([fx, fy-th, fx+tw, fy+1], radius=size//16, fill=(155,124,255,255))
    # document lines
    liney = fy + fh//3
    for i in range(3):
        y = liney + i*(size//12)
        d.rectangle([fx+size//6, y, fx+fw-size//6, y+max(1,size//24)], fill=(255,255,255,200))
    return img

for s in sizes:
    imgs.append(draw_icon(s))

ico_path = os.path.join(os.path.dirname(__file__), 'Resources', 'app.ico')
os.makedirs(os.path.dirname(ico_path), exist_ok=True)
imgs[0].save(ico_path, format='ICO', sizes=[(s,s) for s in sizes], append_images=imgs[1:])
print('done', ico_path)
