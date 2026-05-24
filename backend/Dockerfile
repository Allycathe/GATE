# node:20-alpine usa musl; @tensorflow/tfjs-node requiere glibc → usamos slim (debian)
FROM node:20-slim

# Dependencias de sistema: sharp (libvips), TF.js node (python/make/g++), zona horaria
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    make \
    g++ \
    libvips-dev \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

RUN mkdir -p uploads && chmod 777 uploads

EXPOSE 3000

CMD ["npm", "run", "dev"]
