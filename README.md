# ComputeNet Validator

Validator software for the ComputeNet public research testnet.

Responsibilities:
- verify compute receipts
- replay workloads
- sign attestations
- propagate proofs
- participate in validator consensus

Current Status:
- Testnet only
- Non-economic
- Experimental

## Public Docker Validator

Launch a ComputeNet validator instantly:

```bash
docker pull ghcr.io/computenetprotocol/validator:latest

docker run -p 8787:8787 ghcr.io/computenetprotocol/validator:latest
