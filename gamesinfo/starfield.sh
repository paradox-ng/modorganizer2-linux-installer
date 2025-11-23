game_nexus_id="starfield"
game_steam_id=1716740
game_gog_id=""
game_epic_id=""
game_steam_subdirectory="Starfield"
game_executable="Starfield.exe"
game_protontricks=("xaudio2_7=native")


declare -A game_scriptextender_urls=(
	["steam"]="https://www.nexusmods.com/starfield/mods/106?tab=files&file_id=55300"
	["gog"]=""
	["epic"]=""
)

declare -A game_scriptextender_files=(
	["steam"]="game_scriptextender_files_steam"
	["gog"]="game_scriptextender_files_gog"
	["epic"]="game_scriptextender_files_epic"
)
declare -a game_scriptextender_files_steam=(
	"sfse_0_07_05/sfse_1_15_222.dll"
	"sfse_0_07_05/sfse_loader.exe"
)
declare -a game_scriptextender_files_gog=()
declare -a game_scriptextender_files_epic=()