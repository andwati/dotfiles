echo "### updating the system ###"
sudo paru -Syu --noconfirm

echo "### installing dependencies ###"
paru -S gdb ninja gcc cmake sddm dunst polkit-kde-agent qt5-wayland qt6-wayland  meson libxcb xcb-proto xcb-util xcb-util-keysyms libxfixes libx11 libxcomposite xorg-xinput libxrender pixman wayland-protocols cairo pango seatd libxkbcommon xcb-util-wm xorg-xwayland libinput libliftoff libdisplay-info cpio tomlplusplus hyprlang hyprcursor hyprwayland-scanner xcb-util-errors

echo "### building hyprland ###"
git clone --recursive https://github.com/hyprwm/Hyprland
cd Hyprland
make all && sudo make install
