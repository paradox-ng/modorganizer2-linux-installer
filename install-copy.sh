#!/usr/bin/env bash

cache_enabled="${CACHE:-1}"

set -eu
set -o pipefail

script_root=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
#log_datetime=$(date +"%Y%m%d_%H%M%S")
#log_file="$script_root/install_$log_datetime.log"
#: > "$log_file"
#exec > >(tee -a "$log_file") 2>&1

utils="$script_root/utils"
dialog="$utils/dialog.sh"
pluginsinfo="$script_root/pluginsinfo.json"
nexusapi="$utils/nexus-api.sh"
gamesinfo="$script_root/gamesinfo"
handlers="$script_root/handlers"
launchers="$script_root/launchers"
redirector="$script_root/steam-redirector"
step="$script_root/step"
workarounds="$script_root/workarounds"
downloads_cache=/tmp/mo2-linux-installer-downloads-cache
shared="$HOME/.local/share/modorganizer2"

custom_game=''
custom_workaround=''
started_download_step=0
expect_exit=0

function handle_error() {
	if [ "$expect_exit" != "1" ]; then
		if [ "$started_download_step" == "1" ]; then
			purge_downloads_cache
		fi

		"$dialog" \
			errorbox \
			"Operation canceled. Check the terminal for details"
	fi
}

function log_info() {
	echo "INFO:" "$@" >&2
}

function log_warn() {
	echo "WARN:" "$@" >&2
}

function log_error() {
	echo "ERROR:" "$@" >&2
}

trap handle_error EXIT

if [ "$UID" == "0" ]; then
	log_error "Attempted to run as root"
	log_error "Please follow the install instructions provided at https://github.com/rockerbacon/modorganizer2-linux-installer"
	exit 1
fi

#source "$utils/nexus-api.sh" "fallout4" "98208" "374988"
source "$gamesinfo/fallout4.sh"

"$utils/nexus-api.sh" download \
	"${game_nexusid}" "${game_scriptextender_modid}" "${game_scriptextender_fileid}" "~/Downloads/testfile"

log_info "installation completed successfully"
expect_exit=1
"$dialog" infobox "Installation successful!\n\Launch the game on Steam to use Mod Organizer 2"
