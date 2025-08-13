# syntax=docker/dockerfile:1
FROM python:3.11-slim

ENV PIP_NO_CACHE_DIR=1 \
    PATH="/root/.local/bin:${PATH}" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# System deps (git + build tools for any wheels)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates build-essential && \
    rm -rf /var/lib/apt/lists/*

# Workdir where we’ll mount the repo at runtime
WORKDIR /workspace

# Install requirements (copy first for layer caching; falls back if not present)
# If requirements.txt is not in build context, comment the next two lines and use the RUN pip install … line below.
COPY requirements.txt /tmp/requirements.txt
RUN python -m pip install --upgrade pip && pip install -r /tmp/requirements.txt

# If you prefer pinning inside the image without requirements.txt, uncomment:
# RUN python -m pip install --upgrade pip && \
#     pip install sigma-cli pysigma-backend-splunk pysigma-backend-kusto pysigma-backend-elasticsearch \
#                 pysigma-pipeline-windows pysigma-pipeline-sysmon

# Default entrypoint: show sigma help to confirm install
ENTRYPOINT ["sigma"]
CMD ["--help"]