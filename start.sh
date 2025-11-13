#!/bin/bash
set -e

echo "🔗 Nostr Relay Startup..."

# Config generieren
if [ ! -f /app/config.toml ]; then
  echo "📝 Generating config.toml..."
  
  # Whitelist-Pubkeys parsen (komma-getrennt zu array)
  if [ -n "$WHITELIST_PUBKEYS" ]; then
    PUBKEY_ARRAY=$(echo "$WHITELIST_PUBKEYS" | sed 's/,/", "/g' | sed 's/^/["/' | sed 's/$/"]/')
  else
    PUBKEY_ARRAY="[]"
  fi
  
  cat > /app/config.toml <<EOF
[info]
relay_url = "${RELAY_URL:-wss://localhost:8080}"
name = "${RELAY_NAME:-Steven's Nostr Relay}"
description = "${RELAY_DESCRIPTION:-Personal Nostr relay}"
pubkey = "${RELAY_PUBKEY:-}"
contact = "${RELAY_CONTACT:-steven@stevennoack.de}"

[database]
data_directory = "/app/db"

[network]
port = ${PORT:-8080}
address = "0.0.0.0"

[limits]
messages_per_sec = 3
subscriptions_per_client = 5
max_event_bytes = 65536
max_ws_message_bytes = 65536

[authorization]
pubkey_whitelist = []

[retention]
max_events = 10000
max_event_age_days = 90

[logging]
level = "info"

[verified_users]
mode = "whitelist"
verify_all = ${WHITELIST_MODE:-true}
pubkey_whitelist = ${PUBKEY_ARRAY}
EOF

  echo "✅ Config generated!"
  echo "🔐 Whitelist mode: ${WHITELIST_MODE:-true}"
  echo "📋 Whitelisted pubkeys: $WHITELIST_PUBKEYS"
fi

echo "🗄️  Starting Nostr Relay..."
exec /app/nostr-rs-relay --config /app/config.toml