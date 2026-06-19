String formatearFecha(String? fechaApi) {
  if (fechaApi == null) return 'Sin fecha';
  try {
    final f = DateTime.parse(fechaApi).toLocal();
    return '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year} '
        '${f.hour.toString().padLeft(2, '0')}:${f.minute.toString().padLeft(2, '0')}';
  } catch (_) {
    return fechaApi;
  }
}
