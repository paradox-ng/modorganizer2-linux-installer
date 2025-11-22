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
		log_info "game not found in '$libdir'"
	fi
done < <("$script_root/list-steam-libraries.sh")
exit 1
