#!/usr/bin/env bash

if [ -z "$custom_game" ]; then
	load_gameinfo="$gamesinfo/$selected_game.sh"
else
	load_gameinfo="$custom_game"
fi

if [ ! -f "$load_gameinfo" ]; then
	log_error "no gameinfo for '$selected_game'"
	"$dialog" errorbox \
		"Could not find information on '$selected_game'"
	exit 1
fi

source "$load_gameinfo"

find_steam_game() {
	if [ -z "$game_steam_id" ]; then
		log_warn "empty game_steam_id"
		return 1
	elif [ -z "$game_steam_subdirectory" ]; then
		log_warn "empty steam_subdirectory"
		return 1
	fi

	steam_library=$(
		export game_steam_id game_steam_subdirectory game_executable dialog
		"$utils/find-library-for-file.sh"
	) ||
		case "$?" in
		1)
			log_info "could not find any Steam library containing a game with Steam ID '$game_steam_id'. If this game is installed with Steam and you know exactly where the library is, you can specify it using the environment variable STEAM_LIBRARY"
			return 1
			;;
		2)
			# Fallout 3 needs to be downgraded, no additional dialogs to show
			exit 1
			;;
		esac
	game_launcher=steam
	game_installation="$steam_library/steamapps/common/$game_steam_subdirectory"
	return 0
}

find_heroic_game() {
	if ! heroic_vars=$(
		export game_gog_id game_epic_id
		"$utils/find-heroic-game-installation.sh"
	); then
		return 1
	fi
	game_launcher=heroic
	eval "$heroic_vars"
}

if ! find_steam_game && ! find_heroic_game; then
	"$dialog" errorbox \
		"Could not find '$selected_game' in any of your Steam or Heroic folders.\nMake sure the game is installed and that you've run it at least once."
	exit 1
fi

case "$game_launcher" in
steam)
	game_scriptextender_url="${game_scriptextender_urls[steam]}"
	;;
heroic)
	case "$heroic_game_runner" in
	gog)
		game_scriptextender_url="${game_scriptextender_urls[gog]}"
		;;
	legendary)
		game_scriptextender_url="${game_scriptextender_urls[epic]}"
		;;
	esac
	;;
esac

nexus_scriptextender=false
if [ -n "$game_scriptextender_url" ]; then
	hasScriptExtender=true
	if [[ "$game_scriptextender_url" =~ ^https://www\.nexusmods\.com/[A-Za-z0-9_-]+/mods/[0-9]+\\?.*file_id=[0-9]+$ ]]; then
		log_info "Script extender will be downloaded from Nexus Mods"
		nexus_scriptextender=true
	fi
else
	hasScriptExtender=false
fi

# defer loading these variables to step/clean_game_prefix.sh
game_prefix=''
game_compatdata=''
