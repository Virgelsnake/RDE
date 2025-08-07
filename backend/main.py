from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
import time
from logger import logger

app = FastAPI(
    title="Doctor API",
    description="A simple FastAPI application with a health check endpoint",
    version="0.1.0"
)

# Add CORS middleware to allow requests from the Flutter web app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

# Add middleware to log requests
@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time.time()
    
    # Log the request
    logger.info(f"Request started: {request.method} {request.url.path}")
    
    # Process the request
    response = await call_next(request)
    
    # Calculate processing time
    process_time = time.time() - start_time
    logger.info(f"Request completed: {request.method} {request.url.path} - Status: {response.status_code} - Time: {process_time:.4f}s")
    
    return response

@app.get("/health")
async def health_check():
    """
    Health check endpoint to verify the API is running properly.
    """
    logger.info("Health check endpoint called")
    return {"status": "ok"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
