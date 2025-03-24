#!/bin/bash
# Arch Linux Install Script

# And then 3 interactive checklists:
#   1. Non-driver packages (AUR/official) via paru
#   2. Free driver packages via paru (preselected)
#   3. Flatpak apps from Flathub

# Ensure the script is run as root.
if [[ $EUID -ne 0 ]]; then
  echo "Please run as root"
  exit 1
fi

# Cache sudo credentials (will prompt once)
sudo -v

# Install essential packages: git and dialog
pacman -S --noconfirm git dialog

# Install paru (AUR helper) if not installed
if ! command -v paru &>/dev/null; then
  echo "paru not found, installing paru..."
  git clone https://aur.archlinux.org/paru.git /tmp/paru
  (cd /tmp/paru && makepkg -si --noconfirm)
fi

###############################################################################
# Paru Packages Section - Two Lists: Non-Drivers and Drivers
###############################################################################

# List 1: Non-driver packages (alphabetically sorted)
NON_DRIVER_PKGS=(
  "blender"                     "3D modeling and rendering"                     on
  "breaktimer-bin"		          "Manage periodic breaks"			                  on
  "docker"			                "Containers"					                          on
  "espeak-ng"                   "Text-to-speech engine"                         on
  "filelight"                   "Disk usage analyzer"                           on
  "flatpak"                     "Application sandboxing system"                 on
  "floorp-bin"                  "Unique browser (AUR)"                          on
  "github-cli"                  "GitHub command line tool"                      on
  "htop"                        "Interactive process viewer"                    on
  "krita"                       "Digital painting app"                          on
  "localsend-bin"		            "cross-platform alternative to AirDrop"		      on
  "mission-center"              "Task management"                               on
  "nano"                        "Simple text editor"                            on
  "okular"                      "Document viewer"                               on
  "ollama"                      "AI chat tool (AUR)"                            on
  "partitionmanager"            "Disk partition manager"                        on
  "prusa-slicer"                "Slicer for 3D printing"                        on
  "r2modman-bin"                "Game mod manager (AUR)"                        on
  "sddm"                        "Login manager"                                 on
  "sddm-theme-mountain-git"	    "SDDM mountain theme"				                    on
  "spotify"                     "Music streaming client"                        on
  "steam"                       "Gaming platform"                               on
  "solaar"                      "Logitech device manager"                       on
  "timeshift"                   "Backup solution"                               on
  "ufw"                         "Uncomplicated Firewall"                        on
  "vesktop-bin"                 "Desktop environment helper (AUR)"              on
  "visual-studio-code-bin"      "VS Code (AUR)"                                 on
  "vlc"                         "Media player"                                  on
)

# paru -S blender breaktimer-bin docker espeak-ng filelight flatpak floorp-bin github-cli htop krita localsend-bin mission-center nano okular ollama partitionmanager prusa-slicer r2modman-bin sddm-theme-mountain-git spotify steam solaar ufw vesktop-bin visual-studio-code-bin vlc timeshift 

# List 2: Driver packages (alphabetically sorted and preselected)
DRIVER_PKGS=(
  "intel-media-driver"          "Intel media driver"                            on
  "libva-intel-driver"          "VA API driver for Intel"                       on
  "libva-mesa-driver"           "VA API driver from Mesa"                       on
  "mesa"                        "Open-source OpenGL implementation"             on
  "vulkan-intel"                "Vulkan driver for Intel"                       on
  "vulkan-radeon"               "Vulkan driver for AMD"                         on
  "xf86-video-amdgpu"           "AMD GPU driver"                               	on
  "xf86-video-ati"              "ATI/AMD driver"                                on
  "xf86-video-nouveau"          "Nouveau driver for NVIDIA"                     on
  "xf86-video-vmware"           "VMware video driver"                           on
  "xorg-server"                 "X.Org server"                                  on
  "xorg-xinit"                  "X.Org X server utilities"                      on
)

# intel-media-driver libva-intel-driver libva-mesa-driver mesa vulkan-intel vulkan-radeon xf86-video-amdgpu xf86-video-ati xf86-video-nouveau xf86-video-vmware xorg-server xorg-xinit

# Display interactive checklist for Non-driver packages
NON_DRIVER_CHOICES=$(dialog --clear \
  --title "Select Non-driver Packages" \
  --checklist "Tick the packages you want to install:" 25 80 15 \
  "${NON_DRIVER_PKGS[@]}" \
  3>&1 1>&2 2>&3 3>&-)
clear

# Display interactive checklist for Driver packages
DRIVER_CHOICES=$(dialog --clear \
  --title "Select Free Driver Packages (Preselected)" \
  --checklist "Review driver packages:" 20 80 15 \
  "${DRIVER_PKGS[@]}" \
  3>&1 1>&2 2>&3 3>&-)
