FROM clux/muslrust:stable AS builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM

RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM" > /log

ADD --chown=rust:rust . ./
RUN cargo build --release

FROM alpine:latest
ARG APP_USER=gravel
RUN addgroup -S $APP_USER && adduser -S -g $APP_USER $APP_USER

# COPY --from=builder ./volume/target/x86_64-unknown-linux-musl/release/gravel-gateway /usr/bin/gravel-gateway
# COPY --from=builder ./volume/target/aarch64-unknown-linux-musl/release/gravel-gateway /usr/bin/gravel-gateway
# to handle differenc RUST_ARCH use  '*'
COPY --from=builder ./volume/target/*-unknown-linux-musl/release/gravel-gateway /usr/bin/gravel-gateway

RUN chown -R $APP_USER:$APP_USER /usr/bin/gravel-gateway
USER $APP_USER
EXPOSE 4278

ENTRYPOINT [ "/usr/bin/gravel-gateway", "-l", "0.0.0.0:4278" ]

HEALTHCHECK --interval=30s --timeout=3s CMD wget --spider localhost:4278/metrics
