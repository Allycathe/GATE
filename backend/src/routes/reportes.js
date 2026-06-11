const express = require('express');
const auth = require('../middleware/auth');
const compressImage = require('../middleware/compressImage');
const isAdmin = require('../middleware/isAdmin');
const faceDescriptor = require('../middleware/faceDescriptor');
const { extractDescriptor, findSimilar } = require('../services/faceService');
const { evaluateCrimeAlert, notifyNearbyGuards } = require('../services/crimeAlertService');
const { getMessaging } = require('firebase-admin/messaging');

module.exports = (pool) => {
  const router = express.Router();

  // 1. LISTAR TODOS LOS REPORTES
  router.get('/', auth, async (req, res) => {
    try {
      const result = await pool.query(
        'SELECT id, nombre_sospechoso, description, date, id_supermarket, id_user FROM report ORDER BY id DESC'
      );
      res.json(result.rows);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Error al obtener reportes' });
    }
  });

  // 2. OBTENER UN REPORTE POR ID
  router.get('/:id', auth, async (req, res) => {
    const { id } = req.params;
    try {
      const result = await pool.query(
        'SELECT id, nombre_sospechoso, description, date, id_supermarket FROM report WHERE id = $1',
        [id]
      );
      if (result.rowCount === 0) {
        return res.status(404).json({ error: 'Reporte no encontrado' });
      }
      res.json(result.rows[0]);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Error al obtener el reporte' });
    }
  });

  // 3. CREAR UN REPORTE
  router.post('/', auth, compressImage, faceDescriptor, async (req, res) => {
    const { description, id_supermarket, nombre_sospechoso } = req.body;
    const id_user = req.usuario.id;

    if (!id_supermarket) {
      return res.status(400).json({ error: 'Faltan campos obligatorios' });
    }

    try {
      const query = `
        INSERT INTO report (description, id_supermarket, image, face_descriptor, id_user, nombre_sospechoso)
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING id, description, id_supermarket, nombre_sospechoso`;

      const result = await pool.query(query, [
        description,
        id_supermarket,
        req.imageBuffer ?? null,
        req.faceDescriptor ? JSON.stringify(req.faceDescriptor) : null,
        id_user,
        nombre_sospechoso ?? null,
      ]);

      const newReport = result.rows[0];

      // 🚨 Notificar guardias cercanos inmediatamente (un solo reporte)
      notifyNearbyGuards(pool, newReport, getMessaging(), { radiusKm: 10 })
        .catch((err) => console.error('[NearbyGuards] Error:', err.message));

      // Disparar evaluación de alerta de crimen sin bloquear la respuesta
      evaluateCrimeAlert(pool, newReport, {
        radiusKm: 10,
        windowHours: 1,
        minReports: 2,
      }).then((alert) => {
        if (alert) {
          console.log(`[CrimeAlert] Alerta #${alert.id} — ${alert.report_count} reportes en ${alert.radius_km}km / ${alert.time_window_h}h`);
        }
      }).catch((err) => {
        console.error('[CrimeAlert] Error al evaluar alerta:', err.message);
      });

      res.status(201).json({
        mensaje: 'Reporte creado con éxito',
        reporte: newReport,
        rostro_detectado: req.faceDescriptor !== null,
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Error interno al crear reporte' });
    }
  });

  // 4. MODIFICAR UN REPORTE
  router.put('/:id', auth, compressImage, faceDescriptor, async (req, res) => {
    const { id } = req.params;
    const { description, id_supermarket, nombre_sospechoso } = req.body;

    if (!id_supermarket) {
      return res.status(400).json({
        error: 'Faltan campos obligatorios',
        debug: { id_supermarket, content_type: req.headers['content-type'] }
      });
    }

    try {
      let imageBuffer = req.imageBuffer ?? undefined;
      let faceDesc = req.faceDescriptor !== undefined ? req.faceDescriptor : undefined;

      let query;
      let params;

      if (imageBuffer !== undefined) {
        query = `
          UPDATE report
          SET description = $1, id_supermarket = $2, image = $3, face_descriptor = $4, nombre_sospechoso = $5
          WHERE id = $6
          RETURNING id, description, id_supermarket, nombre_sospechoso`;
        params = [
          description,
          id_supermarket,
          imageBuffer,
          faceDesc ? JSON.stringify(faceDesc) : null,
          nombre_sospechoso ?? null,
          id,
        ];
      } else {
        query = `
          UPDATE report
          SET description = $1, id_supermarket = $2, nombre_sospechoso = $3
          WHERE id = $4
          RETURNING id, description, id_supermarket, nombre_sospechoso`;
        params = [description, id_supermarket, nombre_sospechoso ?? null, id];
      }

      const result = await pool.query(query, params);
      if (result.rowCount === 0) {
        return res.status(404).json({ error: 'El reporte no existe' });
      }
      res.json({ mensaje: 'Reporte actualizado', reporte: result.rows[0] });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Error al actualizar el reporte' });
    }
  });

  // 5. ELIMINAR UN REPORTE - solo admin
  router.delete('/:id', auth, isAdmin(pool), async (req, res) => {
    const { id } = req.params;
    try {
      const result = await pool.query('DELETE FROM report WHERE id = $1 RETURNING *', [id]);
      if (result.rowCount === 0) {
        return res.status(404).json({ error: 'Reporte no encontrado' });
      }
      res.json({ mensaje: 'Reporte eliminado correctamente' });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Error al eliminar el reporte' });
    }
  });

  // 6. IMAGEN DE UN REPORTE
  router.get('/:id/imagen', auth, async (req, res) => {
    const { id } = req.params;
    try {
      const result = await pool.query('SELECT image FROM report WHERE id = $1', [id]);
      if (result.rowCount === 0 || !result.rows[0].image) {
        return res.status(404).json({ error: 'Imagen no encontrada' });
      }
      const buffer = Buffer.isBuffer(result.rows[0].image)
        ? result.rows[0].image
        : Buffer.from(result.rows[0].image);
      res.setHeader('Content-Type', 'image/webp');
      res.setHeader('Content-Length', buffer.length);
      res.end(buffer);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Error al obtener imagen' });
    }
  });

  // 7. REPORTES CON CARA SIMILAR A UN REPORTE DADO
  router.get('/:id/similares', auth, async (req, res) => {
    const { id } = req.params;
    const threshold = parseFloat(req.query.threshold) || undefined;

    try {
      const refResult = await pool.query(
        'SELECT face_descriptor FROM report WHERE id = $1',
        [id]
      );
      if (refResult.rowCount === 0) {
        return res.status(404).json({ error: 'Reporte no encontrado' });
      }
      if (!refResult.rows[0].face_descriptor) {
        return res.status(422).json({ error: 'Este reporte no tiene descriptor facial (no se detectó rostro en la imagen)' });
      }

      const queryDescriptor = Array.isArray(refResult.rows[0].face_descriptor)
        ? refResult.rows[0].face_descriptor
        : JSON.parse(refResult.rows[0].face_descriptor);

      const allResult = await pool.query(`
        SELECT r.id, r.nombre_sospechoso, r.description, r.date, r.id_supermarket,
               r.face_descriptor,
               s.name AS supermarket_name,
               s.latitude,
               s.longitude
        FROM report r
        JOIN supermarket s ON r.id_supermarket = s.id
        WHERE r.id != $1 AND r.face_descriptor IS NOT NULL
      `, [id]);

      const similares = findSimilar(queryDescriptor, allResult.rows, threshold);

      res.json({
        reporte_referencia: parseInt(id),
        total: similares.length,
        similares: similares.map(r => ({
          id: r.id,
          nombre_sospechoso: r.nombre_sospechoso,
          description: r.description,
          date: r.date,
          distancia: parseFloat(r.distance.toFixed(4)),
          confianza: r.distance < 0.5 ? 'alta' : 'media',
          supermercado: {
            id: r.id_supermarket,
            nombre: r.supermarket_name,
            latitude: r.latitude,
            longitude: r.longitude,
          },
        })),
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Error al buscar similares' });
    }
  });

  // 8. BUSCAR POR FOTO SIN CREAR REPORTE
  router.post('/buscar-cara', auth, compressImage, async (req, res) => {
    if (!req.imageBuffer) {
      return res.status(400).json({ error: 'Se requiere una imagen en el campo "image" (base64)' });
    }

    try {
      const descriptor = await extractDescriptor(req.imageBuffer);
      if (!descriptor) {
        return res.status(422).json({ error: 'No se detectó ningún rostro en la imagen proporcionada' });
      }

      const allResult = await pool.query(`
        SELECT r.id, r.nombre_sospechoso, r.description, r.date, r.id_supermarket,
               r.face_descriptor,
               s.name AS supermarket_name,
               s.location_x,
               s.location_y
        FROM report r
        JOIN supermarket s ON r.id_supermarket = s.id
        WHERE r.face_descriptor IS NOT NULL
      `);

      const threshold = parseFloat(req.query.threshold) || undefined;
      const similares = findSimilar(descriptor, allResult.rows, threshold);

      res.json({
        total: similares.length,
        resultados: similares.map(r => ({
          id: r.id,
          nombre_sospechoso: r.nombre_sospechoso,
          description: r.description,
          date: r.date,
          distancia: parseFloat(r.distance.toFixed(4)),
          confianza: r.distance < 0.5 ? 'alta' : 'media',
          supermercado: {
            id: r.id_supermarket,
            nombre: r.supermarket_name,
            latitude: r.latitude,
            longitude: r.longitude,
          },
        })),
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Error al buscar por cara' });
    }
  });

  return router;
};