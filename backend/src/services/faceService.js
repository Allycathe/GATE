const path = require('path');
const sharp = require('sharp');

let faceapi = null;
let tf = null;
let modelsLoaded = false;

const MODEL_PATH = path.join(__dirname, '../../node_modules/@vladmandic/face-api/model');

// Umbral de distancia euclidiana: < 0.5 mismo mechero, 0.5-0.6 probable, > 0.6 diferente
const SIMILARITY_THRESHOLD = 0.65;

async function init() {
  if (modelsLoaded) return;
  tf = require('@tensorflow/tfjs-node');
  faceapi = require('@vladmandic/face-api');
  await faceapi.nets.ssdMobilenetv1.loadFromDisk(MODEL_PATH);
  await faceapi.nets.faceLandmark68Net.loadFromDisk(MODEL_PATH);
  await faceapi.nets.faceRecognitionNet.loadFromDisk(MODEL_PATH);
  modelsLoaded = true;
  console.log('[FaceService] Modelos de reconocimiento facial cargados');
}

// Extrae descriptor de 128 dimensiones desde un buffer de imagen (WebP, JPEG, PNG)
async function extractDescriptor(imageBuffer) {
  await init();
  // TF.js node maneja JPEG/PNG nativamente; convertimos desde WebP con sharp
  const jpegBuf = await sharp(imageBuffer)
  .normalize()
  .sharpen()
  .jpeg({ quality: 95 })
  .toBuffer();
  const tensor = tf.node.decodeImage(jpegBuf, 3);
  try {
    const detection = await faceapi
      .detectSingleFace(tensor, new faceapi.SsdMobilenetv1Options({ minConfidence: 0.3 }))
      .withFaceLandmarks()
      .withFaceDescriptor();
    return detection ? Array.from(detection.descriptor) : null;
  } finally {
    tensor.dispose();
  }
}

function euclideanDistance(a, b) {
  return Math.sqrt(a.reduce((sum, v, i) => sum + (v - b[i]) ** 2, 0));
}

// Toma filas de BD con face_descriptor y devuelve las más similares al descriptor dado
function findSimilar(queryDescriptor, rows, threshold = SIMILARITY_THRESHOLD) {
  return rows
    .filter(row => row.face_descriptor)
    .map(row => {
      const stored = Array.isArray(row.face_descriptor)
        ? row.face_descriptor
        : JSON.parse(row.face_descriptor);
      const distance = euclideanDistance(queryDescriptor, stored);
      return { ...row, distance, face_descriptor: undefined };
    })
    .filter(r => r.distance < threshold)
    .sort((a, b) => a.distance - b.distance);
}

module.exports = { init, extractDescriptor, findSimilar, SIMILARITY_THRESHOLD };
