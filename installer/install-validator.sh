#!/usr/bin/env bash

set -e

echo ""
echo "======================================="
echo "      ComputeNet Validator Setup"
echo "======================================="
echo ""

TMP_DIR=$(mktemp -d)

cd "$TMP_DIR"

echo "[1/8] Cloning ComputeNet validator repo..."

git clone https://github.com/ComputeNetProtocol/computenet-validator.git

cd computenet-validator

echo "[2/8] Updating system..."

apt update -y

echo "[3/8] Installing dependencies..."

apt install -y python3 python3-pip python3-venv curl git

echo "[4/8] Creating ComputeNet directories..."

mkdir -p /opt/computenet
mkdir -p /etc/computenet
mkdir -p /var/log/computenet

echo "[5/8] Installing validator runtime..."

cp -R validator /opt/computenet/validator

cd /opt/computenet

python3 -m venv .venv

source .venv/bin/activate

pip install --upgrade pip

pip install fastapi uvicorn

echo "[6/8] Generating validator identity..."

VALIDATOR_ID=$(openssl rand -hex 8)

cat > /etc/computenet/validator.json <<EOT
{
  "validator_id": "validator_$VALIDATOR_ID",
  "network": "ComputeNet",
  "version": "v0.12",
  "role": "validator",
  "bootstrap_peers": [
    "http://178.62.15.134:8787",
    "http://138.68.134.235:8787",
    "http://46.101.39.92:8787"
  ]
}
EOT

echo "[7/8] Installing systemd service..."

cat > /etc/systemd/system/computenet.service <<EOT
[Unit]
Description=ComputeNet Validator
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/computenet
ExecStart=/opt/computenet/.venv/bin/python -m uvicorn validator.node:app --host 0.0.0.0 --port 8787
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload

systemctl enable computenet

systemctl restart computenet

echo "[8/8] Installing ComputeNet CLI..."

cat > /usr/local/bin/computenet <<'EOT'
#!/usr/bin/env bash

case "$1" in
  status)
    curl -s http://127.0.0.1:8787/status
    ;;
  chain)
    curl -s http://127.0.0.1:8787/chain
    ;;
  receipts)
    curl -s http://127.0.0.1:8787/receipts
    ;;
  validator-id)
    cat /etc/computenet/validator.json
    ;;
  *)
    echo "ComputeNet CLI"
    echo ""
    echo "Commands:"
    echo "  computenet status"
    echo "  computenet chain"
    echo "  computenet receipts"
    echo "  computenet validator-id"
    ;;
esac
EOT

chmod +x /usr/local/bin/computenet

echo ""
echo "======================================="
echo " ComputeNet Validator Installed"
echo "======================================="
echo ""

computenet status
