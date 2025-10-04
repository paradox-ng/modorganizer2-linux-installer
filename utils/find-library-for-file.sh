#!/usr/bin/env bash

if [ -n "$STEAM_LIBRARY" ]; then
	echo "$STEAM_LIBRARY"
	exit 0
fi

function log_info() {
	echo "INFO:" "$@" >&2
}

function log_error() {
	echo "ERROR:" "$@" >&2
}

script_root=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

while read -r libdir; do
	full_path="$libdir/steamapps/common/$game_steam_subdirectory/$game_executable"

	if [ -f "$full_path" ]; then
		log_info "game found in '$libdir'"
		echo "$libdir"
		exit 0
	else
		## Fallout 3 Downgrade Check
		if { [ "$game_appid" -eq 22300 ] || [ "$game_appid" -eq 22370 ]; } &&
			[ -f "$libdir/steamapps/common/$game_steam_subdirectory/Fallout3Launcher.exe" ]; then
			log_error "Fallout 3 and Fallout 3 GOTY require the game version to be downgraded. Instructions have been provided in the GitHub Wiki."

			"$dialog" errorbox \
				"Fallout 3 and Fallout 3 GOTY require the game version to be downgraded.\n\nInstructions have been provided in the GitHub Wiki."
			exit 2
		fi
		log_info "game not found in '$libdir'"
	fi
done < <("$script_root/list-steam-libraries.sh")
exit 1
