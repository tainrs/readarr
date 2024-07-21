#!/bin/bash

# This script is used to update a VERSION.json file with the latest image digests
# for amd64 and arm64 architectures from an upstream Docker image. The script
# retrieves the upstream image details from the VERSION.json file, inspects the
# Docker image manifest to extract the digests for both architectures, and then
# updates the VERSION.json file with these digests. This can be useful for
# ensuring that a project is using the correct and latest versions of upstream images.

# Read the JSON content from VERSION.json into a variable
json=$(cat VERSION.json)

# Extract the 'upstream_image' value from the JSON content
upstream_image=$(jq -re '.upstream_image' <<< "${json}")

# Extract the 'upstream_tag' value from the JSON content
upstream_tag=$(jq -re '.upstream_tag' <<< "${json}")

# Retrieve the raw manifest of the Docker image specified by upstream_image and upstream_tag
# using skopeo and store it in the variable 'manifest'
manifest=$(skopeo inspect --raw "docker://${upstream_image}:${upstream_tag}") || exit 1

# Extract the digest for the amd64 architecture from the manifest
upstream_digest_amd64=$(jq -re '.manifests[] | select (.platform.architecture == "amd64" and .platform.os == "linux").digest' <<< "${manifest}")

# Extract the digest for the arm64 architecture from the manifest
upstream_digest_arm64=$(jq -re '.manifests[] | select (.platform.architecture == "arm64" and .platform.os == "linux").digest' <<< "${manifest}")

# Update the JSON content with the new digests for amd64 and arm64 architectures
# and write it back to VERSION.json, sorting the keys for consistency
jq --sort-keys \
    --arg upstream_digest_amd64 "${upstream_digest_amd64}" \
    --arg upstream_digest_arm64 "${upstream_digest_arm64}" \
    '.upstream_digest_amd64 = $upstream_digest_amd64 | .upstream_digest_arm64 = $upstream_digest_arm64' <<< "${json}" | tee VERSION.json
