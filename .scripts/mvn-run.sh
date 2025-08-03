#!/bin/bash

DEBUG=false
SKIP_COMPILE=false
USE_MVN_RUN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
    -d)
        DEBUG=true
        shift
        ;;
    -c)
        SKIP_COMPILE=true
        shift
        ;;
    -m)
        USE_MVN_RUN=true
        shift
        ;;
    -*)
        echo "unknown option: $1"
        exit 1
        ;;
    *)
        MAIN_CLASS="$1"
        shift
        ;;
    esac
done

if [ -z "$MAIN_CLASS" ]; then
    echo "usage: $0 [-d] [-c] [-m] <fully.qualified.MainClass>"
    echo "options:"
    echo "  -d   show output from mvn compile"
    echo "  -c   skip compilation"
    echo "  -m   run with mvn exec:java instead of direct java execution"
    echo "example: $0 -d com.example.TestCLI"
    exit 1
fi

if [ "$SKIP_COMPILE" = false ]; then
    if [ "$DEBUG" = true ]; then
        mvn compile
    else
        mvn compile >/dev/null
    fi
    COMPILE_RESULT=$?
    if [ $COMPILE_RESULT -ne 0 ]; then
        echo "Compilation failed"
        exit $COMPILE_RESULT
    fi
fi

printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' '-'

if [ "$USE_MVN_RUN" = true ]; then
    if [ "$DEBUG" = true ]; then
        mvn exec:java -Dexec.mainClass="$MAIN_CLASS"
    else
        mvn exec:java -Dexec.mainClass="$MAIN_CLASS" -q
    fi
else
    java -cp target/classes/ "$MAIN_CLASS"
fi
