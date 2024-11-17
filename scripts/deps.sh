sudo pacman -Syu


sudo pacman -Sy --needed base-devel gcc clang llvm rustup  libxau libxi libxss libxtst libxcursor libxcomposite libxdamage libxfixes libxrandr libxrender mesa-libgl alsa-lib libglvnd

sudo pacman -Sy --needed grub efibootmgr networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools base-devel linux-headers avahi xdg-user-dirs xdg-utils gvfs gvfs-smb nfs-utils inetutils dnsutils bluez bluez-utils cups hplip alsa-utils  bash-completion openssh rsync virt-manager qemu bridge-utils dnsmasq vde2 openbsd-netcat  ipset  sof-firmware nss-mdns acpid os-prober ntfs-3g 


rustup toolchain add stable

mkdir -p ~/sources/

cd ~/sources/

git clone https://aur.archlinux.org/paru.git

cd paru

makepkg -si

paru -S docker minikube kubectl zig zls  qbittorrent pyenv git python-pip python-pipx python-pipenv python-poetry google-chrome nvm deno zola bun heroku-cli-bin pnpm obsidian freedownloadmanager signal-desktop onedrive-abraunegg spotify  visual-studio-code-bin  rustup go tor torbrowser-launcher gimp kdenlive github-cli postman-bin vlc firefox media-downloader postgresql mongodb-bin mongodb-compass wps-office wps-office-mime wps-office-fonts ttf-wps-fonts