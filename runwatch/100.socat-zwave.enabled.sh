#!/usr/bin/env bash

if [[ -z "${SOCAT_ZWAVE_TYPE}" ]]; then
  SOCAT_ZWAVE_TYPE="tcp"
fi
if [[ -z "${SOCAT_ZWAVE_LOG}" ]]; then
  SOCAT_ZWAVE_LOG="-lf \"$SOCAT_ZWAVE_LOG\""
fi
if [[ -z "${SOCAT_ZWAVE_LINK}" ]]; then
  SOCAT_ZWAVE_LINK="/dev/zwave"
fi

BINARY="socat"
PARAMS="$INT_SOCAT_LOG-d -d pty,link=$SOCAT_ZWAVE_LINK,raw,user=root,mode=777 $SOCAT_ZWAVE_TYPE:$SOCAT_ZWAVE_HOST:$SOCAT_ZWAVE_PORT"

######################################################

CMD=$1

if [[ -z "${CONFIG_LOG_TARGET}" ]]; then
  LOG_FILE="/dev/null"
else
  LOG_FILE="${CONFIG_LOG_TARGET}"
fi

case $CMD in

describe)
    echo "Sleep $PARAMS"
    ;;

## exit 0 = is not running
## exit 1 = is running
is-running)
    if pgrep -f "$BINARY $PARAMS" >/dev/null 2>&1 ; then
        exit 1
    fi
    # stop home assistant if socat is not running 
    if pgrep -f "python -m homeassistant --config /config" >/dev/null 2>&1 ; then
        echo "Stopping home assistant since socat-zwave is not running" >> "$LOG_FILE"
        kill -9 $(pgrep -f "homeassistant --config /config")
    fi
    exit 0
    ;;

start)
    echo "Starting... $BINARY $PARAMS" >> "$LOG_FILE"
    $BINARY $PARAMS 2>$LOG_FILE >$LOG_FILE &
    ;;

start-fail)
    echo "Start failed! $BINARY $PARAMS" >> "$LOG_FILE"
    ;;

stop)
    echo "Stopping... socat-zwave" >> "$LOG_FILE"
    kill -9 $(pgrep -f "$BINARY $PARAMS")
    ;;

esac
