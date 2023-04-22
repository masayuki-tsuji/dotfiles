#/bin/bash -f

# Warning!! This shell needs to implemented with idempotency in mind.

cd ~

# ===========================================================
# Homebrew
# ===========================================================
which brew 2>&1 1>/dev/null
if [ $? -ne 0 ]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Homebrew settings for only Apple Silicon.
  echo 'export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"' >> ~/.zshrc

  echo "Info: Install homebrew completed."
else
  echo "Info: The OS already have homebrew installed."
fi

# ===========================================================
# oh-my-zsh
# ===========================================================
# Install oh-my-zsh tools.
if [ ! -d ~/.oh-my-zsh ]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  if [ $? -ne 0 ]; then
    echo "Error: failed to install oh-my-zsh."
    exit 1
  fi
  echo "Info: Install oh-my-zsh completed."
else
  echo "Info: The OS already have oh-my-zsh installed."
fi

# Set oh-my-zsh theme.
sed -i "" -r 's/^ZSH_THEME=.*/ZSH_THEME="ys"/g' ~/.zshrc

# Set oh-my-zsh plugins.
sed -i "" -r 's/^plugins=.*/plugins=(git docker-compose)/g' ~/.zshrc

# ===========================================================
# volta
# ===========================================================
hash volta 2>&1 1>/dev/null
if [ $? -ne 0 ]; then
  curl https://get.volta.sh | bash -s -- --skip-setup 
  echo 'export VOLTA_HOME="$HOME/.volta"' >> ~/.zshrc
  echo 'export PATH="$PATH:$VOLTA_HOME/bin"' >> ~/.zshrc
  echo "Info: Install volta completed."
else
  echo "Info: The OS already have volta installed."
fi

# ===========================================================
# homebrew packages
# ===========================================================
installWithHomebrew() {
  local tool=$1
  local callbackArgs=$2
  brew list | grep -q $tool 2>&1 1>/dev/null
  if [ $? -ne 0 ]; then
    brew install $tool
    if [ -n $callbackArgs ]; then
      echo 'export PATH="'"$callbackArgs"':$PATH"' >> ~/.zshrc
    fi
    echo "Info: Install $tool completed."
  else
    echo "Info: The OS already have $tool installed."
  fi
}

installWithHomebrew pnpm
installWithHomebrew awscli
installWithHomebrew libpq "/opt/homebrew/opt/libpq/bin"

echo "Info: Install completed."
exit 0
