MOD_NAME := $(shell python3 -c 'import json; print(json.load(open("info.json"))["name"])')
MOD_VERSION := $(shell python3 -c 'import json; print(json.load(open("info.json"))["version"])')
FACTORIO_MODS ?= $(HOME)/Library/Application Support/factorio/mods
FACTORIO_BIN ?= $(HOME)/Library/Application Support/Steam/steamapps/common/Factorio/factorio.app/Contents/MacOS/factorio

.PHONY: check build test install publish release clean

check:
	@python3 tools/check.py

build:
	@bash scripts/build.sh

# Сборка + headless проверка прототипов и атомного взрыва.
test:
	@FACTORIO_BIN="$(FACTORIO_BIN)" FACTORIO_MODS="$(FACTORIO_MODS)" bash scripts/test.sh

install: build
	rm -rf "$(FACTORIO_MODS)/$(MOD_NAME)_$(MOD_VERSION)"
	unzip -qo "dist/$(MOD_NAME)_$(MOD_VERSION).zip" -d "$(FACTORIO_MODS)"
	@echo "Установлено в $(FACTORIO_MODS)/$(MOD_NAME)_$(MOD_VERSION)"

# Релиз: bump версии + changelog + коммит + тег + сборка.
# Пример: make release BUMP=patch CHANGES="Исправить рецепт"
release:
	@bash scripts/release.sh "$(BUMP)" "$(CHANGES)"

# Публикация собранного релиза (токен: MOD_PORTAL_TOKEN или .mod-portal-token).
publish:
	@bash scripts/publish.sh

clean:
	rm -rf dist
