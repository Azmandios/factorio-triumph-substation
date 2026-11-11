#!/usr/bin/env python3
"""Статические проверки мода TriumphSubstation2 перед сборкой и публикацией.

Проверяется:
  * info.json (обязательные поля, имя мода, версия, factorio_version);
  * совпадение версии в info.json и верхнего блока changelog.txt;
  * префиксы __mod__/... в путях к ресурсам (должны указывать на этот мод);
  * существование всех файлов графики, на которые ссылаются прототипы;
  * паритет ключей локализации en/ru;
  * наличие LICENSE.

Запуск: python3 tools/check.py
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ERRORS: list[str] = []
WARNINGS: list[str] = []


def error(msg: str) -> None:
    ERRORS.append(msg)


def warn(msg: str) -> None:
    WARNINGS.append(msg)


def load_info() -> dict:
    path = ROOT / "info.json"
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        error("info.json не найден")
    except json.JSONDecodeError as exc:
        error(f"info.json: некорректный JSON: {exc}")
    return {}


def check_info(info: dict) -> str:
    required = ("name", "version", "title", "author", "factorio_version", "dependencies", "description")
    for key in required:
        if not info.get(key):
            error(f"info.json: отсутствует поле {key!r}")

    name = info.get("name", "")
    if not re.fullmatch(r"[A-Za-z0-9_-]+", name):
        error(f"info.json: name {name!r} не соответствует шаблону [A-Za-z0-9_-]+")

    version = info.get("version", "")
    if not re.fullmatch(r"\d+\.\d+\.\d+", version):
        error(f"info.json: version {version!r} не в формате X.Y.Z")

    if info.get("factorio_version") != "2.1":
        error("info.json: factorio_version должен быть '2.1'")

    deps = info.get("dependencies") or []
    if not any(str(d).startswith("base >=") for d in deps):
        error("info.json: нет зависимости 'base >= ...'")

    for key in ("homepage", "contact"):
        value = info.get(key, "")
        if value and not re.match(r"^https?://", value):
            warn(f"info.json: {key} не похоже на URL: {value!r}")

    return name


def check_changelog(info: dict) -> None:
    path = ROOT / "changelog.txt"
    if not path.exists():
        error("changelog.txt не найден")
        return
    text = path.read_text(encoding="utf-8", errors="replace")
    match = re.search(r"^Version:\s*(\S+)", text, re.MULTILINE)
    if not match:
        error("changelog.txt: не найден блок 'Version:'")
        return
    if match.group(1) != info.get("version"):
        error(
            "changelog.txt: верхняя версия "
            f"{match.group(1)} не совпадает с info.json {info.get('version')}"
        )


def lua_files() -> list[Path]:
    return sorted(p for p in ROOT.rglob("*.lua") if "original" not in p.parts and ".git" not in p.parts)


def check_resource_prefixes(name: str) -> None:
    pattern = re.compile(r"__([A-Za-z0-9_-]+)__/")
    for path in lua_files():
        for lineno, line in enumerate(path.read_text(encoding="utf-8", errors="replace").splitlines(), 1):
            for mod in pattern.findall(line):
                if mod != name:
                    error(
                        f"{path.relative_to(ROOT)}:{lineno}: путь указывает на __{mod}__, "
                        f"а мод называется {name}"
                    )


def check_sprite_files(name: str) -> None:
    pattern = re.compile(rf"__{re.escape(name)}__/([^\"'\s]*)")
    for path in lua_files():
        text = path.read_text(encoding="utf-8", errors="replace")
        for lineno, line in enumerate(text.splitlines(), 1):
            for rel in pattern.findall(line):
                if not (ROOT / rel).is_file():
                    error(f"{path.relative_to(ROOT)}:{lineno}: нет файла {rel}")


def parse_locale(path: Path) -> dict[str, str]:
    result: dict[str, str] = {}
    section = ""
    for raw in path.read_text(encoding="utf-8", errors="replace").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or line.startswith(";"):
            continue
        if line.startswith("[") and line.endswith("]"):
            section = line[1:-1]
            continue
        if "=" in line:
            key, value = line.split("=", 1)
            result[f"{section}.{key.strip()}"] = value.strip()
    return result


def check_locales() -> None:
    en_path = ROOT / "locale" / "en" / "en.cfg"
    ru_path = ROOT / "locale" / "ru" / "ru.cfg"
    for path in (en_path, ru_path):
        if not path.is_file():
            error(f"нет файла локализации: {path.relative_to(ROOT)}")
            return

    en = parse_locale(en_path)
    ru = parse_locale(ru_path)

    for key in sorted(en.keys() - ru.keys()):
        error(f"локаль ru: отсутствует ключ {key}")
    for key in sorted(ru.keys() - en.keys()):
        error(f"локаль en: отсутствует ключ {key}")
    for key, value in en.items():
        if not value:
            error(f"локаль en: пустое значение {key}")
    for key, value in ru.items():
        if not value:
            error(f"локаль ru: пустое значение {key}")
    if not en:
        error("локаль en: не найдено ни одной строки")


def check_license() -> None:
    path = ROOT / "LICENSE"
    if not path.is_file():
        error("LICENSE не найден")
        return
    text = path.read_text(encoding="utf-8", errors="replace")
    if "MIT License" not in text:
        warn("LICENSE: ожидалась лицензия MIT")
    if "Logvinov Alecksey" not in text:
        warn("LICENSE: не указан автор оригинала")


def main() -> int:
    info = load_info()
    name = check_info(info)
    check_changelog(info)
    if name:
        check_resource_prefixes(name)
        check_sprite_files(name)
    check_locales()
    check_license()

    for msg in WARNINGS:
        print(f"WARN  {msg}")
    for msg in ERRORS:
        print(f"ERROR {msg}")

    if ERRORS:
        print(f"\nПроверка не пройдена: {len(ERRORS)} ошибок, {len(WARNINGS)} предупреждений.")
        return 1

    print(f"Проверка пройдена: 0 ошибок, {len(WARNINGS)} предупреждений.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
