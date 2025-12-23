#!/bin/bash

set -e

REPO="brrock/trash-cli"
RELEASE_TAG="${1:-latest}"

echo "Installing Trash CLI..."

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$OS" in
  linux)
    TARGET="bun-linux-x64"
    INSTALL_DIR="/usr/local/bin"
    ;;
  darwin)
    case "$ARCH" in
      arm64)
        TARGET="bun-darwin-arm64"
        ;;
      x86_64)
        TARGET="bun-darwin-x64"
        ;;
      *)
        echo "❌ Unsupported architecture: $ARCH"
        exit 1
        ;;
    esac
    INSTALL_DIR="/usr/local/bin"
    ;;
  *)
    echo "❌ Unsupported OS: $OS"
    exit 1
    ;;
esac

BINARY_NAME="cli-${TARGET}"
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${RELEASE_TAG}/${BINARY_NAME}"

echo "📦 Downloading for ${TARGET}..."
curl -L "${DOWNLOAD_URL}" -o /tmp/${BINARY_NAME}

chmod +x /tmp/${BINARY_NAME}

if [ -w "${INSTALL_DIR}" ]; then
  mv /tmp/${BINARY_NAME} "${INSTALL_DIR}/trash-cli"
  echo "✅ Installed to ${INSTALL_DIR}/trash-cli"
else
  echo "📍 Need sudo to install to ${INSTALL_DIR}"
  sudo mv /tmp/${BINARY_NAME} "${INSTALL_DIR}/trash-cli"
  echo "✅ Installed to ${INSTALL_DIR}/trash-cli"
fi

echo "🎉 Installation complete! Run 'trash-cli --help' to get started."