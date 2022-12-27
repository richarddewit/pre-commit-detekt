#!/bin/bash

set -eu

#
# FROM: https://gist.github.com/Ariel-Rodriguez/9e3c2163f4644d7a389759b224bfe7f3
# Thanks!
#
###
# semantic version comparition using semver specification http://semver.org/
# This bash script compares pre-releases alphabetically as well
#
# returns 1 when A greater than B
# returns 0 when A equals B
# returns -1 when A lower than B
#
# Usage
# chmod +x semver.sh
# ./semver.sh 1.0.0 v1.0.0-rc.0
# --> 1
#
# Author Ariel Rodriguez
# License MIT
###
semver_compare() {
    local version_a version_b pr_a pr_b
    # strip word "v" and extract first subset version (x.y.z from x.y.z-foo.n)
    version_a=$(echo "${1//v/}" | awk -F'-' '{print $1}')
    version_b=$(echo "${2//v/}" | awk -F'-' '{print $1}')

    if [ "$version_a" == "$version_b" ]; then
        # check for pre-release
        # extract pre-release (-foo.n from x.y.z-foo.n)
        pr_a=$(echo "$1" | awk -F'-' '{print $2}')
        pr_b=$(echo "$2" | awk -F'-' '{print $2}')

        ####
        # Return 0 when A is equal to B
        [ "$pr_a" \= "$pr_b" ] && echo 0 && return 0

        ####
        # Return 1

        # Case when A is not pre-release
        if [ -z "$pr_a" ]; then
            echo 1 && return 0
        fi

        ####
        # Case when pre-release A exists and is greater than B's pre-release

        # extract numbers -rc.x --> x
        # shellcheck disable=SC2086,SC2116
        number_a=$(echo ${pr_a//[!0-9]/})
        # shellcheck disable=SC2086,SC2116
        number_b=$(echo ${pr_b//[!0-9]/})
        [ -z "${number_a}" ] && number_a=0
        [ -z "${number_b}" ] && number_b=0

        [ "$pr_a" \> "$pr_b" ] && [ -n "$pr_b" ] && [ "$number_a" -gt "$number_b" ] && echo 1 && return 0

        ####
        # Retrun -1 when A is lower than B
        echo -1 && return 0
    fi
    # shellcheck disable=SC2206
    arr_version_a=(${version_a//./ })
    # shellcheck disable=SC2206
    arr_version_b=(${version_b//./ })
    cursor=0
    # Iterate arrays from left to right and find the first difference
    while [ "$([ "${arr_version_a[$cursor]}" -eq "${arr_version_b[$cursor]}" ] && [ $cursor -lt ${#arr_version_a[@]} ] && echo true)" == true ]; do
        cursor=$((cursor + 1))
    done
    [ "${arr_version_a[$cursor]}" -gt "${arr_version_b[$cursor]}" ] && echo 1 || echo -1
}

make_release() {
    local version="$1"
    local version_without_v="${version//v/}"

    # Update version
    echo "$version" >version

    # Update Dockerfile
    printf 'ARG DETEKT_VERSION=%s\n' "$version_without_v" >Dockerfile.tmp
    tail -n +2 Dockerfile >>Dockerfile.tmp
    rm -rf Dockerfile
    mv Dockerfile.tmp Dockerfile

    # git commit and tag
    echo "--- Update to $version ---"
    tag="$version"
    git add version Dockerfile
    git commit -m "Update to $version"
    git tag "$tag"
    git push origin "$tag"
}

latest_version=$(cat version)

if [ ! -f detekt_releases.json ]; then
    curl -sSL https://api.github.com/repos/detekt/detekt/releases >detekt_releases.json
fi

detekt_versions="$(jq -r 'sort_by(.published_at) | map(.tag_name) | .[]' <detekt_releases.json)"
IFS_ORG="$IFS"
IFS=$'\n'
# shellcheck disable=SC2206
detekt_versions=($detekt_versions)
IFS="$IFS_ORG"

for i in "${detekt_versions[@]}"; do
    left="$i"
    right="$latest_version"
    if [ "$(semver_compare "$left" "$right")" -eq 1 ]; then
        make_release "$i"
    fi
done
