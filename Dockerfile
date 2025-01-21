# Use a lightweight Python image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy application code
COPY app.py /app/

# Install dependencies
RUN pip install flask

# Expose the port Flask will run on
EXPOSE 5000

# Start the Flask application
CMD ["python", "app.py"]

