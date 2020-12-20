#!/usr/bin/env bash

BINARY="python"
PARAMS="-m homeassistant --config /config"

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
    CHAPID=$(pgrep -f "$BINARY $PARAMS")
    if pgrep -f "$BINARY $PARAMS" >/dev/null 2>&1 ; then
      if [[ $CHAPID != `cat /HAPID` ]] ; then
        echo " [ $CHAPID ] != [ `cat /HAPID` ] Killing Home Assistant" >> "$LOG_FILE"
        kill -9 $(pgrep -f "$BINARY $PARAMS")
        exit 0
      elif [[ `pgrep -f "socat" | wc -l` != 2 ]] >/dev/null 2>&1 ; then
        echo "At least one instance of socat is not running. Stopping... Home Assistant" >> "$LOG_FILE"
        kill -9 $(pgrep -f "$BINARY $PARAMS")
        exit 0
      else
        exit 1
      fi
    fi
    exit 0
    ;;

start)
    echo "Starting... $BINARY $PARAMS" >> "$LOG_FILE"
    if [[ `pgrep -f "socat" | wc -l` == 2 ]] >/dev/null 2>&1 ; then
        # socat is running
        cd /usr/src/homeassistant
        $BINARY $PARAMS 2>$LOG_FILE >$LOG_FILE &
        $(pgrep -f "$BINARY $PARAMS") > /HAPID
        exit 0
    else
        # socat is not running
        echo "At least one instance of socat is not running." >> "$LOG_FILE"
        exit 1
    fi
    ;;

start-fail)
    echo "Start failed! $BINARY $PARAMS" >> "$LOG_FILE"
    ;;

stop)
    echo "Stopping... Home Assistant" >> "$LOG_FILE"
    cd /usr/src/app
    kill -9 $(pgrep -f "$BINARY $PARAMS")
    ;;

esac
