# Triumph Substations (2.1 port)

Community port of the **Triump Substations** mod to Factorio 2.1.

- Original mod and assets: **Logvinov Alecksey** ([alecksey.com](https://alecksey.com))
- Original mod for Factorio 1.1: [mods.factorio.com/mod/TriumphSubstation](https://mods.factorio.com/mod/TriumphSubstation) (MIT)
- 2.1 port and maintenance: **Azmandios**
- Mod Portal: [mods.factorio.com/mod/TriumphSubstation2](https://mods.factorio.com/mod/TriumphSubstation2)
- Tested on Factorio **2.1.24** (Steam, Space Age)

The Mod Portal name is `TriumphSubstation2` because `TriumphSubstation` is already
taken by the 1.1 version. Internal prototype names (`substation-2/3/4`,
`electric-substation-3/4/5`) are unchanged, so saves and blueprints from the
original mod keep working.

## What it adds

Three substations with a larger supply area, longer wire reach, and more expensive recipes:

| Item | Supply area | Wire reach | Health | Notes |
|------|-------------|------------|--------|-------|
| Advanced Substation | 32×32 | 32 | 200 | First upgrade |
| Experimental Nucleonic Substation | 48×48 | 48 | 100 | Explodes when destroyed |
| Reckless Substation | 64×64 | 64 | 100 | Largest supply area |

The Experimental Nucleonic Substation detonates with a full atomic-bomb blast when
destroyed. Use at your own risk.

## Research

| Technology | Unlocks | Prerequisites |
|------------|---------|---------------|
| `electric-substation-3` — Advanced Substations | Advanced Substation | `electric-energy-distribution-2`, `advanced-circuit` |
| `electric-substation-4` — Nucleonic Substations | Experimental Nucleonic Substation | `electric-substation-3`, `nuclear-power` |
| `electric-substation-5` — Reckless Substations | Reckless Substation | `electric-substation-4`, `nuclear-power` |

## Installation

From the Mod Portal: subscribe in game (Mods → Install mods).

From the zip:

1. Download `dist/TriumphSubstation2_<version>.zip` (or take it from a GitHub release).
2. Put the zip into your Factorio mods folder:
   - Windows: `%APPDATA%\Factorio\mods`
   - Linux/macOS: `~/.factorio/mods`
3. Enable **Triumph Substations (2.1 port)** in the in-game mod list.

No other mods are required. Space Age is optional.

## Development

Repository layout (mod files live in the repository root, as Factorio expects):

```
info.json, changelog.txt, control.lua, data.lua
graphics/ locale/ migrations/ prototypes/   mod content
original/                                   original 1.0.0 source (Factorio 1.1), reference only
tests/                                      headless test mod + scenario
tools/check.py                              static checks (info.json, changelog, sprites, locale)
tools/smoke.py                              prototype/locale checks on the Factorio dump
scripts/build.sh                            build dist/<name>_<version>.zip
scripts/test.sh                             static checks + Factorio dump + scenario test
scripts/release.sh                          bump version, changelog, commit, tag, build
scripts/publish.sh                          upload the built zip to the Mod Portal
```

Common commands:

```bash
make check      # static checks only
make build      # dist/TriumphSubstation2_<version>.zip
make test       # checks + headless Factorio run (needs Factorio installed)
make install    # build and copy into the local Factorio mods folder
make release BUMP=patch CHANGES="..."   # release
make publish    # upload to the Mod Portal
```

`FACTORIO_BIN` and `FACTORIO_MODS` override the default macOS paths.

The headless test does three things:

1. builds the zip and starts Factorio with the mod;
2. `--dump-data` / `--dump-prototype-locale` — verifies supply areas, wire reach,
   2.0+ `pictures.layers` sprites, recipes, technologies and Russian names;
3. `--test-scenario` — places `substation-3`, destroys it, and checks that the
   atomic blast kills nearby walls and spares a distant one.

## Publishing

The first release requires the mod page to exist (the Mod Portal API can only add
releases to an existing mod): <https://mods.factorio.com/mods/new>

- Name: `TriumphSubstation2`
- Factorio version: 2.1
- License: MIT
- Category: Content
- Tags: Circuit network

Then put the API token (factorio.com → Profile → API keys, permission
`ModPortal: Upload Mods`) into `.mod-portal-token` (chmod 600, ignored by git) or
export `MOD_PORTAL_TOKEN`, and run `make publish`.

The page text lives in the repository: `portal/metadata.json` (title, summary,
category, tags, license) and `portal/description.md` (markdown). After the page
exists, `make portal-details` applies them (needs the `ModPortal: Edit Mods`
permission on the token).

## Credits and license

Original mod and assets: **Logvinov Alecksey**.
Factorio 2.1 port: **Azmandios**.

The original mod is published under the MIT license; this port keeps the same
license, see [LICENSE](LICENSE). If you are the original author and want any part
of this repository changed, please open an issue.

## Porting notes

The 2.1 port required more than repacking: Factorio 2.0 changed several prototype APIs.
See [PORTING_NOTES.md](PORTING_NOTES.md) for details. Summary:

- `info.json` updated to `factorio_version` 2.1 and the new mod name.
- Electric-pole sprites now use `pictures.layers`.
- Recipes use the 2.x ingredient/result format.
- `advanced-electronics` was removed in 2.0 and replaced with `advanced-circuit`.
- `create_entity()` no longer accepts `speed`; the atomic rocket is spawned
  slightly away from the substation and its speed is assigned after creation.
- Technologies end with a tier number, so their `localised_name` and
  `localised_description` are set explicitly to avoid the automatic
  "<base name> N" fallback.

---

## По-русски

Это порт мода **Triump Substations** (Factorio 1.1) на Factorio 2.1.
Оригинальный автор — Логвинов Алексей (alecksey.com), лицензия MIT. Порт: Azmandios.

На Mod Portal мод называется `TriumphSubstation2`: имя `TriumphSubstation` занято
версией для 1.1. Внутренние имена прототипов не менялись, поэтому сохранения и
чертежи из оригинального мода продолжают работать.

Установка: подписка на Mod Portal или zip из `dist/` в папку модов Factorio.
Другие моды не нужны, Space Age не обязателен.

Сборка и проверка: `make build`, `make test`. Публикация: `make publish`
(нужен токен Mod Portal в `.mod-portal-token`).
Технические подробности порта — в [PORTING_NOTES.md](PORTING_NOTES.md).
