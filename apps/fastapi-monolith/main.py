from fastapi import FastAPI
import uvicorn
import socket

app = FastAPI()

@app.get("/")
def read_root():
    return {
        "status": "online",
        "hostname": socket.gethostname(),
        "message": "Hello from AWS SAA Lab 3!",
        "architecture": "EC2 Monolith"
    }

@app.get("/health")
def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=80)
