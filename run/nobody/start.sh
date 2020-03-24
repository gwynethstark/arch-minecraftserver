#!/bin/bash

# if forge folder doesnt exist then copy default to host config volume
if [ ! -d "/config/forge" ]; then

	echo "[info] forge folder doesnt exist, copying default to '/config/forge/'..."

	mkdir -p /config/forge
	if [[ -d "/srv/forge" ]]; then
		cp -R /srv/forge/* /config/forge/ 2>/dev/null || true
	fi

else

	echo "[info] Forge folder '/config/forge' already exists, rsyncing newer files..."
	rsync -rltp --exclude 'world' --exclude '/server.properties' --exclude '/*.json' /srv/forge/ /config/forge

fi

if [ ! -f /config/forge/eula.txt ]; then

	echo "[info] Starting Java (forge) process to force creation of eula.txt..."
	/usr/bin/forged start

	echo "[info] Waiting for Forge Java process to abort (expected, due to eula flag not set)..."
	while pgrep -fa "java" > /dev/null; do
		sleep 0.1
	done
	echo "[info] Forge Java process ended"

	echo "[info] Setting EULA to true..."
	sed -i -e 's~eula=false~eula=true~g' '/config/forge/eula.txt'
	echo "[info] EULA set to true"

fi

echo "[info] Starting Forge Java process..."
/usr/bin/forged start
echo "[info] Forge Java process started, successful start"

# /usr/bin/forged is dameonised, thus we need to run something in foreground to prevent exit of script
cat