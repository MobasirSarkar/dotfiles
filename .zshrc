export LANG="en_US.UTF-8"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# yazi function
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# Starship & Zoxide
command -v starship >/dev/null && eval "$(starship init zsh)"
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# Syntax highlighting & autosuggestions
[ -f "$HOME/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
    source "$HOME/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[ -f "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
    source "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"

# PNPM
export PNPM_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"
[ -d "$PNPM_HOME" ] && case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Android SDK
export ANDROID_HOME="$HOME/Android/Sdk"
for p in emulator platform-tools; do
    [ -d "$ANDROID_HOME/$p" ] && PATH="$PATH:$ANDROID_HOME/$p"
done

# Editor
export EDITOR="nvim"

# Custom env
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# Go
export GOPATH="$HOME/go"
[ -d "$GOPATH" ] && PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"

# Tmux theme
export TMUX_THEME="nord"

