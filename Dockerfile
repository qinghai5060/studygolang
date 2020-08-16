# Start from golang v1.12 base image
FROM alpine

WORKDIR /app/studyrust

COPY bin /app/studyrust && COPY config /app/studyrust && COPY static /app/studyrust

CMD ["bin/studyrust"]