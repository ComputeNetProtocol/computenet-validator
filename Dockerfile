FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

COPY . .

RUN pip install --no-cache-dir fastapi uvicorn requests pydantic

ENV PYTHONUNBUFFERED=1

EXPOSE 8787
EXPOSE 8788
EXPOSE 8899

CMD ["uvicorn", "validator.node:app", "--host", "0.0.0.0", "--port", "8787"]
