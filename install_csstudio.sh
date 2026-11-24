#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="/opt/phoebus"
REPO="ControlSystemStudio/phoebus"

if [[ "$(uname -m)" != "x86_64" ]]; then
    echo "ERROR: This installer requires x86-64 Linux."
    exit 1
fi

echo "==> Installing system dependencies"

sudo apt-get update

sudo apt-get install -y \
    openjdk-21-jdk \
    curl \
    wget \
    unzip \
    jq \
    libgtk-3-0 \
    libgl1 \
    libasound2t64 \
    ca-certificates

echo "==> Checking Java installation"

/usr/lib/jvm/java-21-openjdk-amd64/bin/java -version

echo "==> Finding latest stable Phoebus release"

RELEASE_JSON=$(curl -fsSL \
    "https://api.github.com/repos/${REPO}/releases/latest")

VERSION=$(echo "$RELEASE_JSON" | jq -r '.tag_name')

DOWNLOAD_URL=$(echo "$RELEASE_JSON" | jq -r '
    [.assets[]
    | select(.name | test("^phoebus.*linux.*\\.zip$"; "i"))
    | select(.name | test("target|aarch64|arm64"; "i") | not)]
    | first
    | .browser_download_url // empty
')

if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "ERROR: No suitable Linux binary found."
    exit 1
fi

echo "Release: $VERSION"
echo "Download: $DOWNLOAD_URL"

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo "==> Downloading Phoebus"

wget -O "$TMP_DIR/phoebus.zip" "$DOWNLOAD_URL"

echo "==> Extracting Phoebus"

mkdir "$TMP_DIR/extracted"
unzip -q "$TMP_DIR/phoebus.zip" -d "$TMP_DIR/extracted"

LAUNCHER=$(find "$TMP_DIR/extracted" \
    -type f -name phoebus.sh -print -quit)

if [[ -z "$LAUNCHER" ]]; then
    echo "ERROR: Could not locate phoebus.sh."
    exit 1
fi

SOURCE_DIR=$(dirname "$LAUNCHER")
VERSION_DIR="$INSTALL_DIR/$VERSION"

echo "==> Installing into $VERSION_DIR"

sudo mkdir -p "$VERSION_DIR"
sudo cp -a "$SOURCE_DIR/." "$VERSION_DIR/"
sudo chmod +x "$VERSION_DIR/phoebus.sh"

# Point to the installed version
sudo ln -sfn "$VERSION_DIR" "$INSTALL_DIR/current"

echo "==> Creating command-line launcher"

sudo tee /usr/local/bin/phoebus > /dev/null <<'EOF'
#!/usr/bin/env bash

export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"

exec /opt/phoebus/current/phoebus.sh "$@"
EOF

sudo chmod +x /usr/local/bin/phoebus

echo "==> Creating desktop launcher"

sudo tee /usr/share/applications/phoebus.desktop > /dev/null <<'EOF'
[Desktop Entry]
Name=CS-Studio Phoebus
Comment=EPICS Control System Studio
Exec=/usr/local/bin/phoebus
Icon=applications-science
Terminal=false
Type=Application
Categories=Science;Engineering;
EOF

echo
echo "========================================"
echo "Phoebus installation complete"
echo "Version: $VERSION"
echo "Location: $VERSION_DIR"
echo "Start using: phoebus"
echo "========================================"
