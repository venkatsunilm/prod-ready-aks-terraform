# Stage 1: Base image for installing dependencies
FROM python:3.13-alpine AS builder

# Set the working directory
WORKDIR /app

# Install necessary build dependencies for Python packages
RUN apk add --no-cache gcc musl-dev libffi-dev

# Copy only the requirements file to leverage Docker layer caching
COPY requirements.txt .

# Upgrade pip to the latest version first
RUN pip install --upgrade pip

# Install the required dependencies in the builder stage
RUN pip install --no-cache-dir -r requirements.txt


# Stage 2: Final image
FROM python:3.13-alpine AS final

# Install bash in the final image
RUN apk add --no-cache bash

# Set the working directory
WORKDIR /app

# Copy the application code from the host to the container
COPY . .

# Copy the installed dependencies from the builder stage to the final image
COPY --from=builder /usr/local/lib/python3.13/site-packages /usr/local/lib/python3.13/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Expose port 8000 for the app to run on
EXPOSE 8000

# Command to run the Flask app using Gunicorn
CMD ["bash", "startup.txt"]
