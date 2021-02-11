FROM paritytech/ci-linux:production as builder
LABEL description="This is the build stage for Polkadot. Here we create the binary."

ARG PROFILE=release
WORKDIR /plasm

COPY . /plasm

RUN cargo build --$PROFILE

# ===== SECOND STAGE ======

FROM debian:buster-slim
LABEL description="This is the 2nd stage: a very small image where we copy the Polkadot binary."
ARG PROFILE=release
COPY --from=builder /plasm/target/$PROFILE/plasm /usr/local/bin

RUN useradd -m -u 1000 -U -s /bin/sh -d /plasm plasm && \
	mkdir -p /plasm/.local/share && \
	mkdir /data && \
	chown -R plasm:plasm /data && \
	ln -s /data /plasm/.local/share/plasm && \
	rm -rf /usr/bin /usr/sbin

USER plasm
EXPOSE 30333 9933 9944
VOLUME ["/data"]

CMD ["/usr/local/bin/plasm"]