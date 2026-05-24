-- Ejecutar una sola vez en la base de datos para agregar soporte de reconocimiento facial
ALTER TABLE report ADD COLUMN IF NOT EXISTS face_descriptor jsonb;
