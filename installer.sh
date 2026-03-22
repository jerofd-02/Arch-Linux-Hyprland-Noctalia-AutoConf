#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_packages() {
    for pkg in "$@"; do
        if pacman -Qq "$pkg" &>/dev/null; then
            echo "'$pkg' is already installed."
        else
            echo "Installing '$pkg'..."
            sudo pacman -S --needed --noconfirm "$pkg" 
        fi
    done
}

install_aur_packages() {
    for pkg in "$@"; do
        if paru -Qq "$pkg" &>/dev/null; then
            echo "'$pkg' is already installed."
        else
            echo "Installing '$pkg'..."
            paru -S --needed --noconfirm "$pkg"
        fi
    done
}

deploy_config() {
    local configs=(
        "gtk-3.0"
        "gtk-4.0"
        "hypr"
        "kitty"
        "noctalia"
        "nwg-look"
        "qt5ct"
        "qt6ct"
        "xsettingsd"
    )

    local src dst
    for cfg in "${configs[@]}"; do
        src="$SCRIPT_DIR/config/$cfg"
        dst="$HOME/.config/$cfg"

        if [[ -d "$src" ]]; then
            echo "Deploying '$cfg'..."
            mkdir -p "$dst"
            cp -r "$src/." "$dst/"
        else
            echo "Warning: '$cfg' not found, skipping."
        fi
    done
}

# Essential packages to install hyprland, according to archinstall
install_packages dolphin dunst grim htop hyprland iwd kitty nano \
	openssh polkit-kde-agent qt5-wayland qt6-wayland slurp \
	smartmontools uwsm vim wget wireless_tools wofi \
	xdg-desktop-portal-hyprland xdg-utils

# Another essential packages to install to do a full installation
install_packages cliphist git sddm xdg-user-dirs

# Configuration to launch the GUI automatically on every reboot
systemctl enable sddm.service
systemctl set-target graphical.target

# Configuration to update user dirs
xdg-user-dirs-update

# Essential packages to install paru (https://github.com/Morganamilo/paru)
install_packages base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

# Essential packages to install notctalia-shell
install_aur_packages noctalia-shell

# Essential packages to change interface settings of GTK and QT applications
install_aur_packages adw-gtk-theme nwg-look qt6ct-kde

# Install zsh packages to change bash
install_packages zsh zsh-completions

# Papirus icon theme and Notwaita Cursor
install_packages papirus-icon-theme 
install_aur_packages notwaita-cursor-theme

# Copy the custom config in ~/.config directory
deploy_config

# Custom themes of zsh (https://github.com/ohmyzsh/ohmyzsh.git)
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

# ssdm lock screen with Noctalia-inspired theme (https://github.com/mda-dev/noctalia-sddm-theme)
cd ..
git clone https://github.com/mda-dev/noctalia-sddm-theme.git noctalia
cd noctalia
chmod u+x /installer/install.sh
sudo ./installer/install.sh

# Custom config of zsh
cp $SCRIPT_DIR/config/zshenv $HOME/.zshenv
cp $SCRIPT_DIR/config/zshrc $HOME/.zshrc
chsh -s $(which zsh)