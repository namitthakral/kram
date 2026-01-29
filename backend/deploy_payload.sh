#!/bin/bash
set -e

# Setup directories
mkdir -p ~/kram
cd ~/kram

# Create venv if not exists
if [ ! -d "venv" ]; then
    echo "Creating venv..."
    sudo DEBIAN_FRONTEND=noninteractive apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3-venv python3-pip
    python3 -m venv venv
fi

# Install dependencies
echo "Installing dependencies..."
./venv/bin/pip install --upgrade pip
./venv/bin/pip install fastapi uvicorn requests python-multipart

# Write main.py
echo "Writing main.py..."
cat <<'PYTHON_EOF' > main.py
from fastapi import FastAPI, HTTPException, Request
from pydantic import BaseModel
import requests
import uvicorn
import logging
import os
from typing import List, Optional, Any

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()

OLLAMA_URL = 'http://localhost:11434/api/chat'
MODEL_NAME = 'llama3'

class ChatRequest(BaseModel):
    message: str
    conversationHistory: Optional[List[dict]] = []

@app.get('/health')
async def health_check():
    return {'status': 'ok', 'service': 'kram-ai'}

@app.post('/ai/chat')
async def chat(request: ChatRequest):
    try:
        history = request.conversationHistory or []
        messages = []
        for msg in history:
            role = msg.get('role', 'user')
            if role not in ['user', 'assistant', 'system']: role = 'user'
            messages.append({'role': role, 'content': msg.get('content', '')})
        messages.append({'role': 'user', 'content': request.message})
        
        payload = {'model': MODEL_NAME, 'messages': messages, 'stream': False}
        logger.info(f'Sending to Ollama: {payload}')
        
        response = requests.post(OLLAMA_URL, json=payload)
        response.raise_for_status()
        data = response.json()
        
        response_text = data.get('message', {}).get('content', '')
        return {'response': response_text}
    except Exception as e:
        logger.error(f'Error: {e}')
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == '__main__':
    uvicorn.run(app, host='0.0.0.0', port=9001)
PYTHON_EOF

# Write start.sh
echo "Writing start.sh..."
cat <<'SH_EOF' > start.sh
#!/bin/bash
cd ~/kram
# Kill existing process if any
pkill -f "python3 main.py" || true
./venv/bin/python3 main.py >> kram.log 2>&1 &
echo $! > kram.pid
echo "Service started."
SH_EOF
chmod +x start.sh

# Run start.sh
echo "Starting service..."
./start.sh
sleep 2
# Verify
if pgrep -f "python3 main.py" > /dev/null; then
    echo "SUCCESS: Service is running."
else
    echo "ERROR: Service failed to start. Check kram.log:"
    cat kram.log
    exit 1
fi
