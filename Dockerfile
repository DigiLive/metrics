# Base image
FROM node:20-bookworm-slim

# Set apt to non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive
ENV PUPPETEER_SKIP_DOWNLOAD=true
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_BROWSER_PATH="google-chrome-stable"

# Copy repository
COPY . /metrics
WORKDIR /metrics

# Setup
RUN chmod +x /metrics/source/app/action/index.mjs \
  # Install latest chrome dev package, fonts to support major charsets and skip chromium download on puppeteer install
  # Based on https://github.com/GoogleChrome/puppeteer/blob/master/docs/troubleshooting.md#running-puppeteer-in-docker
  && apt-get update \
  && apt-get install -y wget gnupg ca-certificates libgconf-2-4 curl unzip \
  && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google.asc] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list' \
  && apt-get update \
  && apt-get install -y \
        google-chrome-stable \
        fonts-ipafont-gothic \
        fonts-wqy-zenhei \
        fonts-thai-tlwg \
        fonts-kacst \
        fonts-freefont-ttf \
        libxss1 \
        libx11-xcb1 \
        libxtst6 \
        lsb-release \
        build-essential \
        libxml2-dev \
        libxslt1-dev \
        ruby-full \
        git \
        g++ \
        cmake \
        pkg-config \
        libssl-dev \
        python3 \
  # Install deno for miscellaneous scripts
  && curl -fsSL https://deno.land/x/install/install.sh | DENO_INSTALL=/usr/local sh \
  # Install ruby gem (licensed) after all dependencies
  && gem install licensed --no-document --verbose \
  && echo "Gem installed" \
  && rm -rf /var/lib/apt/lists/* \
  && echo "Apt lists cleaned" \
  && npm ci --verbose \
  && echo "npm ci done" \
  && npm run build \
  && echo "npm run build done"

# Execute GitHub action
ENTRYPOINT node /metrics/source/app/action/index.mjs
