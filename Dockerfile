# ---------- Stage 1: Build / venv ----------
FROM alpine:3.20 AS builder

LABEL org.opencontainers.image.source="local" \
      org.opencontainers.image.description="Secure Flask - Alpine builder"

ENV PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1

# Build deps only in builder
RUN apk add --no-cache \
      python3 python3-dev py3-pip build-base libffi-dev openssl-dev ca-certificates

# Isolated virtualenv so we copy only what we need later
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Faster, safer installs
COPY app/requirements.txt /tmp/requirements.txt
RUN pip install --upgrade --no-cache-dir pip setuptools wheel \
 && pip install --no-cache-dir -r /tmp/requirements.txt

# ---------- Stage 2: Runtime (tiny) ----------
FROM alpine:3.20

LABEL org.opencontainers.image.title="secure-flask" \
      org.opencontainers.image.vendor="you"

ENV PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1 \
    PATH="/opt/venv/bin:$PATH"

# Only runtime libs, no compilers
RUN apk add --no-cache \
      python3 libffi openssl ca-certificates \
  && addgroup -S app && adduser -S -G app app

WORKDIR /app

# Bring in just the venv and the app
COPY --from=builder /opt/venv /opt/venv
COPY app/ /app/

# Least-privilege
USER app

EXPOSE 5000
# Gunicorn = prod WSGI server; threads/workers kept small for demo
CMD ["gunicorn", "--workers", "2", "--threads", "4", "--bind", "0.0.0.0:5000", "app:app"]











# # ---------- Stage 1: Builder ----------
# FROM python:3.11-slim-bullseye AS builder

# # Metadata for traceability
# LABEL maintainer="priyanshuprafful@gmail.com"
# LABEL description="Secure Flask Web App - Production Ready Dockerfile"

# # Environment setup
# ENV PYTHONUNBUFFERED=1 \
#     PYTHONDONTWRITEBYTECODE=1 \
#     DEBIAN_FRONTEND=noninteractive

# # Update and install only essential dependencies
# RUN apt-get update && \
#     apt-get install -y --no-install-recommends build-essential gcc && \
#     rm -rf /var/lib/apt/lists/*

# # Create working directory
# WORKDIR /app

# # Install dependencies in a temporary path (for later copy)
# COPY app/requirements.txt .
# RUN pip install --user --no-cache-dir -r requirements.txt

# # ---------- Stage 2: Final runtime ----------
# FROM python:3.11-slim-bullseye

# # Create a non-root user for security
# RUN useradd -m appuser

# # Set environment variables
# ENV PYTHONUNBUFFERED=1 \
#     PYTHONDONTWRITEBYTECODE=1 \
#     PATH="/home/appuser/.local/bin:$PATH"

# # Set work directory
# WORKDIR /app

# # Copy only necessary files (not entire context)
# COPY --from=builder /root/.local /home/appuser/.local
# COPY app/ /app/

# # Change ownership to non-root user
# RUN chown -R appuser:appuser /app

# # Switch to non-root user
# USER appuser

# # Expose app port
# EXPOSE 5000

# # Run using Gunicorn (production-grade WSGI server)
# CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
