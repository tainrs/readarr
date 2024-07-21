#!/bin/bash

# Docker build script for multi-architecture images.
#
#  _______ _______ _____ __   _  ______ _______
#     |    |_____|   |   | \  | |_____/ |______
#     |    |     | __|__ |  \_| |    \_ ______|
#

# Check if the first argument is provided; if not, print usage instructions and exit with an error code.
if [[ -z ${1} ]]; then
    echo "Usage: ./build.sh amd64"
    exit 1
fi

# `jq` is required to parse the VERSION.json file. The output of jq is used to set the build arguments.
#
# Example command:
# jq -r 'to_entries[] | [(.key | ascii_upcase),.value] | join("=")' < VERSION.json
#
# Example output:
# DESCRIPTION=Alpine 3.20
# UPSTREAM_DIGEST_AMD64=sha256:dabf91b69c191a1a0a1628fd6bdd029c0c4018041c7f052870bb13c5a222ae76
# UPSTREAM_DIGEST_ARM64=sha256:647a509e17306d117943c7f91de542d7fb048133f59c72dff7893cffd1836e11
# UPSTREAM_IMAGE=alpine
# UPSTREAM_TAG=3.20
# VERSION=3.2.0.0
# VERSION_S6=3.2.0.0

# Set the organization name for the Docker image.
org=tainrs

# Get the name of the current Git repository and use it as the image name.
image=$(basename "$(git rev-parse --show-toplevel)")

# Build the Docker image with the following options:
# --progress=plain: Show the plain build output.
# --platform: Set the target platform for the build (e.g., linux/amd64).
# -f: Specify the Dockerfile to use for the build.
# -t: Tag the image with the format "org/repo-platform".
# $(for ... ; done; echo $out; out=""): Parse the VERSION.json file with `jq`, convert the keys to uppercase,
# and use the key-value pairs as build arguments.
docker build --progress=plain --platform "linux/${1}" -f "./linux-${1}.Dockerfile" -t "${org}/${image}-${1}" $(for i in $(jq -r 'to_entries[] | [(.key | ascii_upcase),.value] | join("=")' < VERSION.json); do out+="--build-arg $i " ; done; echo $out; out="") .
