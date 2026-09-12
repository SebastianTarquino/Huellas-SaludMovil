/// Configuración centralizada de las URLs del Backend / Servidor.
///
/// Cuando despliegues tu propio servidor en Render o tu propia base de datos,
/// solo debes cambiar el valor de [baseUrl] en este archivo.
class ApiConfig {
  /// URL base del servidor backend propio desplegado en Render
  static const String baseUrl = 'https://huellas-saludbackend.onrender.com';

  /// URL base para los endpoints con prefijo /internal/
  static String get internalBaseUrl => '$baseUrl/internal/';
}
