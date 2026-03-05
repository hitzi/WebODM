FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_MAJOR=20
ENV PYTHON_VERSION=3.9
ENV WORKDIR=/webodm
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/webodm
ENV PROJ_LIB=/usr/share/proj

WORKDIR /webodm

# System packages
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        build-essential \
        python3 \
        python3-dev \
        python3-pip \
        python3-venv \
        gdal-bin \
        libgdal-dev \
        proj-bin \
        proj-data \
        libproj-dev \
        tzdata && \
    rm -rf /var/lib/apt/lists/*

# timezone
RUN ln -snf /usr/share/zoneinfo/UTC /etc/localtime && \
    echo UTC > /etc/timezone

# NodeJS
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Python venv
RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"

# Python deps
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Node deps
COPY package.json package-lock.json* ./
RUN npm install --legacy-peer-deps

# copy source
COPY . .

# build frontend
#RUN npm run build

EXPOSE 8000

CMD ["bash", "start.sh"]
