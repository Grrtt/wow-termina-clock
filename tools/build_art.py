"""Build original vector artwork inspired by the N64 clock HUD."""
from pathlib import Path
import math
import subprocess
root = Path(__file__).resolve().parents[1]
art = root / 'art'
textures = root / 'TerminaClock/Textures'

def build(name, body, width=256, height=128):
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}"><defs>
    <linearGradient id="gem" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#249e65"/><stop offset=".48" stop-color="#007143"/><stop offset="1" stop-color="#002e21"/></linearGradient>
    <radialGradient id="sun"><stop stop-color="#ffbcb2"/><stop offset=".45" stop-color="#e67479"/><stop offset="1" stop-color="#9c303f"/></radialGradient>
    </defs>{body}</svg>'''
    source = art / f'{name}.svg'
    source.write_text(svg)
    subprocess.run(['magick','-background','none',str(source),'-resize',f'{width//2}x{height//2}!','-colors','96','-filter','point','-resize',f'{width}x{height}!','-depth','8','-type','TrueColorAlpha','-compress','none',str(textures/f'{name}.tga')],check=True)

spokes = ''
for i in range(13):
    a=math.pi-i*math.pi/12
    x,y=128+math.cos(a)*101,106-math.sin(a)*81
    spokes+=f'<path d="M128 94 L{x:.2f} {y:.2f}" stroke="#d5c580" stroke-opacity=".65" stroke-width="1.3"/>'
build('dial',spokes+'''<path d="M12 107 Q23 111 23 103 C26 -5 230 -5 233 103 Q233 111 244 107" fill="none" stroke="#655e4e" stroke-opacity=".45" stroke-width="5"/>
<path d="M12 106 Q23 110 23 102 C26 -3 230 -3 233 102 Q233 110 244 106" fill="none" stroke="#fffbe5" stroke-width="3.2" stroke-linecap="round"/>
<path d="M128 25 C114 17 113 9 120 10 Q130 11 128 23 C127 7 136 2 136 10 Q137 17 129 24 C139 10 150 16 144 21 Q139 25 128 25" fill="none" stroke="#fffbe5" stroke-width="2.2" stroke-linecap="round"/>
<path d="M128 52 Q137 60 145 67 L164 84 Q164 89 153 95 L132 115 Q128 119 124 114 L99 95 Q89 89 95 83 L117 63Z" fill="#003d2a" stroke="#183e29" stroke-width="3"/>
<path d="M128 53 L159 85 Q165 88 152 94 L128 115 L96 91 Q91 88 100 81Z" fill="url(#gem)" stroke="#0e9b65" stroke-width="1.5"/>
<path d="M128 54 L128 111 L98 88Z" fill="#42a36c" opacity=".18"/>
''')
# The original day numeral is tall, with a much smaller ordinal beside it.
for name, numeral, suffix in [('first', '1', 'st'), ('second', '2', 'nd')]:
    build(name, f'''<g fill="#fff09a" stroke="#24412b" stroke-width="2.6" paint-order="stroke" font-family="DejaVu Serif" font-weight="bold" font-style="italic">
    <text x="102" y="105" font-size="49" transform="rotate(-5 120 90)">{numeral}</text>
    <text x="129" y="93" font-size="27" letter-spacing="-3">{suffix}</text></g>''')
for name,label,size in [('final','Final',26),('new','New',26),('waiting','--',30)]:
    build(name,f'''<text x="128" y="98" text-anchor="middle" font-family="DejaVu Serif" font-style="italic" font-weight="bold" font-size="{size}" letter-spacing="-3" fill="#fff29a" stroke="#163622" stroke-width="2.6" paint-order="stroke">{label}</text>''')
for hour in range(1, 13):
    build(f'hour{hour}', f'''<text x="16" y="25" text-anchor="middle" font-family="DejaVu Serif" font-weight="bold" font-size="24" fill="#ffffdf" stroke="#67654a" stroke-width="1.1" paint-order="stroke">{hour}</text>''', 32, 32)
rays=''
for i in range(12):
    a=i*math.pi/6
    points=[]
    for radius,angle in [(9,a-.12),(15,a+.06),(9,a+.23)]:
        points.append(f'{16+math.cos(angle)*radius:.2f},{16+math.sin(angle)*radius:.2f}')
    rays+=f'<polygon points="{" ".join(points)}" fill="#d96572" stroke="#572b36" stroke-width=".7"/>'
build('sun',rays+'''<circle cx="16" cy="16" r="8.4" fill="url(#sun)" stroke="#ffc0a0" stroke-width="1"/><path d="M12 14 l2 1 M18 15 l2 -1 M13 19 Q16 22 19 18" fill="none" stroke="#843544" stroke-width="1.2"/>''',32,32)
build('moon','''<path d="M22 3 C4 2 0 25 17 29 Q25 30 29 23 C15 29 10 12 22 3Z" fill="#fff8b2" stroke="#77714e" stroke-width="1"/><path d="M10 12 Q8 22 17 25" fill="none" stroke="#d7c86f" stroke-width="1.5"/>''',32,32)
build('star','''<path d="M16 0 L19 11 28 4 22 13 32 16 21 19 28 28 19 22 16 32 13 21 4 28 10 19 0 16 11 13 4 4 13 10Z" fill="#fff584"/><circle cx="16" cy="16" r="4" fill="#ffffd4"/>''',32,32)
for day, word, hours in [('first','First',72),('second','Second',48),('final','Final',24)]:
    build('dawn-' + day, f'''<g fill="#fffef0" text-anchor="middle" font-family="DejaVu Serif">
    <text x="512" y="165" font-size="61">Dawn of</text>
    <text x="512" y="263" font-size="80">The {word} Day</text>
    <text x="512" y="338" font-size="33">–{hours} Hours Remain–</text></g>''', 1024, 512)
# A preview composites the exact textures and coordinates used by the addon.
subprocess.run(['magick','-size','512x256','xc:#393b3b',str(textures/'dial.tga'),'-filter','point','-geometry','512x256+0+0','-composite',str(textures/'first.tga'),'-filter','point','-geometry','512x256+0+0','-composite',str(textures/'sun.tga'),'-geometry','48x48+46+94','-composite',str(textures/'star.tga'),'-geometry','28x28+275+196','-composite',str(root/'preview.png')],check=True)
