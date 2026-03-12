# Use an official Python runtime as a parent image
FROM python:3.10-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PORT 7860

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY backend/requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy project
COPY backend/ /app/

# Collect static files
RUN python manage.py collectstatic --noinput

# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos '' myuser
USER myuser

# Start the application
CMD gunicorn core.wsgi:application --bind 0.0.0.0:$PORT
