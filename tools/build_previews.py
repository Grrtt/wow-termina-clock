"""Compose labeled artwork previews; these are not in-game screenshots."""
from pathlib import Path
import subprocess

root = Path(__file__).resolve().parents[1]
textures = root / 'TerminaClock/Textures'
output = root / 'docs/images'
output.mkdir(parents=True, exist_ok=True)
for day in ['first', 'second', 'final']:
    subprocess.run([
        'magick', '-size', '512x256', 'xc:#252b30',
        str(textures / 'dial.tga'), '-filter', 'point', '-geometry', '512x256+0+0', '-composite',
        str(textures / f'{day}.tga'), '-geometry', '512x256+0+0', '-composite',
        str(textures / 'sun.tga'), '-geometry', '50x50+45+93', '-composite',
        str(textures / 'hour8.tga'), '-geometry', '44x44+48+50', '-composite',
        str(textures / 'star.tga'), '-geometry', '32x32+276+188', '-composite',
        str(output / f'clock-{day}-preview.png'),
    ], check=True)
subprocess.run([
    'magick', '-size', '1024x512', 'xc:black', str(textures / 'dawn-first.tga'),
    '-composite', str(output / 'dawn-preview.png'),
], check=True)
