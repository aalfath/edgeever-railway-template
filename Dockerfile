# EdgeEver for Railway: official image, pinned by release tag and digest.
FROM ghcr.io/tianma-if/edgeever:v2.31.2@sha256:929ab9cdf826d6e4a3c4d5f41502bface54db5154cadd2f944fde27fb75abf75

USER root
COPY railway-start.sh /usr/local/bin/railway-start.sh
COPY railway-proxy.mjs /app/scripts/railway-proxy.mjs
RUN chmod 755 /usr/local/bin/railway-start.sh && chmod 644 /app/scripts/railway-proxy.mjs

# Railway routes the public domain and its health check to PORT.
ENV PORT=8787 \
    EDGE_EVER_DATA_DIR=/data \
    EDGE_EVER_CONTAINER_IMAGE=ghcr.io/tianma-if/edgeever \
    EDGE_EVER_DEPLOYMENT_METHOD=docker \
    EDGE_EVER_DEPLOYMENT_TRIGGER=github_release

EXPOSE 8787
STOPSIGNAL SIGTERM
CMD ["/usr/local/bin/railway-start.sh"]
