FROM alpine:3.23 AS downloader

ARG TARGETARCH
ARG SONARR_VERSION=4.0.16.2944
ARG SONARR_SHA256_x64=dd7c6d62667830622bd4970c064d7ae110673c5d767e222afde0e14bb311349d
ARG SONARR_SHA256_arm64=2540234eee8d2fd31d75518df3b747aa942445e84810afc57765ca2a08dbd185

RUN set -ex; \
    case "$TARGETARCH" in \
        amd64) ARCH="x64"; SHA256="$SONARR_SHA256_x64" ;; \
        arm64) ARCH="arm64"; SHA256="$SONARR_SHA256_arm64" ;; \
        *) echo "Unsupported architecture: $TARGETARCH" >&2; exit 1 ;; \
    esac; \
    apk add --no-cache curl; \
    curl -fsSL -o /tmp/sonarr.tar.gz "https://github.com/Sonarr/Sonarr/releases/download/v${SONARR_VERSION}/Sonarr.main.${SONARR_VERSION}.linux-musl-${ARCH}.tar.gz"; \
    echo "$SHA256  /tmp/sonarr.tar.gz" | sha256sum -c -; \
    tar xzf /tmp/sonarr.tar.gz -C /; \
    rm /tmp/sonarr.tar.gz; \
    cd /Sonarr; \
    rm -rf Sonarr.Update;

FROM alpine:3.23 AS builder

WORKDIR /sonarr

# Install runtime dependencies and create user in one layer
RUN apk add --no-cache \
    icu-libs \
    sqlite-libs \
    tzdata \
    su-exec \
    && addgroup -g 1000 sonarr \
    && adduser -S -u 1000 -G sonarr sonarr \
    && mkdir -p /config /sonarr \
    && chown -R sonarr:sonarr /config /sonarr

# Copy application
COPY --from=downloader --chown=sonarr:sonarr /Sonarr ./Sonarr

FROM scratch

COPY --from=builder / /

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

WORKDIR /sonarr

VOLUME ["/config"]

EXPOSE 8989

ENTRYPOINT ["/entrypoint.sh"]

CMD ["./Sonarr/Sonarr", "-nobrowser", "-data=/config"]