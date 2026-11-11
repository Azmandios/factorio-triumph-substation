# Triumph Substations — Factorio 2.1 port

Community port of **Triumph Substations** to Factorio 2.1.

- Original mod: **Logvinov Alecksey** (contact: [alecksey.com](https://alecksey.com))
- 2.1 port: **Azmandios**
- Tested on Factorio **2.1.24** (Steam, Space Age)

## What it adds

Three substations with a larger supply area, longer wire reach, and more expensive recipes:

| Item | Supply area | Wire reach | Health | Notes |
|------|-------------|------------|--------|-------|
| Advanced Substation | 32×32 | 32 | 200 | First upgrade |
| Experimental Nucleonic Substation | 48×48 | 48 | 100 | Explodes when destroyed |
| Reckless Substation | 64×64 | 64 | 100 | Largest supply area |

The Experimental Nucleonic Substation detonates with a full atomic-bomb blast when destroyed.
Use at your own risk.

## Research

| Technology | Unlocks | Prerequisites |
|------------|---------|---------------|
| `electric-substation-3` — Advanced Substations | Advanced Substation | `electric-energy-distribution-2`, `advanced-circuit` |
| `electric-substation-4` — Nucleonic Substations | Experimental Nucleonic Substation | `electric-substation-3`, `nuclear-power` |
| `electric-substation-5` — Reckless Substations | Reckless Substation | `electric-substation-4`, `nuclear-power` |

The internal prototype names are `substation-2`, `substation-3` and `substation-4`;
the technologies that unlock them are named `electric-substation-3`, `-4` and `-5`.

## Installation

1. Download `dist/TriumphSubstation_2.1.0.zip` (or take it from the latest GitHub release).
2. Put the zip into your Factorio mods folder:
   - Windows: `%APPDATA%\Factorio\mods`
   - Linux/macOS: `~/.factorio/mods`
3. Enable **Triumph Substations** in the in-game mod list.

No other mods are required. Space Age is optional.

## Building the zip

Windows (PowerShell):

```powershell
pwsh -File build.ps1
```

Linux/macOS:

```bash
./build.sh
```

The archive is written to `dist/`.

## Repository layout

```
src/        Mod source for Factorio 2.1
original/   Original 1.0.0 source (Factorio 1.1), kept for reference
dist/       Ready-to-install zip
build.ps1   Packaging script (Windows)
build.sh    Packaging script (Linux/macOS)
PORTING_NOTES.md  Technical notes about the 2.1 port
```

## Porting notes

The 2.1 port required more than repacking: Factorio 2.0 changed several prototype APIs.
See [PORTING_NOTES.md](PORTING_NOTES.md) for details. Summary:

- `info.json` updated to `factorio_version` 2.1.
- Electric-pole sprites now use `pictures.layers`.
- Recipes use the 2.x ingredient/result format.
- `advanced-electronics` was removed in 2.0 and replaced with `advanced-circuit`.
- `create_entity()` no longer accepts `speed`; the atomic rocket is now spawned
  slightly away from the substation and its speed is assigned after creation.

## Credits

Original mod and assets: **Logvinov Alecksey**.
Factorio 2.1 port: **Azmandios**.

If you are the original author and want any part of this repository changed,
please open an issue.

---

## По-русски

Это порт мода **Triumph Substations** на Factorio 2.1.
Оригинальный автор — Логвинов Алексей (alecksey.com). Порт: Azmandios.

Готовый архив: `dist/TriumphSubstation_2.1.0.zip`.
Скопируйте его в `%APPDATA%\Factorio\mods` и включите мод в игре.

Другие моды не нужны, Space Age не обязателен.
Технические подробности порта — в [PORTING_NOTES.md](PORTING_NOTES.md).
