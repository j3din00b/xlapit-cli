#!/usr/bin/env bash
#set -e

######################################
# Author   :   DarkXero              #
# Website  :   http://xerolinux.xyz  #
######################################

# Set window title
echo -ne "\033]0;Gaming Tools\007"

# Function to display header
display_header() {
  clear
  gum style --foreground 212 --border double --padding "1 1" --margin "1 1" --align center "System Customization"
  echo
  gum style --foreground 141 "Hello $USER, please select an option. Press 'i' for the Wiki."
  echo
}
check_dependency() {
  local dependency=$1
  command -v $dependency >/dev/null 2>&1 || { echo >&2 "$dependency is not installed. Installing..."; sudo pacman -S --noconfirm $dependency; }
}

# Function to display header
display_header() {
  clear
  gum style --foreground 212 --border double --padding "1 1" --margin "1 1" --align center "Gaming Tools & Launchers"
  echo
  gum style --foreground 33 "Hello $USER, select what gaming software to install. Press 'i' for the Wiki."
  echo
}

# Function to install AUR packages
install_aur_packages() {
  $AUR_HELPER -S --noconfirm --needed "$@"
}

# Function to display options
display_options() {
  gum style --foreground 40 ".::: Main (Chaotic-AUR) :::."
  echo
  gum style --foreground 7 "1. Steam All-in-one."
  gum style --foreground 7 "2. Game Controllers."
  gum style --foreground 7 "3. LACT GPU-Overclock."
  echo
  gum style --foreground 226 ".::: Extras (Flatpaks) :::."
  echo
  gum style --foreground 7 "4. Heroic."
  gum style --foreground 7 "5. Lutris."
  gum style --foreground 7 "6. Bottles."
  gum style --foreground 7 "7. ProtonUp-QT."
}

# Function to handle errors and prompt user
handle_error() {
  echo
  gum style --foreground 196 "An error occurred. Would you like to retry or exit? (r/e)"
  read -rp "Enter your choice: " choice
  case $choice in
    r|R) exec "$0" ;;
    e|E) exit 0 ;;
    *) gum style --foreground 50 "Invalid choice. Returning to menu." ;;
  esac
  sleep 3
  clear && exec "$0"
}

# Function to handle Ctrl+C
handle_interrupt() {
  echo
  gum style --foreground 190 "Script interrupted. Do you want to exit or restart the script? (e/r)"
  read -rp "Enter your choice: " choice
  echo
  case $choice in
    e|E) exit 1 ;;
    r|R) exec "$0" ;;
    *) gum style --foreground 50 "Invalid choice. Returning to menu." ;;
  esac
  sleep 3
  clear && exec "$0"
}

# Trap errors and Ctrl+C
trap 'handle_error' ERR
trap 'handle_interrupt' SIGINT

# Function to display package selection dialog
package_selection_dialog() {
    local title=$1
    shift
    local options=("$@")
    PACKAGES=$(dialog --checklist "$title" 20 60 10 "${options[@]}" 3>&1 1>&2 2>&3)

    if [ -n "$PACKAGES" ]; then
        for PACKAGE in $PACKAGES; do
            case $PACKAGE in
                DualSense)
                    install_aur_packages dualsensectl game-devices-udev
                    sleep 3
                    echo "_:: Please follow guide on Github for configuration ::_"
                    sleep 3
                    xdg-open "https://github.com/nowrep/dualsensectl"  > /dev/null 2>&1
                    ;;
                DualShock4)
                    install_aur_packages ds4drv game-devices-udev
                    sleep 3
                    echo "_:: Please follow guide on Github for configuration ::_"
                    sleep 3
                    xdg-open "https://github.com/chrippa/ds4drv"  > /dev/null 2>&1
                    ;;
                XBoxOne)
                    install_aur_packages xone-dkms game-devices-udev
                    sleep 3
                    echo "_:: Please follow guide on Github for configuration ::_"
                    sleep 3
                    xdg-open "https://github.com/medusalix/xone"  > /dev/null 2>&1
                    ;;
                *)
                    echo "Unknown package: $PACKAGE"
                    ;;
            esac
        done
    else
        echo "No packages selected."
    fi
}

