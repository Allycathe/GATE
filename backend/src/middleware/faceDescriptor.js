const { extractDescriptor } = require('../services/faceService');

// Debe ir después de compressImage en la cadena de middleware
// Lee req.imageBuffer y escribe req.faceDescriptor (array de 128 floats) o null si no hay cara
module.exports = async (req, res, next) => {
  req.faceDescriptor = null;
  if (!req.imageBuffer) return next();
  try {
    req.faceDescriptor = await extractDescriptor(req.imageBuffer);
    if (!req.faceDescriptor) {
      console.warn('[faceDescriptor] No se detectó ningún rostro en la imagen');
    }
  } catch (err) {
    console.error('[faceDescriptor] Error al procesar imagen:', err.message);
  }
  next();
};
