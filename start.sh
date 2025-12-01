#!/bin/bash
set -e

echo "🔗 Nostr Relay Startup..."

# Config generieren
echo "📝 Generating config.toml..."

# Variablen mit Defaults
RELAY_URL="${RELAY_URL:-wss://localhost:8080}"
RELAY_NAME="${RELAY_NAME:-My Nostr Relay}"
RELAY_DESCRIPTION="${RELAY_DESCRIPTION:-Personal Nostr relay}"
RELAY_PUBKEY="${RELAY_PUBKEY:-}"
RELAY_CONTACT="${RELAY_CONTACT:-}"
WHITELIST_MODE="${WHITELIST_MODE:-false}"
PORT="${PORT:-8080}"

# Config schreiben (ohne Heredoc um Bash-Probleme zu vermeiden)
cat > /app/config.toml << 'ENDCONFIG'
[info]
relay_url = "PLACEHOLDER_URL"
name = "PLACEHOLDER_NAME"
description = "PLACEHOLDER_DESC"
pubkey = "PLACEHOLDER_PUBKEY"
contact = "PLACEHOLDER_CONTACT"

[database]
data_directory = "/app/db"

[network]
port = PLACEHOLDER_PORT
address = "0.0.0.0"

[limits]
messages_per_sec = 3
subscriptions_per_client = 10
max_event_bytes = 131072
max_ws_message_bytes = 131072

[authorization]
pubkey_whitelist = []

[retention]
max_events = 50000
max_event_age_days = 365

[logging]
folder = "/app/db"
level = "info"
ENDCONFIG

# Variablen ersetzen
sed -i "s|PLACEHOLDER_URL|${RELAY_URL}|g" /app/config.toml
sed -i "s|PLACEHOLDER_NAME|${RELAY_NAME}|g" /app/config.toml
sed -i "s|PLACEHOLDER_DESC|${RELAY_DESCRIPTION}|g" /app/config.toml
sed -i "s|PLACEHOLDER_PUBKEY|${RELAY_PUBKEY}|g" /app/config.toml
sed -i "s|PLACEHOLDER_CONTACT|${RELAY_CONTACT}|g" /app/config.toml
sed -i "s|PLACEHOLDER_PORT|${PORT}|g" /app/config.toml

echo "✅ Config generated!"
cat /app/config.toml

echo "🗄️  Starting Nostr Relay on port ${PORT}..."
exec /app/nostr-rs-relay --config /app/config.toml