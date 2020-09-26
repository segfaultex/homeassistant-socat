FROM "homeassistant/home-assistant:latest"
LABEL maintainer="Vlad Babii"

RUN mkdir /runwatch
COPY runwatch/run.sh /runwatch/run.sh

# Monitor HomeAssistant
COPY runwatch/300.home-assistant.enabled.sh /runwatch/300.home-assistant.enabled.sh

# Install socat
RUN apk add --no-cache socat

# Monitor socat
COPY runwatch/100.socat-zwave.enabled.sh /runwatch/100.socat-zwave.enabled.sh

# Monitor socat
COPY runwatch/200.socat-zigbee.enabled.sh /runwatch/200.socat-zigbee.enabled.sh

CMD [ "bash","/runwatch/run.sh" ]
