#!/usr/bin/env bash
type=$1; shift

# USAGE:
# "$utils/nexus-api.sh" download <game_id> <mod_id> <file_id> <output_path>

VAR_FILE=${VAR:-"$HOME/.local/share/modorganizer2/nexus.env"}

if [ -f "$VAR_FILE" ]; then
	source "$VAR_FILE"
	token="${API_KEY:-}"
fi
if [ -z "$token" ]; then
	$utils/nexus-sso.sh
	if [ -f "$VAR_FILE" ]; then
		source "$VAR_FILE"
		token="${API_KEY:-}"
	fi
fi
application="mo2lint"
version="indev"

function request_headers() {
	echo "apikey: $token"
	echo "Application-Name: $application"
	echo "Application-Version: $version"
}

function curl_nexus() {
	local url="$1"
	shift
	local attempt_max=3
	local attempt=1
	local response=""

	local headers=()
	while IFS= read -r line; do
		headers+=("-H" "$line")
	done < <(request_headers)

	printf "INFO: requesting uri %s\n" "$url" >&2

	while [ $attempt -lt $attempt_max ]; do
		response=$(curl -s -v "${headers[@]}" "$@" "$url")
		if [[ -z "$response" || "$response" == *"Please provide an authentication method"* ]]; then
			printf "INFO: Attempt $attempt failed: No response or authentication required. Retrying...\n" >&2
			((attempt++))
			sleep 2
		else
			echo "$response"
			return 0
		fi
	done

	printf "ERROR: Failed after $attempt_max attempts.\n" >&2
	exit 1
}

function fetch_download_link() {
	local game_id="$1"
	local mod_id="$2"
	local file_id="$3"

	response=$(curl_nexus "https://api.nexusmods.com/v1/games/$game_id/mods/$mod_id/files/$file_id/download_link.json")
	parsed=$(printf "%s" "$response" | grep -o '{[^}]*"short_name":"Nexus CDN"[^}]*}' | sed -n 's/.*"URI":"\([^"]*\)".*/\1/p')
	parsed=$(printf "%s" "$parsed" | sed 's/\\u0026/\&/g')

	#printf "INFO: Raw response: %s\n" "$response" >&2
	#printf "INFO: Parsed download link: %s\n" "$parsed">&2
	if [ -z "$parsed" ]; then
		printf "ERROR: Failed to parse download link from response.\n" >&2
		exit 1
	fi

	echo "${parsed}"
}

download() {
	url=$(fetch_download_link $1 $2 $3 | sed 's/ /%20/g')

	if [[ "$4" == ~* ]]; then
		out="${4/#\~/$HOME}"
	fi

	printf "INFO: Downloading %s to %s\n" "$url" "$out" >&2

	curl "$url" -L --fail -o "$out"
}

$type "$@"
exit $?