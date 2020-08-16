# Start from golang v1.12 base image
FROM euleros

COPY bin /app/studyrust/bin
COPY config /app/studyrust/config
COPY static /app/studyrust/static
COPY template /app/studyrust/template

WORKDIR /app/studyrust

CMD ["bin/studyrust"]