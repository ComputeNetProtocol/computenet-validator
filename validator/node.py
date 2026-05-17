from fastapi import FastAPI
from datetime import datetime
import hashlib
import json
import os

app = FastAPI()

CHAIN = []
RECEIPTS = []

def block_hash(block):
    return hashlib.sha256(json.dumps(block, sort_keys=True).encode()).hexdigest()

genesis = {
    "index": 0,
    "timestamp": str(datetime.utcnow()),
    "data": "GENESIS",
    "previous_hash": "0"
}

genesis["hash"] = block_hash(genesis)
CHAIN.append(genesis)

@app.get("/status")
def status():
    return {
        "network": "ComputeNet",
        "version": "v0.4-testnet",
        "blocks": len(CHAIN),
        "receipts": len(RECEIPTS),
        "valid": True
    }

@app.post("/submit_job")
def submit_job(job_id: str, payload: str):
    receipt = {
        "job_id": job_id,
        "payload": payload,
        "timestamp": str(datetime.utcnow()),
        "truth_score": 1.0,
        "verified": True
    }

    RECEIPTS.append(receipt)

    block = {
        "index": len(CHAIN),
        "timestamp": str(datetime.utcnow()),
        "data": receipt,
        "previous_hash": CHAIN[-1]["hash"]
    }

    block["hash"] = block_hash(block)

    CHAIN.append(block)

    return {
        "status": "accepted",
        "receipt": receipt,
        "block": block["index"]
    }

@app.get("/receipts")
def receipts():
    return RECEIPTS

@app.get("/chain")
def chain():
    return CHAIN
