import 'dart:typed_data';

import 'package:sistema_tickets_edis/domain/entities/alta_document_result.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket.dart';

import 'alta_document_storage_stub.dart'
    if (dart.library.html) 'alta_document_storage_web.dart'
    if (dart.library.io) 'alta_document_storage_io.dart';

abstract class AltaDocumentStorage {
  Future<AltaDocumentResult> save({
    required Ticket ticket,
    required String baseName,
    required Uint8List pdfBytes,
    required String csvData,
  });
}

AltaDocumentStorage createAltaDocumentStorage() => createAltaDocumentStorageImpl();
