import json
import hashlib
import time
import uuid
from pathlib import Path

RECEIPT_DIR = Path("receipts")
RECEIPT_DIR.mkdir(exist_ok=True)

def sha256(data):
    return hashlib.sha256(data.encode()).hexdigest()

def generate_receipt(workload, validator_id="validator-local"):
    timestamp = int(time.time())

    payload = {
        "receipt_id": str(uuid.uuid4()),
        "timestamp": timestamp,
        "validator": validator_id,
        "workload_hash": sha256(workload),
        "truth_score": 1.0,
        "verified": True,
    }

    payload_string = json.dumps(payload, sort_keys=True)
    payload["signature"] = sha256(payload_string)

    output = RECEIPT_DIR / f"{payload['receipt_id']}.json"

    with open(output, "w") as f:
        json.dump(payload, f, indent=2)

    return payload

if __name__ == "__main__":
    receipt = generate_receipt("demo workload")
    print(json.dumps(receipt, indent=2))
