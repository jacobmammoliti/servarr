FROM alpine:3.23 AS downloader

ARG TARGETARCH
ARG RADARR_VERSION=6.0.4.10291
ARG RADARR_SHA256_x64=66256b1b0905b6bd5d73aab95d6d5b32cf22033096489d0c4fc3317bf1a1b549
ARG RADARR_SHA256_arm64=fb867a7ce9957a1ffeb18a239803468a0d33cc2fa5129c695de600557c8788b0

RUN set -ex; \
    case "$TARGETARCH" in \
        amd64) ARCH="x64"; SHA256="$RADARR_SHA256_x64" ;; \
        arm64) ARCH="arm64"; SHA256="$RADARR_SHA256_arm64" ;; \
        *) echo "Unsupported architecture: $TARGETARCH" >&2; exit 1 ;; \
    esac; \
    apk add --no-cache curl; \
    curl -fsSL -o /tmp/radarr.tar.gz "https://github.com/Radarr/Radarr/releases/download/v${RADARR_VERSION}/Radarr.master.${RADARR_VERSION}.linux-musl-core-${ARCH}.tar.gz"; \
    echo "$SHA256  /tmp/radarr.tar.gz" | sha256sum -c -; \
    tar xzf /tmp/radarr.tar.gz -C /; \
    rm /tmp/radarr.tar.gz; \
    cd /Radarr; \
    rm -rf Radarr.Update;

FROM alpine:3.23 AS builder

WORKDIR /radarr
# Install runtime dependencies and create user in one layer
RUN apk add --no-cache \
    icu-libs \
    sqlite-libs \
    tzdata \
    su-exec \
    && addgroup -g 1000 radarr \
    && adduser -S -u 1000 -G radarr radarr \
    && mkdir -p /config /radarr \
    && chown -R radarr:radarr /config /radarr

# Copy application
COPY --from=downloader --chown=radarr:radarr /Radarr ./Radarr

FROM scratch

COPY --from=builder / /

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

WORKDIR /radarr

VOLUME ["/config"]

EXPOSE 7878

ENTRYPOINT ["/entrypoint.sh"]
CMD ["./Radarr/Radarr", "-nobrowser", "-data=/config"]