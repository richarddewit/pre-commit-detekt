#!/bin/sh

set -u

ends_with() {
    target="${1}"
    suffix="${2}"

    case $target in
    *$suffix)
        echo 0
        ;;
    *)
        echo 1
        ;;
    esac
}

# parse arguments
opts=""
filenames=""
filenames_started=0
input_included=0
base_path_included=0
for i in "$@"; do
    if [ "$i" = "--input" ] || [ "$i" = "-i" ]; then
        input_included=1
    fi
    if [ "$i" = "--base-path" ] || [ "$i" = "-bp" ]; then
        base_path_included=1
    fi

    if [ $filenames_started -eq 0 ]; then
        if [ "$(ends_with "$i" ".kt")" -eq 0 ] || [ "$(ends_with "$i" ".kts")" -eq 0 ]; then
            filenames_started=1
        fi
    fi

    if [ $filenames_started -eq 1 ]; then
        if [ "$filenames" != "" ]; then
            filenames="$filenames,"
        fi
        filenames="${filenames}${i}"
    else
        if [ "$opts" != "" ]; then
            opts="$opts "
        fi
        opts="$opts$i"
    fi
done

if [ $base_path_included -eq 0 ]; then
    if [ "$opts" != "" ]; then
        opts="$opts "
    fi
    opts="${opts}--base-path /src"
fi

# run detekt
current_dir=$(pwd)
cd /src >/dev/null || exit 1
if [ "$filenames" = "" ] || [ $input_included -eq 1 ]; then
    # shellcheck disable=SC2086
    OUTPUT=$(java -jar "/opt/detekt/detekt-cli-all.jar" $opts 2>&1)
else
    # shellcheck disable=SC2086
    OUTPUT=$(java -jar "/opt/detekt/detekt-cli-all.jar" $opts --input "$filenames" 2>&1)
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
cd "$current_dir" >/dev/null || exit 1
