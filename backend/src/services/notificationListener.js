const { Client } = require('pg');
const { Pool } = require('pg');
const { initializeApp, cert } = require('firebase-admin/app');
const { getMessaging } = require('firebase-admin/messaging');
const serviceAccount = require('../../firebase-service-account.json');

initializeApp({ credential: cert(serviceAccount) });

// Pool separado para queries dentro del listener
const pool = new Pool({ connectionString: process.env.DATABASE_URL });

function haversine(lat1, lon1, lat2, lon2) {
  const R = 6371;
  const toRad = (x) => (x * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

async function startListener() {
  const client = new Client({ connectionString: process.env.DATABASE_URL });
  await client.connect();
  await client.query('LISTEN nuevo_evento');
  console.log('📡 Escuchando canal: nuevo_evento');

  client.on('notification', async (msg) => {
    const alerta = JSON.parse(msg.payload);
    console.log('🔔 Crime alert recibida:', alerta);
    await notifyNearbyUsers(alerta);
  });

  client.on('error', (err) => {
    console.error('Error en listener PG:', err);
    setTimeout(startListener, 5000);
  });
}

async function notifyNearbyUsers(alerta) {
  // 1. Coordenadas del supermercado centro de la alerta
  const centerResult = await pool.query(
    'SELECT latitude AS lat, longitude AS lon FROM supermarket WHERE id = $1',
    [alerta.center_supermarket_id]
  );
  if (centerResult.rowCount === 0) return;
  const center = centerResult.rows[0];

  // 2. Todos los supermercados con sus coordenadas
  const allSm = await pool.query(
    'SELECT id, latitude AS lat, longitude AS lon FROM supermarket'
  );

  // 3. Filtrar supermercados dentro del radio
  const nearbySmIds = allSm.rows
    .filter((sm) => haversine(center.lat, center.lon, sm.lat, sm.lon) <= alerta.radius_km)
    .map((sm) => sm.id);

  if (nearbySmIds.length === 0) return;

  // 4. Obtener FCM tokens de usuarios en esos supermercados
  const usersResult = await pool.query(
    `SELECT fcm_token FROM users 
     WHERE id_supermarket = ANY($1::int[]) 
     AND fcm_token IS NOT NULL`,
    [nearbySmIds]
  );

  const tokens = usersResult.rows.map((u) => u.fcm_token);
  if (tokens.length === 0) {
    console.log('⚠️ No hay usuarios con FCM token en el radio');
    return;
  }

  // 5. Enviar notificación a cada token
  const message = {
    notification: {
      title: '⚠️ Alerta delictual cercana',
      body: `Se detectaron ${alerta.report_count} reportes en un radio de ${alerta.radius_km} km`,
    },
    data: {
      crime_alert_id: String(alerta.id),
      report_count: String(alerta.report_count),
      radius_km: String(alerta.radius_km),
    },
    tokens,
  };

  try {
    const response = await getMessaging().sendEachForMulticast(message);
    console.log(`✅ Notificaciones enviadas: ${response.successCount}/${tokens.length}`);
    if (response.failureCount > 0) {
      response.responses.forEach((r, i) => {
        if (!r.success) console.error(`❌ Token ${i} falló:`, r.error?.message);
      });
    }
  } catch (err) {
    console.error('❌ Error enviando notificaciones:', err);
  }
}

module.exports = { startListener };