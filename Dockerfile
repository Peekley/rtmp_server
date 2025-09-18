# Stage 1: Build FFmpeg
FROM ubuntu:22.04 AS ffmpeg-builder

# Install build dependencies for FFmpeg
RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    wget \
    yasm \
    nasm \
    && rm -rf /var/lib/apt/lists/*

# Download and build FFmpeg
WORKDIR /usr/src
RUN wget https://ffmpeg.org/releases/ffmpeg-7.0.2.tar.bz2 && \
    tar -xjf ffmpeg-7.0.2.tar.bz2 && \
    cd ffmpeg-7.0.2 && \
    ./configure --enable-gpl --enable-nonfree && \
    make -j$(nproc) && \
    make install

# Stage 2: Build Elixir application
FROM elixir:1.17.2-slim AS app-builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Hex and Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set working directory
WORKDIR /app

# Copy mix.exs and mix.lock
COPY mix.exs mix.lock ./

# Install dependencies
RUN mix deps.get && mix deps.compile

# Copy the rest of the application code
COPY . .

# Compile the application
RUN mix compile

# Build release
ENV MIX_ENV=prod
RUN mix release

# Stage 3: Final image
FROM ubuntu:22.04

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy FFmpeg from ffmpeg-builder stage
COPY --from=ffmpeg-builder /usr/local/bin/ffmpeg /usr/local/bin/
COPY --from=ffmpeg-builder /usr/local/lib /usr/local/lib

# Set environment variable for FFmpeg
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# Copy the release from app-builder stage
COPY --from=app-builder /app/_build/prod/rel/rtmp_server /app

# Copy .env file (optional, can be mounted at runtime)
COPY .env /app/.env

# Set working directory
WORKDIR /app

# Expose ports for RTMP, RTMPS, and HLS
EXPOSE 1935 1936 80

# Ensure FFmpeg is in PATH
RUN ln -s /usr/local/bin/ffmpeg /usr/bin/ffmpeg

# Start the application
CMD ["/app/bin/rtmp_server", "start"]