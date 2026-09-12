/// Configuración centralizada de las URLs del Backend / Servidor.
///
/// Cuando despliegues tu propio servidor en Render o tu propia base de datos,
/// solo debes cambiar el valor de [baseUrl] en este archivo.
class ApiConfig {
  /// URL base del servidor backend desplegado en Render (o tu servidor local / de producción)
  static const String baseUrl = 'https://huellassalud.onrender.com';

  /// URL base para los endpoints con prefijo /internal/
  static String get internalBaseUrl => '$baseUrl/internal/';
}
