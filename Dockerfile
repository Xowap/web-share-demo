FROM modelw/base:2023.04

COPY --chown=user package.json package-lock.json ./

RUN modelw-docker install

COPY --chown=user . .

RUN modelw-docker build

CMD ["modelw-docker", "serve"]
