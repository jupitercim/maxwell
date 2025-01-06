FROM zendesk/maxwell:latest
COPY config.properties /app
COPY filter.js /app
CMD [ "/bin/bash", "-c", "bin/maxwell" ]
