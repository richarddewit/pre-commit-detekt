#!/bin/bash

set -u

# parse arguments
opts=()
filenames=""
filenames_started=0
input_included=0
base_path_included=0
for i in "$@"; do
    if [ "$i" == "--input" ] || [ "$i" == "-i" ]; then
        input_included=1
    fi
    if [ "$i" == "--base-path" ] || [ "$i" == "-bp" ]; then
        base_path_included=1
    fi

    if [ $filenames_started -eq 0 ]; then
        if [[ ${i} == *.kt ]] || [[ ${i} == *.kts ]]; then
            filenames_started=1
        fi
    fi

    if [ $filenames_started -eq 1 ]; then
        if [ "$filenames" != "" ]; then
            filenames="$filenames,"
        fi
        filenames="${filenames}${i}"
    else
        opts+=("$i")
    fi
done

if [[ $base_path_included -eq 0 ]]; then
    opts+=("--base-path" "/src")
fi

# run detekt
pushd /src >/dev/null || exit 1
if [ "$filenames" == "" ] || [[ $input_included -eq 1 ]]; then
    OUTPUT=$(java -jar "/opt/detekt/detekt-cli-all.jar" "${opts[@]}" 2>&1)
else
    OUTPUT=$(java -jar "/opt/detekt/detekt-cli-all.jar" "${opts[@]}" --input "$filenames" 2>&1)
fi

EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    echo "$OUTPUT"
    echo "***********************************************"
    echo "                 Detekt failed                 "
    echo " Please fix the above issues before committing "
    echo "***********************************************"
    exit $EXIT_CODE
fi
popd >/dev/null || exit 1
