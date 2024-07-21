#!/bin/bash

# This script is designed to update the version number in a local JSON file (VERSION.json)
# with the latest version number for Radarr for Linux, which it fetches from the Radarr API.
# It uses the 'curl' command to fetch the latest version, 'jq' to parse and manipulate JSON data,
# and 'tee' to write the output back to VERSION.json.

branch="develop"
os="linuxmusl"
runtime="netcore"
arch="x64"
url="https://readarr.servarr.com/v1/update/${branch}/changes?os=${os}&runtime=${runtime}&arch=${arch}"

latest_version=$(curl -s $url | jq -r '.[0].version')

json=$(cat VERSION.json)
jq --sort-keys \
    --arg version "${latest_version//v/}" \
    --arg sbranch "${branch}" \
    '.version = $version | .sbranch = $sbranch' <<< "${json}" | tee VERSION.json
