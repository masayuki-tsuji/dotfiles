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
# https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
sed -i "" -r 's/^plugins=.*/plugins=(git docker-compose gh)/g' ~/.zshrc

# ===========================================================
# homebrew packages
# ===========================================================
installWithHomebrew() {
  local tool=$1
  local callbackArgs=$2
  brew list $tool 2>&1 1>/dev/null
  if [ $? -ne 0 ]; then
    brew install $tool
    if [ -n "$callbackArgs" ]; then
      echo 'export PATH="'"$callbackArgs"':$PATH"' >> ~/.zshrc
    fi
    echo "Info: Install $tool completed."
  else
    echo "Info: The OS already have $tool installed."
  fi
}

installWithHomebrewWithCaskOption() {
  local tool=$1
  local callbackArgs=$2
  brew list $tool 2>&1 1>/dev/null
  if [ $? -ne 0 ]; then
    brew install --cask $tool
    if [ -n "$callbackArgs" ]; then
      echo 'export PATH="'"$callbackArgs"':$PATH"' >> ~/.zshrc
    fi
    echo "Info: Install $tool completed."
  else
    echo "Info: The OS already have $tool installed."
  fi
}

# installWithHomebrew openjdk
# export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"

hash fnm 2>&1 1>/dev/null
if [ $? -ne 0 ]; then
  installWithHomebrew fnm
  echo 'eval "$(fnm env --use-on-cd)"' >> ~/.zshrc
fi

# Coreutils packages for Linux compatibility.
installWithHomebrew coreutils
installWithHomebrew mkcert
installWithHomebrew corepack

installWithHomebrew libpq "/opt/homebrew/opt/libpq/bin" # PostgreSQL
installWithHomebrew mysql-client

installWithHomebrew gh
installWithHomebrew act
installWithHomebrew jq
installWithHomebrew tree

installWithHomebrew codex
installWithHomebrew cloudflared
installWithHomebrew pulumi

# For external projects.
installWithHomebrew zstd
installWithHomebrew rbenv
installWithHomebrew certbot

corepack enable
echo "Info: Enable corepack completed."

## pnpm setup // it is a command.
## echo "Info: Setup pnpm."

# ===========================================================
# Project specific libs
# CDK required.
# ===========================================================
macArch="darwin_arm64" # NOTES: `uname` and `uname -m`
terraformVersion="1.5.3"
hash terraform 2>&1 1>/dev/null
if [ $? -ne 0 ]; then
  # https://developer.hashicorp.com/terraform/downloads
  curl https://releases.hashicorp.com/terraform/${terraformVersion}/terraform_${terraformVersion}_${macArch}.zip -o "terraform.zip"
  unzip terraform.zip
  chmod +x terraform
  sudo mv terraform /usr/local/bin
  rm -f terraform.zip
  echo "Info: Install terraform cli completed."
else
  echo "Info: The OS already have terraform cli installed."
fi

# ===========================================================
# Project specific libs
# Powerpoint required.
# ===========================================================
installWithHomebrew poppler

# ===========================================================
# Project specific libs
# AWS required.
# ===========================================================
installWithHomebrew awscli


hash session-manager-plugin 2>&1 1>/dev/null
if [ $? -ne 0 ]; then
  # https://docs.aws.amazon.com/ja_jp/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html#install-plugin-macos
  curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac_arm64/sessionmanager-bundle.zip" -o "sessionmanager-bundle.zip"
  unzip sessionmanager-bundle.zip
  sudo ./sessionmanager-bundle/install -i /usr/local/sessionmanagerplugin -b /usr/local/bin/session-manager-plugin
  rm -f install.sh sessionmanager-bundle.zip
  echo "Info: Install session-manager-plugin completed."
else
  echo "Info: The OS already have session-manager-plugin installed."
fi

# ===========================================================
# Project specific libs
# Google Cloud Platform required.
# ===========================================================
installWithHomebrewWithCaskOption google-cloud-sdk

cloudSqlProxyName=cloud_sql_proxy
cloudSqlProxyVersion=v1.33.6
hash $cloudSqlProxyName 2>&1 1>/dev/null
if [ $? -ne 0 ]; then
  curl -o $cloudSqlProxyName https://storage.googleapis.com/cloudsql-proxy/${cloudSqlProxyVersion}/cloud_sql_proxy.darwin.arm64
  chmod +x $cloudSqlProxyName
  sudo mv $cloudSqlProxyName /usr/local/bin
  echo "Info: Install $cloudSqlProxyName completed."
else
  echo "Info: The OS already have $cloudSqlProxyName installed."
fi

hash firebase 2>&1 1>/dev/null
if [ $? -ne 0 ]; then
  curl -sL https://firebase.tools | bash
  echo "Info: Install firebase completed."
else
  echo "Info: The OS already have firebase installed."
fi

# ===========================================================
# Project specific libs
# Python required.
# ===========================================================
curl -LsSf https://astral.sh/uv/install.sh | sh # python version manager (pyenv + venv = uv)


echo "Info: Install completed."
exit 0
