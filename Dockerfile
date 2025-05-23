# Use CUDA base image
FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04
# Check CUDA version compatibility
RUN nvidia-smi || true
ENV NVIDIA_REQUIRE_CUDA="cuda>=11.8"
ENV NVIDIA_DRIVER_MIN_VERSION="450.80.02"
# Set environment variables for NVIDIA GPU support
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libopenexr-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libgstreamer1.0-0 \
    libgstreamer-plugins-base1.0-0 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /app
WORKDIR /app

# 安装 Poetry 并禁用虚拟环境
ENV POETRY_VERSION=2.0.0
# Ensure pip is available, then install Poetry
RUN python3 -m pip install --upgrade pip \
    && pip install "poetry==$POETRY_VERSION" \
    && poetry config virtualenvs.create false
# Note: The PATH adjustment might still be needed depending on where pip installs poetry.
# The default path for user-installed binaries is often ~/.local/bin for the root user.
ENV PATH="/root/.local/bin:$PATH"

# 复制依赖文件
COPY pyproject.toml poetry.lock ./

# 安装应用依赖
RUN poetry install --no-root --only main

# 复制应用代码
COPY . .

EXPOSE 8501
CMD ["streamlit", "run", "smartvision/app.py", "--server.port=8501", "--server.address=0.0.0.0"]
