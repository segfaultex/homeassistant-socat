#!/usr/bin/env bash

if [[ -z "${SOCAT_ZIGBEE_TYPE}" ]]; then
  SOCAT_ZIGBEE_TYPE="tcp"
fi
if [[ -z "${SOCAT_ZIGBEE_LOG}" ]]; then
  SOCAT_ZIGBEE_LOG="-lf \"$SOCAT_ZIGBEE_LOG\""
fi
if [[ -z "${SOCAT_ZIGBEE_LINK}" ]]; then
  SOCAT_ZIGBEE_LINK="/dev/zigbee"
fi

BINARY="socat"
PARAMS="$INT_SOCAT_LOG-d -d -d pty,link=$SOCAT_ZIGBEE_LINK,raw,user=root,mode=777 $SOCAT_ZIGBEE_TYPE:$SOCAT_ZIGBEE_HOST:$SOCAT_ZIGBEE_PORT"

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
    if pgrep -f "python -m homeassistant" >/dev/null 2>&1 ; then
        echo "stopping home assistant since socat is not running"
        kill -9 $(pgrep -f "python -m homeassistant")
    fi
    exit 0
    ;;

start)
    echo "Starting... $BINARY $PARAMS" >> "$LOG_FILE"
    $BINARY $PARAMS 2>$LOG_FILE >$LOG_FILE &
    ;;

start-fail)
    echo "Start failed! $BINARY $PARAMS"
    ;;

stop)
    echo "Stopping... $BINARY $PARAMS"
    kill -9 $(pgrep -f "$BINARY $PARAMS")
    ;;

esac
