#!/bin/bash
set -e

echo "🔗 Nostr Relay + Landing Page Startup..."

RELAY_URL="${RELAY_URL:-wss://localhost:8080}"
RELAY_NAME="${RELAY_NAME:-My Nostr Relay}"
RELAY_DESCRIPTION="${RELAY_DESCRIPTION:-Personal Nostr relay}"
RELAY_PUBKEY="${RELAY_PUBKEY:-}"
RELAY_CONTACT="${RELAY_CONTACT:-}"

echo "📝 Generating config.toml..."

cat > /app/config.toml << ENDCONFIG
[info]
relay_url = "${RELAY_URL}"
name = "${RELAY_NAME}"
description = "${RELAY_DESCRIPTION}"
pubkey = "${RELAY_PUBKEY}"
contact = "${RELAY_CONTACT}"

[database]
data_directory = "/app/db"

[network]
port = 8080
address = "127.0.0.1"

[limits]
messages_per_sec = 3
subscriptions_per_client = 10
max_event_bytes = 131072
max_ws_message_bytes = 131072

[retention]
max_events = 50000
max_event_age_days = 365

[logging]
folder = "/app/db"
level = "info"
ENDCONFIG

echo "✅ Config generated!"

echo "🌐 Starting nginx on port 80..."
nginx

echo "🗄️  Starting Nostr Relay on port 8080..."
exec /app/nostr-rs-relay --config /app/config.toml
