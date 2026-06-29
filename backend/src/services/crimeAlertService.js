// Haversine: distancia en km entre dos puntos lat/lon
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

async function evaluateCrimeAlert(pool, newReport, options = {}) {
  const { radiusKm = 10, windowHours = 1, minReports = 2 } = options;

  const smResult = await pool.query(
    'SELECT id, latitude AS lat, longitude AS lon FROM supermarket WHERE id = $1',
    [newReport.id_supermarket]
  );
  if (smResult.rowCount === 0) return null;
  const center = smResult.rows[0];

  const allSm = await pool.query(
    'SELECT id, latitude AS lat, longitude AS lon FROM supermarket'
  );
  const nearbySmIds = allSm.rows
    .filter((sm) => haversine(center.lat, center.lon, sm.lat, sm.lon) <= radiusKm)
    .map((sm) => sm.id);

  if (nearbySmIds.length === 0) return null;

  const since = new Date(Date.now() - windowHours * 60 * 60 * 1000);
  const recentResult = await pool.query(
    `SELECT id FROM report
     WHERE id_supermarket = ANY($1::int[])
       AND date >= $2
       AND id != $3`,
    [nearbySmIds, since, newReport.id]
  );

  const allReportIds = [newReport.id, ...recentResult.rows.map((r) => r.id)];

  if (allReportIds.length < minReports) return null;

  const alertResult = await pool.query(
    `INSERT INTO crime_alert
       (center_supermarket_id, radius_km, time_window_h, report_count, report_ids)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING *`,
    [center.id, radiusKm, windowHours, allReportIds.length, allReportIds]
  );

  return alertResult.rows[0];
}

async function notifyNearbyGuards(pool, newReport, messaging, options = {}) {
  const { radiusKm = 10 } = options;

  // 1. Coordenadas del supermercado del reporte
  const smResult = await pool.query(
    'SELECT id, name, latitude AS lat, longitude AS lon FROM supermarket WHERE id = $1',
    [newReport.id_supermarket]
  );
  if (smResult.rowCount === 0) return;
  const center = smResult.rows[0];

  console.log(`[NearbyGuards] Centro: ${center.name} lat=${center.lat} lon=${center.lon} radio=${radiusKm}km`);

  // 2. Supermercados dentro del radio
  const allSm = await pool.query(
    'SELECT id, name, latitude AS lat, longitude AS lon FROM supermarket'
  );

  allSm.rows.forEach(sm => {
    const dist = haversine(center.lat, center.lon, sm.lat, sm.lon);
    console.log(`[NearbyGuards] id=${sm.id} "${sm.name}" dist=${dist.toFixed(2)}km -> ${dist <= radiusKm ? 'DENTRO' : 'fuera'}`);
  });

  const nearbySmIds = allSm.rows
    .filter((sm) => haversine(center.lat, center.lon, sm.lat, sm.lon) <= radiusKm)
    .map((sm) => sm.id);

  console.log(`[NearbyGuards] Supermercados dentro del radio: [${nearbySmIds.join(', ')}]`);

  if (nearbySmIds.length === 0) return;

  // 3. FCM tokens de usuarios en esos supermercados
  const usersResult = await pool.query(
    `SELECT id, email, id_supermarket, fcm_token FROM users
     WHERE id_supermarket = ANY($1::int[])
     AND fcm_token IS NOT NULL`,
    [nearbySmIds]
  );

  console.log(`[NearbyGuards] Usuarios con token en radio: ${usersResult.rowCount}`);
  usersResult.rows.forEach(u => {
    console.log(`[NearbyGuards]   -> id=${u.id} ${u.email} super_id=${u.id_supermarket} token=${u.fcm_token.slice(0, 20)}...`);
  });

  const tokens = usersResult.rows.map((u) => u.fcm_token);
  if (tokens.length === 0) {
    console.log('[NearbyGuards] No hay usuarios con FCM token en el radio');
    return;
  }

  // 4. Enviar notificacion
  const message = {
    notification: {
      title: 'Mechero detectado cerca',
      body: `Nuevo reporte en supermercado ${center.name} - radio ${radiusKm} km`,
    },
    data: {
      report_id: String(newReport.id),
      supermarket_id: String(newReport.id_supermarket),
      type: 'nearby_thief',
    },
    tokens,
  };

  try {
    const response = await messaging.sendEachForMulticast(message);
    console.log(`[NearbyGuards] ${response.successCount}/${tokens.length} notificaciones enviadas`);
  } catch (err) {
    console.error('[NearbyGuards] Error enviando notificaciones:', err.message);
  }
}

module.exports = { evaluateCrimeAlert, notifyNearbyGuards };