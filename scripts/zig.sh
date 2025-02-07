#!/bin/bash

set -e

INSTALL_DIR="$HOME/.local/zig"
mkdir -p "$INSTALL_DIR"

ZIG_LATEST_URL=$(curl -s https://ziglang.org/download/index.json | jq -r '."0.13.0" | ."x86_64-linux".tarball')
ZIG_TARBALL=$(basename "$ZIG_LATEST_URL")

cd "$INSTALL_DIR"
curl -LO "$ZIG_LATEST_URL"
tar -xf "$ZIG_TARBALL" --strip-components=1
rm "$ZIG_TARBALL"

ZLS_LATEST_URL=$(curl -s https://api.github.com/repos/zigtools/zls/releases/tags/0.13.0 | jq -r '.assets[] | select(.name | test("linux.*x86_64.tar.gz$")) | .browser_download_url')
ZLS_TARBALL=$(basename "$ZLS_LATEST_URL")

curl -LO "$ZLS_LATEST_URL"
tar -xf "$ZLS_TARBALL" --strip-components=1
rm "$ZLS_TARBALL"

if ! grep -q 'export PATH="$HOME/.local/zig:$PATH"' "$HOME/.zshrc"; then
    echo 'export PATH="$HOME/.local/zig:$PATH"' >> "$HOME/.zshrc"
fi


export PATH="$HOME/.local/zig:$PATH"
echo "Zig 0.13.0 and ZLS 0.13.0 have been installed in $INSTALL_DIR and added to PATH. Restart your shell or run 'source ~/.zshrc' to apply changes."
