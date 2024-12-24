echo "Upgrade sources..."
winget source update

echo "Install from $env:USERPROFILE\.dotfiles\deps\winget.json..."
winget import "$env:USERPROFILE\.dotfiles\deps\winget.json" --accept-source-agreements --accept-package-agreements

echo "Upgrade all.."
winget upgrade --all

echo "Setting dotfiles..."
~/.dotfiles/scripts/dotfiles.ps1

echo "Configuring tools..."

echo "Installing vscode-vscodium extensions..."
cat ~/.dotfiles/deps/vscodium.txt | ForEach-Object { codium --install-extension $_ }

echo "Installing Node..."
fnm install $(cat ~/.node-version)
fnm use $(cat ~/.node-version)

echo "installing NPM packages..."
cat ~/.dotfiles/deps/npm.txt | ForEach-Object { npm install -g $_ }

echo "Installing wsl..."
~/.dotfiles/scripts/wsl.ps1