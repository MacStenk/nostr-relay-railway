FROM rust:1.75-slim AS builder

# Dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# nostr-rs-relay klonen
RUN git clone --depth 1 https://github.com/scsibug/nostr-rs-relay.git .

# Binary bauen
RUN cargo build --release

# Runtime Image
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Binary kopieren
COPY --from=builder /build/target/release/nostr-rs-relay /app/nostr-rs-relay

# Start-Script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Datenbank-Verzeichnis
RUN mkdir -p /app/db

EXPOSE 8080

CMD ["/app/start.sh"]