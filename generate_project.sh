#!/bin/bash
set -e

echo "Installing XcodeGen..."

# Download XcodeGen binary
XCODEGEN_VERSION="2.38.0"
XCODEGEN_URL="https://github.com/yonaskolb/XcodeGen/releases/download/${XCODEGEN_VERSION}/xcodegen.zip"

cd /tmp
curl -L -o xcodegen.zip "$XCODEGEN_URL"
unzip -o xcodegen.zip
chmod +x xcodegen
sudo mv xcodegen /usr/local/bin/ || mv xcodegen /workspace/

# Generate Xcode project
cd /workspace/IndustrialConfigurator

if [ -f "/usr/local/bin/xcodegen" ]; then
    /usr/local/bin/xcodegen generate
elif [ -f "/workspace/xcodegen" ]; then
    /workspace/xcodegen generate
else
    echo "XcodeGen installation failed"
    exit 1
fi

echo "Xcode project generated successfully!"
