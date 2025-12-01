#!/bin/bash
set -e

echo "🔗 Nostr Relay Startup..."

# Variablen mit Defaults
RELAY_URL="${RELAY_URL:-wss://localhost:8080}"
RELAY_NAME="${RELAY_NAME:-My Nostr Relay}"
RELAY_DESCRIPTION="${RELAY_DESCRIPTION:-Personal Nostr relay}"
RELAY_PUBKEY="${RELAY_PUBKEY:-}"
RELAY_CONTACT="${RELAY_CONTACT:-}"
WHITELIST_MODE="${WHITELIST_MODE:-false}"
PORT="${PORT:-8080}"

# Config IMMER neu generieren
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
port = ${PORT}
address = "0.0.0.0"

[limits]
messages_per_sec = 3
subscriptions_per_client = 10
max_event_bytes = 131072
max_ws_message_bytes = 131072

[authorization]
ENDCONFIG

# Whitelist nur hinzufügen wenn WHITELIST_MODE=true
if [ "${WHITELIST_MODE}" = "true" ] && [ -n "${RELAY_PUBKEY}" ]; then
    echo "🔒 Whitelist mode: only ${RELAY_PUBKEY} can post"
    echo "pubkey_whitelist = [\"${RELAY_PUBKEY}\"]" >> /app/config.toml
else
    echo "🌐 Public mode: anyone can post"
    echo "pubkey_whitelist = []" >> /app/config.toml
fi

cat >> /app/config.toml << ENDCONFIG

[retention]
max_events = 50000
max_event_age_days = 365

[logging]
folder = "/app/db"
level = "info"
ENDCONFIG

echo "✅ Config generated!"
cat /app/config.toml

echo "🗄️  Starting Nostr Relay on port ${PORT}..."
exec /app/nostr-rs-relay --config /app/config.toml