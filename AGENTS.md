# AGENTS.md

> Карта проекта для AI-агентов. Обновляйте при значительных изменениях структуры.

## Обзор

Порт мода **Triump Substations** (Factorio 1.1, автор Logvinov Alecksey, MIT) на
Factorio 2.1. Публикуется на Mod Portal как `TriumphSubstation2`, потому что имя
`TriumphSubstation` занято оригиналом.

Внутренние имена прототипов (`substation-2/3/4`, `electric-substation-3/4/5`)
совпадают с оригиналом: сохранения и чертежи совместимы. Не переименовывать без
крайней необходимости.

## Стек

- Lua-прототипы Factorio (data stage) + `control.lua` (runtime).
- Инструменты: Python 3, bash, `make`.
- Factorio 2.1+ (проверено на 2.1.24).

## Структура

```
info.json, changelog.txt, control.lua, data.lua   манифест и точка входа
graphics/                                        спрайты и иконки
locale/en/en.cfg, locale/ru/ru.cfg               названия и описания
migrations/                                      миграции из 0.16.x (наследие)
prototypes/                                      entity, item, recipe, technology
original/TriumphSubstation_1.0.0/                исходники 1.1, только для справки
tests/triumphsubstation2-tests/                  тестовый мод + scenario для --test-scenario
tools/check.py                                   статические проверки
tools/smoke.py                                   проверка дампа Factorio
scripts/build.sh                                 сборка dist/<name>_<version>.zip
scripts/test.sh                                  check + дамп + сценарный тест
scripts/release.sh                               bump версии, changelog, коммит, тег
scripts/publish.sh                               загрузка релиза на Mod Portal
```

## Команды

| Команда | Что делает |
|---------|------------|
| `make check` | статические проверки (info.json, changelog, спрайты, локали, LICENSE) |
| `make build` | собрать zip в `dist/` |
| `make test` | `check` + сборка + `--dump-data`/`--dump-prototype-locale` + сценарный тест |
| `make install` | собрать и распаковать в локальную папку модов Factorio |
| `make release BUMP=patch CHANGES="..."` | релиз: версия, changelog, коммит, тег, сборка |
| `make publish` | загрузить zip на Mod Portal (токен в `.mod-portal-token`) |

Пути Factorio переопределяются через `FACTORIO_BIN` и `FACTORIO_MODS`.

## Правила

- Пути к ресурсам — только `__TriumphSubstation2__/...`; `tools/check.py` ловит
  забытые префиксы.
- Версия в `info.json` и в верхнем блоке `changelog.txt` должна совпадать.
- Спрайты электрических столбов — в формате 2.0+ (`pictures.layers`).
- У технологий с номером в конце имени обязательны явные `localised_name` и
  `localised_description`, иначе Factorio берёт `<база> N` из ключа без номера.
- Ключи `locale/en` и `locale/ru` должны совпадать; проверяется `make check`.
- `original/` не редактировать — это снимок апстрима.
- Перед коммитом — `make test` (0 ошибок).
- Секреты: `.mod-portal-token`, `.env` в `.gitignore`.
