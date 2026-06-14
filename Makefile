.DEFAULT_GOAL := help

INIT_FILE    := init.lua
PLUGINS_FILE := plugins.lua

NVIM_LOCAL_SHARE_DIR := ~/.local/share/nvim
NVIM_CONFIG_DIR      := ~/.config/nvim
LUA_CONFIG_DIR       := $(NVIM_CONFIG_DIR)/lua

.PHONY: help
help:
	@grep '^.PHONY: .* #' Makefile | sed 's/\.PHONY: \(.*\) # \(.*\)/\1 $(shell echo "\t") \2/' | sort | expand -t20

.PHONY: install # Install neovim and plugins
install:
	@echo "→ Installing neovim"
	@if [ "$$(uname)" = "Darwin" ]; then \
		brew upgrade nvim || brew install nvim; \
	elif command -v pacman >/dev/null 2>&1; then \
		sudo pacman -S --needed --noconfirm neovim; \
	else \
		echo "Unsupported OS: install neovim manually"; exit 1; \
	fi
	@echo "→ Symlinking"
	mkdir -p $(LUA_CONFIG_DIR)
	ln -nfs $(shell pwd)/$(PLUGINS_FILE) $(LUA_CONFIG_DIR)/$(PLUGINS_FILE)
	ln -nfs $(shell pwd)/$(INIT_FILE) $(NVIM_CONFIG_DIR)/$(INIT_FILE)
	@echo "→ Installing plugins"
	nvim --headless '+Lazy! sync' +qa

.PHONY: remove # Remove distribution
remove:
	@echo "→ Removing neovim"
	@if [ "$$(uname)" = "Darwin" ]; then \
		brew uninstall nvim; \
	elif command -v pacman >/dev/null 2>&1; then \
		sudo pacman -Rns --noconfirm neovim; \
	else \
		echo "Unsupported OS: remove neovim manually"; exit 1; \
	fi
	@echo "→ Removing plugins"
	rm -rf $(NVIM_CONFIG_DIR)
	rm -rf $(NVIM_LOCAL_SHARE_DIR)
