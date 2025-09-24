import 'dart:typed_data';

import 'package:sistema_tickets_edis/domain/entities/alta_document_result.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket.dart';

import 'alta_document_storage.dart';

AltaDocumentStorage createAltaDocumentStorageImpl() =>
    _UnsupportedAltaDocumentStorage();

class _UnsupportedAltaDocumentStorage implements AltaDocumentStorage {
  @override
  Future<AltaDocumentResult> save({
    required Ticket ticket,
    required String baseName,
    required Uint8List pdfBytes,
    required String csvData,
  }) async {
    throw UnsupportedError('No hay almacenamiento disponible para documentos RM/FG.');
  }
}
