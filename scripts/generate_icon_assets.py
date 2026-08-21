from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
source = ROOT / "mobile" / "assets" / "tv_stream_icon.png"
resolutions = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

with Image.open(source).convert("RGB") as image:
    for folder, size in resolutions.items():
        destination = ROOT / "mobile" / "android" / "app" / "src" / "main" / "res" / folder
        destination.mkdir(parents=True, exist_ok=True)
        image.resize((size, size), Image.Resampling.LANCZOS).save(destination / "ic_launcher.png", optimize=True)
    image.resize((512, 512), Image.Resampling.LANCZOS).save(ROOT / "assets" / "tv_stream_icon_512.png", optimize=True)
