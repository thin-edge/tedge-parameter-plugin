#!/bin/sh
set -e
COMMAND="$1"
shift

PARAMETER_PLUGINS="/usr/share/tedge/parameter-plugins"

get_parameter_type() {
    echo "$1" |  jq -r '.operation | keys | .[] | select(. | startswith("c8y_ParameterUpdate_")) | sub("^c8y_ParameterUpdate_"; "")'
}

set_parameters() {
    if [ $# -lt 2 ]; then
        echo "Missing required positional arguments. expected as least 2 arguments" >&2
        exit 1
    fi
    TYPE="$1"
    PARAMETERS="$2"

    case "$TYPE" in
        flow_params_*)
            # Special case where a single parameter plugin is responsible for managing all flow parameters
            # since flows can't write the values to file themselves
            COMMON_TYPE=flow_params
            ;;
        *)
            COMMON_TYPE="$TYPE"
            ;;
    esac

    if [ ! -x "$PARAMETER_PLUGINS/$COMMON_TYPE" ]; then
        echo "Could not find a matching parameter plugin. path=$PARAMETER_PLUGINS/$COMMON_TYPE" >&2
        exit 1
    fi

    echo "Running plugin: \"$PARAMETER_PLUGINS/$COMMON_TYPE\" set \"$PARAMETERS\" \"$TYPE\"" >&2
    "$PARAMETER_PLUGINS/$COMMON_TYPE" set "$PARAMETERS" "$TYPE"
}

case "$COMMAND" in
    prepare)
        MESSAGE="$1"
        TYPE=$(get_parameter_type "$MESSAGE")
        if [ -z "$TYPE" ]; then
            echo "Could not detect the parameter update type in message" >&2
            exit 1
        fi

        PARAMETER_PAYLOAD=$(echo "$MESSAGE" | jq ".operation.${TYPE}")

        echo :::begin-tedge:::
        printf '{"type":"%s","parameters":%s}\n' "$TYPE" "$PARAMETER_PAYLOAD"
        echo :::end-tedge:::
        ;;
    set)
        set_parameters "$@"
        ;;
esac
