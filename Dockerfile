# Start from golang v1.12 base image
FROM alpine

COPY bin /app/studyrust/bin
COPY config /app/studyrust/config
COPY static /app/studyrust/static

WORKDIR /app/studyrust

CMD ["bin/studyrust"]