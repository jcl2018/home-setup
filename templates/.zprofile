if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if [ -f "$HOME/.config/home-setup/secrets.zsh" ]; then
  . "$HOME/.config/home-setup/secrets.zsh"
fi
