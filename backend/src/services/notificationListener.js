const { Client } = require('pg');
const { initializeApp, cert } = require('firebase-admin/app');
const { getMessaging } = require('firebase-admin/messaging');
const serviceAccount = require('../../firebase-service-account.json');

initializeApp({
  credential: cert(serviceAccount),
});

async function startListener() {
  const client = new Client({ connectionString: process.env.DATABASE_URL });
  await client.connect();

  await client.query('LISTEN nuevo_evento');
  console.log('📡 Escuchando canal: nuevo_evento');

  client.on('notification', async (msg) => {
    const payload = JSON.parse(msg.payload);
    console.log('🔔 Evento recibido:', payload);
    await sendBroadcast(payload);
  });

  client.on('error', (err) => {
    console.error('Error en listener PG:', err);
    setTimeout(startListener, 5000);
  });
}

async function sendBroadcast(evento) {
  const message = {
    notification: {
      title: `Nuevo evento: ${evento.tipo ?? 'Alerta'}`,
      body: evento.descripcion ?? JSON.stringify(evento),
    },
    topic: 'alertas',
  };

  try {
    const response = await getMessaging().send(message);
    console.log('✅ Notificación enviada:', response);
  } catch (err) {
    console.error('❌ Error enviando notificación:', err);
  }
}

module.exports = { startListener };