clear

# Combine selections from both lists (if any)
PARU_SELECTIONS="$NON_DRIVER_CHOICES $DRIVER_CHOICES"
if [ -z "$PARU_SELECTIONS" ]; then
  echo "No Paru packages selected."
else
  # Remove extra quotes and create a space-separated list
  PARU_LIST=$(echo $PARU_SELECTIONS | tr -d '"')
  echo "Installing the following packages via paru: $PARU_LIST"
  # Run paru as the invoking (non-root) user
  if [ -n "$SUDO_USER" ]; then
    sudo -u "$SUDO_USER" paru -S --noconfirm $PARU_LIST
  else
    paru -S --noconfirm $PARU_LIST
  fi
fi

###############################################################################
# Flatpak Apps Section
###############################################################################

# Add Flathub repository if not already added
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# List 3: Flatpak apps from Flathub (alphabetically sorted)
FLATPAK_APPS=(
  "com.github.tchx84.Flatseal"           "Flatseal (permissions manager)"     on
  "io.github.giantpinkrobots.flatsweep"   "Flatsweep (system cleanup)"        on
  "it.mijorus.gearlever"                  "GearLever (utility)"               on
  "net.lutris.Lutris"                     "Lutris (gaming platform)"          on
)

# Display interactive checklist for Flatpak apps
FLATPAK_CHOICES=$(dialog --clear \
  --title "Select Flatpak Apps from Flathub" \
  --checklist "Tick the Flatpak apps you want to install:" 15 80 4 \
  "${FLATPAK_APPS[@]}" \
  3>&1 1>&2 2>&3 3>&-)
clear

if [ -z "$FLATPAK_CHOICES" ]; then
  echo "No Flatpak apps selected."
else
  FLATPAK_LIST=$(echo $FLATPAK_CHOICES | tr -d '"')
  echo "Installing the following Flatpak apps: $FLATPAK_LIST"
  for app in $FLATPAK_LIST; do
    flatpak install -y flathub "$app"
  done
fi

###############################################################################
# Apply SDDM Theme and Cursor Theme Configurations
###############################################################################

# 1. SDDM configuration: Update /etc/sddm.conf.d/sddm.conf so that under the [Theme] section
#    the line 'Current=' is set to 'mountain' without overwriting the rest of the file.
SDDM_CONF="/etc/sddm.conf.d/sddm.conf"
if [ -f "$SDDM_CONF" ]; then
  # If the [Theme] section exists...
  if grep -q '^\[Theme\]' "$SDDM_CONF"; then
    # If a 'Current=' line exists within the [Theme] section, replace it.
    if sed -n '/^\[Theme\]/,/^\[/{/^[[:space:]]*Current=/p}' "$SDDM_CONF" | grep -q 'Current='; then
      sed -i '/^\[Theme\]/,/^\[/{s/^[[:space:]]*Current=.*/Current=mountain/}' "$SDDM_CONF"
    else
      # No Current line exists; insert it after the [Theme] header.
      sed -i '/^\[Theme\]/a Current=mountain' "$SDDM_CONF"
    fi
  else
    # If no [Theme] section exists, append it to the file.
    echo -e "\n[Theme]\nCurrent=mountain" >> "$SDDM_CONF"
  fi
else
  # If the file doesn't exist, create it.
  mkdir -p "$(dirname "$SDDM_CONF")"
  echo -e "[Theme]\nCurrent=mountain" > "$SDDM_CONF"
fi

# 2. Cursor theme configuration: Overwrite /usr/share/icons/default/index.theme
CURSOR_CONF="/usr/share/icons/default/index.theme"
echo -e "[Icon Theme]\nInherits=Bibata-Modern-Ice" > "$CURSOR_CONF"

###############################################################################
# Update Configuration Files: pacman.conf and paru.conf
###############################################################################

# Update /etc/pacman.conf: Set ParallelDownloads to 20
PACMAN_CONF="/etc/pacman.conf"
if grep -q "ParallelDownloads" "$PACMAN_CONF"; then
  # Replace both commented and uncommented lines with the desired value.
  sed -i 's/^[#]*\s*ParallelDownloads.*/ParallelDownloads = 20/' "$PACMAN_CONF"
else
  # If the setting doesn't exist, insert it under the [options] section.
  sed -i '/^\[options\]/a ParallelDownloads = 20' "$PACMAN_CONF"
fi

# Update /etc/paru.conf: Uncomment BottomUp
PARU_CONF="/etc/paru.conf"
if [ -f "$PARU_CONF" ]; then
  sed -i 's/^#\s*BottomUp/BottomUp/' "$PARU_CONF"
fi

echo "Installation complete!"
