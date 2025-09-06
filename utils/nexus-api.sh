token="${NEXUS_TOKEN:-}"
user_token="${NEXUS_USER_TOKEN:-}"
application="mod-organizer-2-linux-installer"
version="indev"

function sso() {

    uuid=$(cat /proc/sys/kernel/random/uuid)
    application_slug="mod-organizer-2-linux-installer"

    echo "UUID: ${uuid}"
    json="{\"id\":\"$uuid\",\"token\":null,\"protocol\":2}"

    if [ -z "$NEXUS_USER_TOKEN" ]; then
        
    fi
}

function request_headers() {
    echo "-H \"apikey: $token\""
    echo "-H \"Application-Name: $name\""
    echo "-H \"Application-Version: $version\""
}

function curl_nexus() {
    local url="$1"
    local headers=""
    while IFS= read -r line; do
        headers="$headers $line"
    done < <(request_headers)

    eval curl -s $headers "$url"
}

function fetch_download_link() {
    local game_id="$1"
    local mod_id="$2"
    local file_id="$3"

    url="https://api.nexusmods.com/v1/games/$game_id/mods/$mod_id/files/$file_id/download_link.json"
    echo "${url}"

    response=$(curl_nexus "https://api.nexusmods.com/v1/games/$game_id/mods/$mod_id/files/$file_id/download_link.json")
    echo "Response: ${response}"
    parsed=$(echo "$response" | grep -o '{[^}]*"short_name":"Nexus CDN"[^}]*}' | sed -n 's/.*"URI":"\([^"]*\)".*/\1/p')
    echo "URI: ${parsed}"
}