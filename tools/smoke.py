#!/usr/bin/env python3
"""Headless-проверка собранного мода по дампу Factorio.

Ожидает каталог script-output, полученный после:
    factorio --dump-prototype-locale   (locale=ru)

Проверяет:
  * прототипы подстанций (зона снабжения, длина провода, здоровье);
  * формат спрайтов 2.0+ (pictures.layers);
  * предметы, рецепты и технологии (связи, блокировка, предпосылки);
  * что русские названия из locale/ru действительно применились.

Запуск: python3 tools/smoke.py <каталог script-output>
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

EXPECTED = {
    "substation-2": {"supply": 16, "wire": 32, "health": 200},
    "substation-3": {"supply": 24, "wire": 48, "health": 100},
    "substation-4": {"supply": 32, "wire": 64, "health": 100},
}

EXPECTED_TECH = {
    "electric-substation-3": "substation-2",
    "electric-substation-4": "substation-3",
    "electric-substation-5": "substation-4",
}

EXPECTED_RU_ENTITY = {
    "substation-2": "Улучшенная подстанция",
    "substation-3": "Экспериментальная нуклонная подстанция",
    "substation-4": "Безрассудная подстанция",
}

EXPECTED_RU_TECH = {
    "electric-substation-3": "Улучшенные подстанции",
    "electric-substation-4": "Нуклонные подстанции",
    "electric-substation-5": "Безрассудные подстанции",
}

errors: list[str] = []


def check(condition: bool, message: str) -> None:
    if not condition:
        errors.append(message)


def load(path: Path) -> dict:
    if not path.is_file():
        errors.append(f"нет файла дампа: {path.name} (Factorio не загрузил мод?)")
        return {}
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def check_prototypes(data: dict) -> None:
    poles = data.get("electric-pole", {})
    items = data.get("item", {})
    recipes = data.get("recipe", {})
    technologies = data.get("technology", {})

    for name, expected in EXPECTED.items():
        pole = poles.get(name)
        check(pole is not None, f"нет прототипа electric-pole {name}")
        if not pole:
            continue

        check(pole.get("type") == "electric-pole", f"{name}: неверный type")
        check(pole.get("supply_area_distance") == expected["supply"],
              f"{name}: supply_area_distance {pole.get('supply_area_distance')} != {expected['supply']}")
        check(pole.get("maximum_wire_distance") == expected["wire"],
              f"{name}: maximum_wire_distance {pole.get('maximum_wire_distance')} != {expected['wire']}")
        check(pole.get("max_health") == expected["health"],
              f"{name}: max_health {pole.get('max_health')} != {expected['health']}")

        pictures = pole.get("pictures") or {}
        layers = pictures.get("layers") or []
        check(bool(layers), f"{name}: pictures.layers пуст (нужен формат Factorio 2.0+)")
        for layer in layers:
            filename = layer.get("filename", "")
            check(bool(filename), f"{name}: у слоя спрайта нет filename")
            check(layer.get("direction_count") == 4,
                  f"{name}: direction_count {layer.get('direction_count')} != 4")

        check(pole.get("icon") is not None, f"{name}: нет icon")
        check(pole.get("icon_size") == 32, f"{name}: icon_size != 32")
        check(pole.get("fast_replaceable_group") == "electric-pole",
              f"{name}: fast_replaceable_group")

        item = items.get(name)
        check(item is not None, f"нет предмета {name}")
        if item:
            check(item.get("place_result") == name, f"{name}: place_result != {name}")

        recipe = recipes.get(name)
        check(recipe is not None, f"нет рецепта {name}")
        if recipe:
            check(recipe.get("enabled") is False, f"{name}: рецепт должен быть заблокирован")
            check(bool(recipe.get("ingredients")), f"{name}: у рецепта нет ингредиентов")
            results = recipe.get("results") or []
            check(any(r.get("name") == name for r in results if isinstance(r, dict)),
                  f"{name}: рецепт не производит {name}")

    for tech_name, unlocks in EXPECTED_TECH.items():
        tech = technologies.get(tech_name)
        check(tech is not None, f"нет технологии {tech_name}")
        if not tech:
            continue
        effects = tech.get("effects") or []
        check(any(e.get("type") == "unlock-recipe" and e.get("recipe") == unlocks for e in effects),
              f"{tech_name}: не открывает рецепт {unlocks}")

    tech3 = technologies.get("electric-substation-3") or {}
    check("advanced-circuit" in (tech3.get("prerequisites") or []),
          "electric-substation-3: в предпосылках нет advanced-circuit")


def check_locale(dump_dir: Path) -> None:
    entity_locale = load(dump_dir / "entity-locale.json").get("names", {})
    item_locale = load(dump_dir / "item-locale.json").get("names", {})
    tech_locale = load(dump_dir / "technology-locale.json").get("names", {})
    tech_desc = load(dump_dir / "technology-locale.json").get("descriptions", {})

    for name, expected in EXPECTED_RU_ENTITY.items():
        check(entity_locale.get(name) == expected,
              f"локализация entity {name}: {entity_locale.get(name)!r} != {expected!r}")
        check(item_locale.get(name) == expected,
              f"локализация item {name}: {item_locale.get(name)!r} != {expected!r}")

    for name, expected in EXPECTED_RU_TECH.items():
        check(tech_locale.get(name) == expected,
              f"локализация technology {name}: {tech_locale.get(name)!r} != {expected!r}")
        check(bool(tech_desc.get(name)), f"локализация technology {name}: нет описания")


def main() -> int:
    if len(sys.argv) != 2:
        print("Использование: tools/smoke.py <каталог script-output>", file=sys.stderr)
        return 2

    dump_dir = Path(sys.argv[1])
    if not dump_dir.is_dir():
        print(f"Нет каталога {dump_dir}", file=sys.stderr)
        return 2

    check_prototypes(load(dump_dir / "data-raw-dump.json"))
    check_locale(dump_dir)

    for message in errors:
        print(f"ERROR {message}")
    if errors:
        print(f"\nSmoke-проверка не пройдена: {len(errors)} ошибок.")
        return 1

    print("Smoke-проверка пройдена: прототипы и локализация в порядке.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
