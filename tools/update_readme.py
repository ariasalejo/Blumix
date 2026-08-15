#!/usr/bin/env python3

from pathlib import Path
import re
import shutil
from datetime import datetime


ROOT = Path(__file__).resolve().parent.parent
README = ROOT / "README.md"
ROADMAP = ROOT / "ROADMAP.md"

START = "<!-- BLUMIX_ROADMAP_START -->"
END = "<!-- BLUMIX_ROADMAP_END -->"


def backup_file(path: Path) -> Path:
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    backup = path.with_name(
        f"{path.name}.backup-{timestamp}"
    )
    shutil.copy2(path, backup)
    return backup


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def write_text(path: Path, content: str) -> None:
    path.write_text(content, encoding="utf-8")


def build_block(roadmap: str) -> str:
    roadmap = roadmap.strip()

    return (
        f"{START}\n\n"
        "## 🗺️ ROADMAP\n\n"
        f"{roadmap}\n\n"
        f"{END}"
    )


def update_readme(readme: str, roadmap: str) -> str:
    block = build_block(roadmap)

    pattern = re.compile(
        re.escape(START) + r".*?" + re.escape(END),
        re.DOTALL,
    )

    if pattern.search(readme):
        return pattern.sub(block, readme, count=1)

    separator = "\n\n"

    if not readme.endswith("\n"):
        separator = "\n\n"

    return readme.rstrip() + separator + block + "\n"


def main() -> int:
    print()
    print("🚀 BLUMIX · ROADMAP → README")
    print("=" * 50)
    print()

    if not README.exists():
        print(f"❌ No existe: {README}")
        return 1

    if not ROADMAP.exists():
        print(f"❌ No existe: {ROADMAP}")
        return 1

    roadmap = read_text(ROADMAP).strip()

    if not roadmap:
        print("❌ ROADMAP.md está vacío.")
        return 1

    print(f"📄 README : {README}")
    print(f"🗺️  ROADMAP: {ROADMAP}")
    print()

    backup = backup_file(README)
    print(f"🛡️ Backup creado:")
    print(f"   {backup.name}")
    print()

    current_readme = read_text(README)
    new_readme = update_readme(current_readme, roadmap)

    write_text(README, new_readme)

    print("✅ README.md actualizado.")
    print()
    print("📌 El contenido de ROADMAP.md quedó integrado")
    print("   dentro de la sección:")
    print()
    print("   ## 🗺️ ROADMAP")
    print()
    print("🔐 El README anterior quedó respaldado.")
    print()

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
