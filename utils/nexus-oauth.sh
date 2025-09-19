#!/usr/bin/env bash

function code_challenge() { # https://modding.wiki/en/api/oauth2-guide#create-the-code-challenge-public-apps
    verifier="$(openssl rand -hex 43)"

    base64url() {
        echo -n "$1" | openssl base64 -e | tr '+/' '-_' | tr -d '=' | tr -d '\n'
    }

    challenge="$(echo -n "$verifier" | openssl dgst -sha256 -binary | base64url)"

    echo "$challenge"
}

function auth_url() { # https://modding.wiki/en/api/oauth2-guide#generate-an-authorize-url

    clientID='PLACEHOLDER'
    response_type='code'
    scope=''
    redirect_uri='PLACEHOLDER'
    state=$(uuidgen)
    method='S256'
    challenge=$(code_challenge)
    
}