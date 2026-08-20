# Use a stable, production-ready Python image with an updated Debian base (Bookworm)
FROM python:3.11-slim-bookworm

# Set work directory
WORKDIR /app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies securely and clean up to keep the image small
RUN apt-get update && apt-get install --no-install-recommends -y \
    dnsutils \
    libpq-dev \
    gcc \
    python3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip to the latest secure version
RUN python -m pip install --no-cache-dir --upgrade pip

# Copy and install Python requirements (utilizing Docker layer caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the project files
COPY . .

# Expose the application port
EXPOSE 8000

# Run migrations and start Gunicorn (using standard syntax)
RUN python manage.py migrate
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "6", "pygoat.wsgi"]