# Function to install gaming packages
install_gaming_packages() {
  case $1 in
    steam)
      sudo pacman -S --needed steam steam-native-runtime gamemode gamescope mangohud lib32-mangohud wine-meta wine-nine ttf-liberation lib32-fontconfig wqy-zenhei vkd3d giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses ocl-icd lib32-ocl-icd libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader cups dosbox lib32-opencl-icd-loader lib32-vkd3d opencl-icd-loader
      ;;
    bottles)
      flatpak install -y com.usebottles.bottles
      ;;
    heroic)
      flatpak install -y com.heroicgameslauncher.hgl
      ;;
    lutris)
      flatpak install -y net.lutris.Lutris
      ;;
    emulators)
      flatpak install -y org.libretro.RetroArch org.ppsspp.PPSSPP org.DolphinEmu.dolphin-emu org.flycast.Flycast org.pcsx2.PCSX2 flathub net.rpcs3.RPCS3
      ;;
    protonupQT)
      flatpak install -y net.davidotek.pupgui2
      ;;
    *)
      echo "Unknown package: $1"
      ;;
  esac
}

# Function to process user choice
process_choice() {
  while :; do
    echo
    read -rp "Enter your choice, or 'q' to return to main menu : " CHOICE
    echo

    case $CHOICE in
      i)
        gum style --foreground 33 "Opening Wiki..."
        sleep 3
        xdg-open "https://wiki.xerolinux.xyz/xlapit/#game-launchers" > /dev/null 2>&1
        clear && exec "$0"
        ;;
      1)
        gum style --foreground 7 "Installing Steam + Mangohud + Gamemode + Gamescope..."
        sleep 2
        echo
        install_gaming_packages steam
        sleep 3
        echo
        echo "Applying Download Speed Enhancement Patch..."
        [ ! -d ~/.local/share/Steam ] && mkdir -p ~/.local/share/Steam
        echo -e "@nClientDownloadEnableHTTP2PlatformLinux 0\n@fDownloadRateImprovementToAddAnotherConnection 1.0" > ~/.local/share/Steam/steam_dev.cfg
        sleep 3
        echo
        echo "Patching VM.Max.MapCount"
        echo
        echo "vm.max_map_count=2147483642" | sudo tee /etc/sysctl.d/99-sysctl.conf >/dev/null
        sleep 3
        gum style --foreground 7 "Steam installation complete!"
        sleep 3
        clear && exec "$0"
        ;;
      2)
        package_selection_dialog "Select Controller Driver to install:" \
        "DualSense" "DualSence Driver" OFF \
        "DualShock4" "DualShock 4 Driver" OFF \
        "XBoxOne" "XBOX One Controller Driver" OFF
        gum style --foreground 7 "Game Controller Drivers installation complete!"
        sleep 3
        clear && exec "$0"
        ;;
      3)
        gum style --foreground 7 "Installing LACT GPU OC Utility..."
        sleep 2
        echo
        install_aur_packages lact && sudo systemctl enable --now lactd
        echo
        gum style --foreground 7 "LACT GPU OC Utility installation complete!"
        sleep 3
        clear && exec "$0"
        ;;
      4)
        gum style --foreground 7 "Installing Heroic Games Launcher..."
        sleep 2
        echo
        install_gaming_packages heroic
        echo
        gum style --foreground 7 "Heroic Games Launcher installation complete!"
        sleep 3
        clear && exec "$0"
        ;;
      5)
        gum style --foreground 7 "Installing Lutris..."
        sleep 2
        echo
        install_gaming_packages lutris
        echo
        gum style --foreground 7 "Lutris installation complete!"
        sleep 3
        clear && exec "$0"
        ;;
      6)
        gum style --foreground 7 "Installing Bottles..."
        sleep 2
        echo
        install_gaming_packages bottles
        echo
        gum style --foreground 7 "Bottles installation complete!"
        sleep 3
        clear && exec "$0"
        ;;
      7)
        gum style --foreground 7 "Installing ProtonUp-QT..."
        sleep 2
        echo
        install_gaming_packages protonupQT
        echo
        gum style --foreground 7 "ProtonUp-QT installation complete!"
        sleep 3
        clear && exec "$0"
        ;;
      q)
        clear && exec xero-cli -m
        ;;
      *)
        gum style --foreground 50 "Invalid choice. Please select a valid option."
        echo
        ;;
    esac
    sleep 3
  done
}

# Main execution
display_header
display_options
process_choice
