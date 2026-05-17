const sharp = require('sharp');

const compressImage = async (req, res, next) => {
  if (!req.body.image) return next();

  try {
    // La imagen llega como base64 desde el cliente
    const base64Data = req.body.image.replace(/^data:image\/\w+;base64,/, '');
    const buffer = Buffer.from(base64Data, 'base64');

    const compressed = await sharp(buffer)
      .resize(800, 800, {         // Máximo 800x800px
        fit: 'inside',            // Mantiene proporción
        withoutEnlargement: true  // No agranda imágenes pequeñas
      })
      .webp({ quality: 70 })      // Convierte a WebP, el formato más eficiente
      .toBuffer();

    // Sobreescribe el campo image con el buffer comprimido
    req.imageBuffer = compressed;
    next();
  } catch (err) {
    console.error('Error al comprimir imagen:', err);
    res.status(400).json({ error: 'Imagen inválida o corrupta' });
  }
};

module.exports = compressImage;