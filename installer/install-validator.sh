#!/usr/bin/env bash

set -e

echo ""
echo "======================================="
echo "      ComputeNet Validator Setup"
echo "======================================="
echo ""

echo "[1/7] Updating system..."
sudo apt update -y

echo "[2/7] Installing dependencies..."
sudo apt install -y python3 python3-pip python3-venv curl git

echo "[3/7] Creating ComputeNet directories..."
sudo mkdir -p /opt/computenet
sudo mkdir -p /etc/computenet
sudo mkdir -p /var/log/computenet

echo "[4/7] Installing validator runtime..."
sudo cp -R validator /opt/computenet/validator

cd /opt/computenet

python3 -m venv .venv

source .venv/bin/activate

pip install fastapi uvicorn

echo "[5/7] Generating validator identity..."

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

echo "[6/7] Installing systemd service..."

sudo tee /etc/systemd/system/computenet.service > /dev/null <<EOT
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

sudo systemctl daemon-reload

sudo systemctl enable computenet

sudo systemctl restart computenet

echo "[7/7] Installing ComputeNet CLI..."

sudo tee /usr/local/bin/computenet > /dev/null <<'EOT'
#!/usr/bin/env bash

case "$1" in
  status)
    curl -s http://127.0.0.1:8787/v011/telemetry
    ;;
  validator-id)
    cat /etc/computenet/validator.json
    ;;
  peers)
    curl -s http://127.0.0.1:8787/v011/manifest
    ;;
  *)
    echo "ComputeNet CLI"
    echo ""
    echo "Commands:"
    echo "  computenet status"
    echo "  computenet validator-id"
    echo "  computenet peers"
    ;;
esac
EOT

sudo chmod +x /usr/local/bin/computenet

echo ""
echo "======================================="
echo " ComputeNet Validator Installed"
echo "======================================="
echo ""
echo "Validator ID:"
cat /etc/computenet/validator.json
echo ""
echo "Test Commands:"
echo "  computenet status"
echo "  computenet peers"
echo ""
echo "Public Testnet v0.12"
echo "Mainnet NOT launched"
echo ""
