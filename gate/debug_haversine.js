const { Pool } = require('pg');
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

async function debug() {
  // Simular alerta desde supermercado id=1 (Líder Alameda, Santiago)
  const REPORT_SUPERMARKET_ID = 1;
  const RADIUS_KM = 10;

  console.log('=== DEBUG NOTIFICACIONES ===\n');

  // 1. Centro de la alerta
  const centerResult = await pool.query(
    'SELECT id, name, latitude AS lat, longitude AS lon FROM supermarket WHERE id = $1',
    [REPORT_SUPERMARKET_ID]
  );
  const center = centerResult.rows[0];
  console.log(`📍 Centro: ${center.name} (lat=${center.lat}, lon=${center.lon})\n`);

  // 2. Todos los supermercados con distancia
  const allSm = await pool.query(
    'SELECT id, name, latitude AS lat, longitude AS lon FROM supermarket'
  );

  console.log(`📊 Distancias desde ${center.name} (radio=${RADIUS_KM}km):`);
  const nearbySmIds = [];
  allSm.rows.forEach(sm => {
    const dist = haversine(center.lat, center.lon, sm.lat, sm.lon);
    const dentro = dist <= RADIUS_KM;
    if (dentro) nearbySmIds.push(sm.id);
    console.log(`  ${dentro ? '✅' : '❌'} [id=${sm.id}] ${sm.name}: ${dist.toFixed(2)} km ${dentro ? '<-- DENTRO' : ''}`);
  });

  console.log(`\n🎯 Supermercados dentro del radio: [${nearbySmIds.join(', ')}]\n`);

  // 3. Usuarios con FCM token en esos supermercados
  const usersResult = await pool.query(
    `SELECT id, name, last_name, email, id_supermarket, 
            CASE WHEN fcm_token IS NOT NULL THEN 'SÍ' ELSE 'NO' END AS tiene_token
     FROM users
     WHERE id_supermarket = ANY($1::int[])`,
    [nearbySmIds]
  );

  console.log(`👥 Usuarios en supermercados cercanos (${usersResult.rowCount} total):`);
  usersResult.rows.forEach(u => {
    console.log(`  [id=${u.id}] ${u.email} — super_id=${u.id_supermarket} — FCM: ${u.tiene_token}`);
  });

  // 4. Solo los que tienen token
  const conToken = usersResult.rows.filter(u => u.tiene_token === 'SÍ');
  console.log(`\n📲 Recibirían notificación: ${conToken.length} usuario(s)`);
  conToken.forEach(u => console.log(`  → ${u.email} (super_id=${u.id_supermarket})`));

  // 5. Verificar usuario de Arica específicamente
  console.log('\n=== VERIFICACIÓN USUARIO ARICA ===');
  const aricaResult = await pool.query(
    `SELECT u.id, u.email, u.id_supermarket, s.name AS super_name,
            s.latitude, s.longitude,
            CASE WHEN u.fcm_token IS NOT NULL THEN 'SÍ' ELSE 'NO' END AS tiene_token
     FROM users u
     JOIN supermarket s ON s.id = u.id_supermarket
     WHERE u.email = 'arica_test@mail.com'`
  );
  if (aricaResult.rowCount === 0) {
    console.log('⚠️  Usuario arica_test@mail.com no encontrado');
  } else {
    const u = aricaResult.rows[0];
    const dist = haversine(center.lat, center.lon, u.latitude, u.longitude);
    console.log(`Usuario: ${u.email}`);
    console.log(`Supermercado: ${u.super_name} (lat=${u.latitude}, lon=${u.longitude})`);
    console.log(`Distancia a ${center.name}: ${dist.toFixed(2)} km`);
    console.log(`Dentro del radio de ${RADIUS_KM}km: ${dist <= RADIUS_KM ? '❌ SÍ (BUG)' : '✅ NO (correcto)'}`);
    console.log(`Tiene FCM token: ${u.tiene_token}`);
  }

  await pool.end();
}

debug().catch(console.error);
