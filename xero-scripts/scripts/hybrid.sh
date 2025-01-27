#!/usr/bin/env bash

# Function to check for dual GPU
check_dual_gpu() {
    if lspci | grep -E "VGA|3D" | grep -q "NVIDIA" && lspci | grep -E "VGA|3D" | grep -q "Intel"; then
        echo "Intel/NVIDIA"
        return 0
    elif lspci | grep -E "VGA|3D" | grep -q "NVIDIA" && lspci | grep -E "VGA|3D" | grep -q "AMD"; then
        echo "NVIDIA/AMD"
        return 0
    else
        echo "None"
        return 1
    fi
}

# Function to install common packages
install_common_packages() {
    sudo pacman -S --needed --noconfirm vulkan-icd-loader lib32-vulkan-icd-loader
}

# Function to install NVIDIA and Intel drivers
install_nvidia_intel() {
    local driver_type=$1
    install_common_packages
    if [ "$driver_type" = "closed" ]; then
        sudo pacman -S --needed --noconfirm linux-headers nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings egl-wayland opencl-nvidia lib32-opencl-nvidia libvdpau-va-gl libvdpau ennycontrol
    else
        sudo pacman -S --needed --noconfirm linux-headers nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings egl-wayland opencl-nvidia lib32-opencl-nvidia libvdpau-va-gl libvdpau ennycontrol
    fi
    sudo pacman -S --needed --noconfirm mesa lib32-mesa vulkan-intel lib32-vulkan-intel intel-media-driver intel-gmmlib onevpl-intel-gpu gstreamer-vaapi intel-gmmlib
}

# Function to install NVIDIA and AMD drivers
install_nvidia_amd() {
    local driver_type=$1
    install_common_packages
    if [ "$driver_type" = "closed" ]; then
        sudo pacman -S --needed --noconfirm linux-headers nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings egl-wayland opencl-nvidia lib32-opencl-nvidia libvdpau-va-gl libvdpau
    else
        sudo pacman -S --needed --noconfirm linux-headers nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings egl-wayland opencl-nvidia lib32-opencl-nvidia libvdpau-va-gl libvdpau
    fi
    sudo pacman -S --needed --noconfirm mesa xf86-video-amdgpu lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-mesa-layers lib32-vulkan-mesa-layers
}

# Check if running on Arch Linux or compatible
if ! command -v pacman &> /dev/null; then
    echo "This script is designed for Arch Linux and compatible distributions."
    exit 1
fi

# Check for sudo privileges
if ! sudo -v; then
    echo "You need sudo privileges to run this script."
    exit 1
fi

# Check if gum is installed (for styling output)
if ! command -v gum &> /dev/null; then
    echo "gum is not installed. Installing gum..."
    sudo pacman -S --needed --noconfirm gum
fi

# Detect GPU configuration
gpu_config=$(check_dual_gpu)

# Show the user what GPU combo was detected (or if none)
if [ "$gpu_config" = "Intel/NVIDIA" ]; then
    echo
    gum style --foreground 33 "Detected GPU configuration: Intel/NVIDIA"
elif [ "$gpu_config" = "NVIDIA/AMD" ]; then
    echo
    gum style --foreground 196 "Detected GPU configuration: NVIDIA/AMD"
else
    echo
    gum style --foreground 196 "No dual GPU configuration detected."
    exit 1
fi

# Only proceed if a valid dual GPU configuration was detected
if [ "$gpu_config" = "Intel/NVIDIA" ] || [ "$gpu_config" = "NVIDIA/AMD" ]; then
    # Prompt the user to confirm if it's okay to proceed
    while true; do
        read -p "Do you want to proceed with the driver installation? (y/n): " proceed_choice
        proceed_choice=$(echo "$proceed_choice" | tr '[:upper:]' '[:lower:]')
        if [ "$proceed_choice" = "y" ]; then
            break
        elif [ "$proceed_choice" = "n" ]; then
            echo
            echo "Driver installation canceled."
            exit 0
        else
            echo "Invalid input. Please enter 'y' or 'n'."
        fi
    done

    # Proceed with driver installation based on GPU configuration
    if [ "$gpu_config" = "Intel/NVIDIA" ]; then
        gum style --foreground 33 "Intel/NVIDIA detected. Setup should work for most."
        echo
        while true; do
            read -p "Do you want (C)losed or (O)pen drivers? (c/o): " driver_choice
            driver_choice=$(echo "$driver_choice" | tr '[:upper:]' '[:lower:]')
            if [ "$driver_choice" = "c" ]; then
                install_nvidia_intel "closed"
                break
            elif [ "$driver_choice" = "o" ]; then
                install_nvidia_intel "open"
                break
            else
                echo
                echo "Invalid input. Please choose 'c' or 'o'."
            fi
        done
    elif [ "$gpu_config" = "NVIDIA/AMD" ]; then
        gum style --foreground 196 "NVIDIA/AMD detected. Setup should work for most."
        echo
        while true; do
            read -p "Do you want (C)losed or (O)pen drivers? (c/o): " driver_choice
            driver_choice=$(echo "$driver_choice" | tr '[:upper:]' '[:lower:]')
            if [ "$driver_choice" = "c" ]; then
                install_nvidia_amd "closed"
                break
            elif [ "$driver_choice" = "o" ]; then
                install_nvidia_amd "open"
                break
            else
                echo
                echo "Invalid input. Please choose 'c' or 'o'."
            fi
        done
    fi

    # Reboot prompt
    while true; do
        read -p "A reboot is required. Do you want to reboot now? (y/n): " reboot_choice
        reboot_choice=$(echo "$reboot_choice" | tr '[:upper:]' '[:lower:]')
        if [ "$reboot_choice" = "y" ]; then
            sudo reboot
            break
        elif [ "$reboot_choice" = "n" ]; then
            echo
            echo "Please remember to reboot your system to apply the changes."
            break
        else
            echo
            echo "Invalid input. Please enter 'y' or 'n'."
        fi
    done
fi
