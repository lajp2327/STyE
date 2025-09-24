import 'package:flutter/foundation.dart';

/// Flags de compilación para habilitar el modo de previsualización sin backend.
const bool kWebPreviewFlag = bool.fromEnvironment('WEB_PREVIEW', defaultValue: false);

/// Indica si la aplicación debe ejecutar el modo demo sin conectarse a Azure/Dataverse.
bool get kUsePreviewBackend => kIsWeb && kWebPreviewFlag;

