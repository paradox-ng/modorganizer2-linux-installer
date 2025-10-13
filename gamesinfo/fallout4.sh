game_nexus_id="fallout4"
game_steam_id=377160
game_gog_id=1998527297
game_epic_id=""
game_steam_subdirectory="Fallout 4"
game_executable="Fallout4Launcher.exe"
game_protontricks=("xaudio2_7=native" "grabfullscreen=y")
declare -A game_scriptextender_urls=(
	["steam"]=""
	["gog"]="https://f4se.silverlock.org/beta/f4se_0_06_23.7z" # Fallout 4 runtime 1.10.163
	["epic"]=""
)
game_scriptextender_files=(
	"f4se_0_06_23/Data"
	"f4se_0_06_23/CustomControlMap.txt"
	"f4se_0_06_23/f4se_1_10_163.dll"
	"f4se_0_06_23/f4se_loader.exe"
	"f4se_0_06_23/f4se_steam_loader.dll"
)
