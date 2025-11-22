#!/usr/bin/env bash

printf "INFO: Starting SSO process\n"

# Check dependencies
command -v websocat >/dev/null 2>&1 || { printf "ERROR: websocat is required. Install it and retry.\n"; exit 2; }
command -v jq >/dev/null 2>&1 || { printf "ERROR: jq is required. Install it and retry.\n"; exit 2; }
command -v uuidgen >/dev/null 2>&1 || { printf "ERROR: uuidgen is required. Install it and retry.\n"; exit 2; }


# Grab existing variables / set defaults
UUID=${UUID:-$(uuidgen)}
CONNECTION_TOKEN=${CONNECTION_TOKEN:-}
API_KEY=${API_KEY:-}
TIMEOUT=${TIMEOUT:-300}


# Set up files
VAR_FILE=${VAR:-"$HOME/.local/share/modorganizer2/nexus.env"}
touch "$VAR_FILE"
FIFO_FILE="$(mktemp -u /tmp/nexus-sso.fifo.XXXX)"
mkfifo "$FIFO_FILE"
LOG_FILE=${LOG:-/tmp/nexus-sso.log}
: >"$LOG_FILE"
CONNECTED_FLAG=/tmp/nexus-sso.connected


# UUID Storage
if [ -s "$VAR_FILE" ]; then
	file_uuid=$(awk -F= '/^UUID=/{print $2; exit}' "$VAR_FILE")
	if printf '%s' "$file_uuid" | grep -Eq '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'; then # If existing and valid UUID
		UUID="$file_uuid"
		printf "INFO: Using existing UUID\n"
	else
		sed -i '/^UUID=/d' "$VAR_FILE"
		printf 'UUID=%s\n' "$UUID" >>"$VAR_FILE"
		printf "INFO: Generated and stored new UUID\n"
	fi
else
	sed -i '/^UUID=/d' "$VAR_FILE"
	printf 'UUID=%s\n' "$UUID" >>"$VAR_FILE"
	printf "INFO: Generated and stored new UUID\n"
fi


# CONNECTION_TOKEN Storage
if [ -s "$VAR_FILE" ]; then
	file_token=$(awk -F= '/^CONNECTION_TOKEN=/{print $2; exit}' "$VAR_FILE")
	if [ -n "$file_token" ]; then
		CONNECTION_TOKEN="$file_token"
		printf "INFO: Using existing CONNECTION_TOKEN\n"
	fi
fi


# Cleanup on exit
cleanup() {
	rm -f "$FIFO_FILE"
	rm -f "$CONNECTED_FLAG"
	if [ -n "${WEBSOCK_PID:-}" ]; then
		kill "${WEBSOCK_PID}" 2>/dev/null || true
	fi
	if [ -n "${tail_pid:-}" ]; then
		kill "${tail_pid}" 2>/dev/null || true
	fi
}
trap cleanup EXIT


# Start websocat in background
websocat -vn "wss://sso.nexusmods.com" <"$FIFO_FILE" >>"$LOG_FILE" 2>&1 &
WEBSOCK_PID=$!
printf "INFO: Started websocat (pid=%s fifo_file=%s log_file=%s)\n" "$WEBSOCK_PID" "$FIFO_FILE" "$LOG_FILE" >&2


# DEBUG: View Logs
tail -n +1 -F "$LOG_FILE" 2>/dev/null | (
	while IFS= read -r line; do
		# Only print non-JSON lines to avoid dumping raw JSON to the terminal
		if ! printf '%s' "$line" | jq -e '.' >/dev/null 2>&1; then
			printf '%s\n' "$line"
		fi
		case "$line" in
			*Connected*|*connected*)
				: >"$CONNECTED_FLAG"
				;;
		esac
		token=$(printf '%s' "$line" | jq -r 'try(fromjson) | .data.connection_token // empty' 2>/dev/null || true)
		if [ -n "$token" ]; then
			CONNECTION_TOKEN="$token"
		fi
	done
) &
tail_pid=$!


# Send initial payload
PAYLOAD=$(jq -c -n --arg id "$UUID" --arg token "$CONNECTION_TOKEN" '{id:$id,token:$token,protocol:2}')
printf "INFO: Sending payload to SSO server\n"
printf '%s\n' "$PAYLOAD" >"$FIFO_FILE"


# Connection Token Request & Storage
get_connection() {
	local elapsed=0
	local interval=1
	while [ $elapsed -lt $TIMEOUT ]; do
		JSON_OBJ=$(jq -R -r -s 'split("\n") | map(try(fromjson) catch null) | map(select(.!=null and .data and .data.connection_token)) | .[0] // empty' "$LOG_FILE" 2>/dev/null)
		if [ -n "$JSON_OBJ" ]; then
			CONNECTION_TOKEN=$(printf '%s' "$JSON_OBJ" | jq -r '.data.connection_token // empty')
		fi
		if [ -n "$CONNECTION_TOKEN" ]; then
			printf "INFO: Retrieved connection token from SSO server\n"
			return 0
		fi
		sleep "$interval"
		elapsed=$((elapsed + interval))
	done
	return 1
}

if [ -z "$CONNECTION_TOKEN" ]; then
	get_connection
	sed -i '/^CONNECTION_TOKEN=/d' "$VAR_FILE"
	printf 'CONNECTION_TOKEN=%s\n' "$CONNECTION_TOKEN" >>"$VAR_FILE"
	printf "INFO: Stored connection token\n"
fi

# API_KEY Storage
if [ -s "$VAR_FILE" ]; then
	file_token=$(awk -F= '/^API_KEY=/{print $2; exit}' "$VAR_FILE")
	if [ -n "$file_token" ]; then
		API_KEY="$file_token"
		printf "INFO: Using existing API_KEY\n"
	fi
fi

get_token() {
	local elapsed=0
	local interval=1
	xdg-open "$URL" >/dev/null 2>&1 || printf "INFO: Please open the following URL in your browser to authenticate:\n%s\n" "$URL"
	while [ $elapsed -lt $TIMEOUT ]; do
		JSON_OBJ=$(jq -R -r -s 'split("\n") | map(try(fromjson) catch null) | map(select(.!=null and .data and .data.api_key)) | .[0] // empty' "$LOG_FILE" 2>/dev/null)
		if [ -n "$JSON_OBJ" ]; then
			API_KEY=$(printf '%s' "$JSON_OBJ" | jq -r '.data.api_key // empty')
		fi
		if [ -n "$API_KEY" ]; then
			printf "INFO: Retrieved API key from SSO server\n"
			return 0
		fi
		sleep "$interval"
		elapsed=$((elapsed + interval))
	done
	return 1
}

URL="https://www.nexusmods.com/sso?id=${UUID}&application=mo2lint"
if [ -z "$API_KEY" ]; then
	get_token
	sed -i '/^API_KEY=/d' "$VAR_FILE"
	printf 'API_KEY=%s\n' "$API_KEY" >>"$VAR_FILE"
	printf "INFO: Stored API key\n"
fi

pkill "$WEBSOCK_PID" 2>/dev/null || true
printf "INFO: SSO process completed\n"