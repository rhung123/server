#!/usr/bin/env bash

set -euo pipefail

MC_VERSION="1.20.1"
FORGE_VERSION="47.4.16"
FORGE_INSTALLER="forge-${MC_VERSION}-${FORGE_VERSION}-installer.jar"

SERVER_DIR="moniserver"

#############################################

# Fetch server build from GitHub Actions

#############################################

echo "==> Fetching server build from GitHub Actions"
./fetch_server_build.sh .

if [[ ! -f server.zip ]]; then
echo "ERROR: server.zip not found after fetch."
exit 1
fi

#############################################

# Validate Forge installer exists

#############################################

if [[ ! -f "$FORGE_INSTALLER" ]]; then
echo "ERROR: $FORGE_INSTALLER not found."
echo "Download it from:"
echo "https://files.minecraftforge.net/net/minecraftforge/forge/index_1.20.1.html"
exit 1
fi

#############################################

# Create server directory

#############################################

echo "==> Creating $SERVER_DIR"
mkdir -p "$SERVER_DIR"

echo "==> Copying install artifacts"
cp -f server.zip "$SERVER_DIR/"
cp -f "$FORGE_INSTALLER" "$SERVER_DIR/"

cd "$SERVER_DIR"

#############################################

# Install Forge

#############################################

echo "==> Installing Forge server"
java -jar "$FORGE_INSTALLER" --installServer

#############################################

# Unzip Monifactory server

#############################################

echo "==> Unzipping server.zip"
unzip -o server.zip

#############################################

# First run (generate eula.txt)

#############################################

echo "==> Running server once"
./run.sh || true

#############################################

# Accept EULA

#############################################

if [[ -f eula.txt ]]; then
echo "==> Accepting EULA"
sed -i.bak 's/^eula=false$/eula=true/' eula.txt
rm -f eula.txt.bak
fi

#############################################

# Second run (initialize)

#############################################

echo "==> Starting server again"
./run.sh || true

echo "Stop the server with /stop before continuing."

#############################################

# Add spark

#############################################

if [[ -f ../spark-1.10.53-forge.jar ]]; then
echo "==> Installing spark mod"
cp -f ../spark-1.10.53-forge.jar mods/
fi

#############################################

# Set pack mode to Expert

#############################################

echo "==> Setting Expert mode"
java -jar mods/monilabs-*.jar E

#############################################

# Remove generated default world

#############################################

echo "==> Removing generated world"
rm -rf world

#############################################

# Cleanup install artifacts

#############################################

echo "==> Cleaning up installer artifacts"
rm -f "$FORGE_INSTALLER"
rm -f "$FORGE_INSTALLER.log"
rm -f server.zip

#############################################

# Final step

#############################################

echo "==> Installation complete"
