# 1. Usamos una imagen de Node estable y ligera
FROM node:20-alpine

# 2. Instalamos dependencias del sistema necesarias para Sharp y herramientas de red
# 'vips-dev' y 'fftw-dev' ayudan a Sharp a ser más rápido en entornos Linux
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    vips-dev \
    fftw-dev

# 3. Directorio de trabajo
WORKDIR /usr/src/app

# 4. Copiamos los archivos de dependencias
# Al copiar esto primero, Docker cachea las instalaciones y es más rápido
COPY package*.json ./

# 5. Instalamos las dependencias de Node
# Usamos 'npm install' para asegurar que se instalen tanto las dependencias 
# de producción como las de desarrollo (Nodemon, Knex)
RUN npm install

# 6. Copiamos el resto del código del backend
COPY . .

# 7. Creamos la carpeta de uploads por si no existe
RUN mkdir -p uploads && chmod 777 uploads

# 8. Exponemos el puerto de la API
EXPOSE 3000

# 9. Comando para arrancar en modo desarrollo
# Esto permite que Nodemon vigile tus cambios y Knex esté disponible
CMD ["npm", "run", "dev"]
