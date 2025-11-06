# ---------- Stage 1: Builder ----------
FROM python:3.11-slim-bullseye AS builder

# Metadata for traceability
LABEL maintainer="priyanshuprafful@gmail.com"
LABEL description="Secure Flask Web App - Production Ready Dockerfile"

# Environment setup
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    DEBIAN_FRONTEND=noninteractive

# Update and install only essential dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential gcc && \
    rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /app

# Install dependencies in a temporary path (for later copy)
COPY app/requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# ---------- Stage 2: Final runtime ----------
FROM python:3.11-slim-bullseye

# Create a non-root user for security
RUN useradd -m appuser

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/home/appuser/.local/bin:$PATH"

# Set work directory
WORKDIR /app

# Copy only necessary files (not entire context)
COPY --from=builder /root/.local /home/appuser/.local
COPY app/ /app/

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose app port
EXPOSE 5000

# Run using Gunicorn (production-grade WSGI server)
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
