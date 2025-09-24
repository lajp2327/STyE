import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:sistema_tickets_edis/domain/entities/alta_document_result.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket.dart';

import 'alta_document_storage.dart';

class FileSystemAltaDocumentStorage implements AltaDocumentStorage {
  FileSystemAltaDocumentStorage({Future<Directory> Function()? directoryBuilder})
      : _directoryBuilder = directoryBuilder ?? _defaultDirectoryBuilder;

  final Future<Directory> Function() _directoryBuilder;

  static Future<Directory> _defaultDirectoryBuilder() async {
    try {
      final Directory base = await getApplicationDocumentsDirectory();
      final Directory target = Directory(p.join(base.path, 'rm_fg_docs'));
      if (!await target.exists()) {
        await target.create(recursive: true);
      }
      return target;
    } catch (_) {
      final Directory fallback =
          await Directory.systemTemp.createTemp('rm_fg_docs');
      return fallback;
    }
  }

  @override
  Future<AltaDocumentResult> save({
    required Ticket ticket,
    required String baseName,
    required Uint8List pdfBytes,
    required String csvData,
  }) async {
    final Directory directory = await _directoryBuilder();
    final String pdfFileName = '$baseName.pdf';
    final String csvFileName = '$baseName.csv';

    final File pdfFile = File(p.join(directory.path, pdfFileName));
    await pdfFile.writeAsBytes(pdfBytes);
    final File csvFile = File(p.join(directory.path, csvFileName));
    await csvFile.writeAsString(csvData);

    return AltaDocumentResult(
      pdf: AltaDocumentArtifact(
        reference: pdfFile.path,
        fileName: pdfFileName,
        mimeType: 'application/pdf',
      ),
      csv: AltaDocumentArtifact(
        reference: csvFile.path,
        fileName: csvFileName,
        mimeType: 'text/csv',
      ),
    );
  }
}

AltaDocumentStorage createAltaDocumentStorageImpl() =>
    FileSystemAltaDocumentStorage();
