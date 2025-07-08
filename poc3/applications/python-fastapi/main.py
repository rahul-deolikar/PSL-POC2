from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from datetime import datetime
import os

app = FastAPI(
    title="Python FastAPI Hello World",
    description="Hello World API for TeamCity CI/CD Pipeline",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class HelloResponse(BaseModel):
    message: str
    version: str
    timestamp: str
    technology: str

class HealthResponse(BaseModel):
    status: str
    timestamp: str
    service: str

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint"""
    return HealthResponse(
        status="healthy",
        timestamp=datetime.now().isoformat(),
        service="python-fastapi-hello-world"
    )

@app.get("/api/hello", response_model=HelloResponse)
async def hello_world():
    """Hello World API endpoint"""
    return HelloResponse(
        message="Hello World from Python FastAPI!",
        version="1.0.0",
        timestamp=datetime.now().isoformat(),
        technology="Python + FastAPI"
    )

@app.get("/api/hello/{name}", response_model=HelloResponse)
async def hello_name(name: str):
    """Personalized hello message"""
    if not name or name.strip() == "":
        raise HTTPException(status_code=400, detail="Name cannot be empty")
    
    return HelloResponse(
        message=f"Hello {name} from Python FastAPI!",
        version="1.0.0",
        timestamp=datetime.now().isoformat(),
        technology="Python + FastAPI"
    )

@app.get("/")
async def root():
    """Root endpoint with API information"""
    return {
        "service": "Python FastAPI Hello World API",
        "version": "1.0.0",
        "endpoints": [
            "GET /health - Health check",
            "GET /api/hello - Hello World message",
            "GET /api/hello/{name} - Personalized hello message",
            "GET /docs - API documentation"
        ]
    }

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)