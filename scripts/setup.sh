#!/bin/zsh

echo "Machine Setup"

echo ""

echo "Installing OS deps..."

echo ""

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	# Linux
	echo "Syncing Linux..."

	echo ""

	if [ "$(which dnf)" != "" ]; then
		echo "Syncing Fedora..."

		echo ""

		echo "Updating packages..."
		sudo dnf update

		echo ""

		echo "Installing repositories..."
		sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

		echo "Installing external repositories..."
		sudo dnf install dnf-plugins-core
		# Brave Browser
		sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
		sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
		#VSCode
		sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
		echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
		#NVM
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

		echo "Installing packages..."
		xargs sudo dnf install < ~/.dotfiles/deps/dnf.txt

		echo "Installing flatpak packages..."
		sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
		sudo flatpak update
		xargs sudo flatpak install -y < ~/.dotfiles/deps/flatpak.txt

		echo ""

		echo "Configuring some tools"
		# VSCode
		sudo chown -R $(whoami) /usr/share/code
	fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
	# Mac OSX
	echo "Syncing MacOS..."

	echo ""

	which -s brew
	if [[ $? != 0 ]]; then
		# Install Homebrew
		echo "Installing Homebrew..."
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	else
		echo "Homebrew is installed!"
		brew update
		brew upgrade
	fi

	echo ""

	# Install brew packages
	echo "Installing brew packages..."
	xargs brew install <~/.dotfiles/deps/brew.txt

	brew autoremove
	brew cleanup


	if [ "$(which mas)" != "" ]; then
		echo ""

		# Install mas apps
		echo "Installing mas apps from store..."
		xargs mas install <~/.dotfiles/deps/mas.txt

		if [ "$(which xcodebuild)" != "" ]; then
			sudo xcodebuild -license accept
		fi
	fi
fi

echo ""

~/.dotfiles/scripts/dotfiles.sh

echo ""

# OS agnostic commands

echo "Configuring tools..."

echo ""

# Install Node
echo "Install Node from NVM..."
cat ~/.nvmrc | xargs fnm install

echo ""

# Install global npm packages
echo "Installing global npm packages..."
cat ~/.dotfiles/deps/npm.txt | xargs npm install -g
# Enable pnpm
corepack enable

echo ""

# Install vscode-vscodium extensions

echo "Installing vscode-vscodium extensions..."
cat ~/.dotfiles/deps/vscodium.txt | xargs -n 1 codium --install-extension

# gh config

echo "Configuring gh..."

gh config set editor code

# gh aliases

gh alias delete --all

gh alias set notifications 'notify -sn 10'
gh alias set issues 'search issues --assignee=@me --state=open'
gh alias set prs 'search prs --assignee=@me --state=open'

# Install gh extensions

gh extension install meiji163/gh-notify

echo ""

echo "Done!"

echo ""

source ~/.zshrc