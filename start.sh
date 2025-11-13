#!/bin/bash
set -e

echo "🔗 Nostr Relay Startup..."

# Config generieren falls nicht vorhanden
if [ ! -f /app/config.toml ]; then
  echo "📝 Generating config.toml..."
  
  cat > /app/config.toml <<EOF
[info]
relay_url = "${RELAY_URL:-wss://localhost:8080}"
name = "${RELAY_NAME:-Steven's Nostr Relay}"
description = "${RELAY_DESCRIPTION:-Personal Nostr relay - part of Creator Freedom movement}"
pubkey = "${RELAY_PUBKEY:-}"
contact = "${RELAY_CONTACT:-steven@stevennoack.de}"

[database]
data_directory = "/app/db"

[network]
port = ${PORT:-8080}
address = "0.0.0.0"

[limits]
messages_per_sec = 10
subscriptions_per_client = 10
max_event_bytes = 131072
max_ws_message_bytes = 131072

[authorization]
pubkey_whitelist = []

[retention]
max_events = 50000
max_event_age_days = 365

[logging]
level = "info"

[verified_users]
mode = "whitelist"
verify_all = ${VERIFY_ALL:-true}
EOF

  echo "✅ Config generated!"
fi

echo "🗄️  Starting Nostr Relay..."
exec /app/nostr-rs-relay --config /app/config.toml
```

---

### **3. .gitignore**
```
db/
config.toml
*.log
.env