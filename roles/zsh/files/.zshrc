export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="crcandy"

zstyle ':omz:update' mode auto # update automatically without asking
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(git 1password aliases aws zsh-autosuggestions zsh-syntax-highlighting cd-ls artisan laravel-sail)

source $ZSH/oh-my-zsh.sh

alias sail=vendor/bin/sail
alias cw=cargo watch -q -c -x run -w
export SSH_AUTH_SOCK=~/.1password/agent.sock

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
# place this after nvm initialization!
autoload -U add-zsh-hook

load-nvmrc() {
  local nvmrc_path
  nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version
    nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
      nvm use
    fi
  elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}

add-zsh-hook chpwd load-nvmrc
load-nvmrc

export PATH="$PATH:$HOME/.local/bin"
### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="$HOME/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export FLYCTL_INSTALL="$HOME/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"
# eval "$(zellij setup --generate-auto-start zsh)"

alias ct='bat --paging=never'
alias dotfiles="$HOME/.dotfiles/bin/dotfiles"
alias gbc="better-commits"
alias ng="ngrok http --domain=complete-marten-moved.ngrok-free.app "

eval "$(atuin init zsh)"
eval "$(op completion zsh)"
compdef _op op
eval "$(zoxide init zsh)"

export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"
export PATH="/opt/homebrew/opt/ansible@8/bin:$PATH"

export ARTISAN_OPEN_ON_MAKE_EDITOR=code

#sail AlIASES
alias smig="sail artisan migrate"
alias sseed="sail artisan db:seed"
alias sart="sail artisan"
alias ar="artisan"

#fzf
source <(fzf --zsh)
