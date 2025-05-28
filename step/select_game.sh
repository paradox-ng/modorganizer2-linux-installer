#!/usr/bin/env bash

screen_text=$( \
cat << EOF
Welcome to the Mod Organizer 2 installer!

This installer only allows Mod Organizer 2 to manage a single game.
Install one instance of Mod Organizer 2 for each game you want to manage.

Which game would you like to manage with this installation?
EOF
)

selected_game=$( \
	"$dialog" \
		radio \
		450 "$screen_text" \
  		"oblivionremastered" "Oblivion Remastered"\
		"fallout76" "Fallout 76"\
)

if [ -z "$selected_game" ]; then
	log_error "no game selected"
	exit 1
fi

echo "$selected_game"

