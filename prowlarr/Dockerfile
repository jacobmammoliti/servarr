FROM alpine:3.23 AS downloader

ARG TARGETARCH
ARG PROWLARR_VERSION=2.3.0.5236
ARG PROWLARR_SHA256_x64=076229b7df5d98e53e1736e1d1efe3e76ce78f3b6a04b45c377db0e40a43c76b
ARG PROWLARR_SHA256_arm64=735c0e57c47fedf519a34908dbbb849752e49dc19701ede9940af5bed8b8943d

RUN set -ex; \
    case "$TARGETARCH" in \
        amd64) ARCH="x64"; SHA256="$PROWLARR_SHA256_x64" ;; \
        arm64) ARCH="arm64"; SHA256="$PROWLARR_SHA256_arm64" ;; \
        *) echo "Unsupported architecture: $TARGETARCH" >&2; exit 1 ;; \
    esac; \
    apk add --no-cache curl; \
    curl -fsSL -o /tmp/prowlarr.tar.gz "https://github.com/Prowlarr/Prowlarr/releases/download/v${PROWLARR_VERSION}/Prowlarr.master.${PROWLARR_VERSION}.linux-musl-core-${ARCH}.tar.gz"; \
    echo "$SHA256  /tmp/prowlarr.tar.gz" | sha256sum -c -; \
    tar xzf /tmp/prowlarr.tar.gz -C /; \
    rm /tmp/prowlarr.tar.gz; \
    cd /Prowlarr; \
    rm -rf Prowlarr.Update;

FROM alpine:3.23 AS builder

WORKDIR /prowlarr
# Install runtime dependencies and create user in one layer
RUN apk add --no-cache \
    icu-libs \
    sqlite-libs \
    tzdata \
    su-exec \
    && addgroup -g 1000 prowlarr \
    && adduser -S -u 1000 -G prowlarr prowlarr \
    && mkdir -p /config /prowlarr \
    && chown -R prowlarr:prowlarr /config /prowlarr

# Copy application
COPY --from=downloader --chown=prowlarr:prowlarr /Prowlarr ./Prowlarr

FROM scratch

COPY --from=builder / /

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

WORKDIR /prowlarr

VOLUME ["/config"]

EXPOSE 9696

ENTRYPOINT ["/entrypoint.sh"]
CMD ["./Prowlarr/Prowlarr", "-nobrowser", "-data=/config"]