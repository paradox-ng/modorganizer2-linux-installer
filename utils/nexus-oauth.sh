#!/usr/bin/env bash

function code_challenge() { # https://modding.wiki/en/api/oauth2-guide#create-the-code-challenge-public-apps
	verifier="$(openssl rand -hex 43)"

	challenge="$(printf '%s' "$verifier" | openssl dgst -sha256 -binary | openssl base64 -A | tr '+/' '-_' | tr -d '=')"

	echo "$challenge"
}

function auth_url() { # https://modding.wiki/en/api/oauth2-guide#generate-an-authorize-url

	client_id='PLACEHOLDER'
	response_type='code'
	scope=''
	redirect_uri='PLACEHOLDER'
	state=$(uuidgen)
	method='S256'
	challenge=$(code_challenge)

	url="https://users.nexusmods.com/oauth/authorize?client_id=${client_id}&response_type=${response_type}&scope=${scope}&redirect_uri=${redirect_uri}&state=${state}&code_challenge_method=${method}&code_challenge=${challenge}"

	echo "$url"
	
}

echo $(auth_url)