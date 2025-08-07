import logging
import os
from logging.handlers import RotatingFileHandler

# Define log directory with absolute path
LOG_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "logs")

# Create logs directory if it doesn't exist
os.makedirs(LOG_DIR, exist_ok=True)

# Configure logger
def setup_logger():
    logger = logging.getLogger("doctor_api")
    logger.setLevel(logging.INFO)
    
    # Create formatter
    formatter = logging.Formatter(
        "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    )
    
    # Create console handler
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)
    
    # Create file handler for info level
    file_handler = RotatingFileHandler(
        os.path.join(LOG_DIR, "app.log"), 
        maxBytes=10485760,  # 10MB
        backupCount=5
    )
    file_handler.setFormatter(formatter)
    file_handler.setLevel(logging.INFO)
    logger.addHandler(file_handler)
    
    # Create file handler for errors
    error_file_handler = RotatingFileHandler(
        os.path.join(LOG_DIR, "error.log"), 
        maxBytes=10485760,  # 10MB
        backupCount=5
    )
    error_file_handler.setFormatter(formatter)
    error_file_handler.setLevel(logging.ERROR)
    logger.addHandler(error_file_handler)
    
    return logger

# Create logger instance
logger = setup_logger()
