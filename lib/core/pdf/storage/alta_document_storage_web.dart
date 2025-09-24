import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:sistema_tickets_edis/domain/entities/alta_document_result.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket.dart';

import 'alta_document_storage.dart';

class WebAltaDocumentStorage implements AltaDocumentStorage {
  @override
  Future<AltaDocumentResult> save({
    required Ticket ticket,
    required String baseName,
    required Uint8List pdfBytes,
    required String csvData,
  }) async {
    final String pdfFileName = '$baseName.pdf';
    final String csvFileName = '$baseName.csv';

    final html.Blob pdfBlob = html.Blob(<dynamic>[pdfBytes], 'application/pdf');
    final String pdfUrl = html.Url.createObjectUrl(pdfBlob);
    _triggerDownload(pdfUrl, pdfFileName);

    final html.Blob csvBlob = html.Blob(<dynamic>[csvData], 'text/csv');
    final String csvUrl = html.Url.createObjectUrl(csvBlob);
    _triggerDownload(csvUrl, csvFileName);

    return AltaDocumentResult(
      pdf: AltaDocumentArtifact(
        reference: pdfUrl,
        fileName: pdfFileName,
        mimeType: 'application/pdf',
      ),
      csv: AltaDocumentArtifact(
        reference: csvUrl,
        fileName: csvFileName,
        mimeType: 'text/csv',
      ),
    );
  }

  void _triggerDownload(String url, String fileName) {
    final html.AnchorElement anchor = html.AnchorElement(href: url)
      ..download = fileName
      ..style.display = 'none';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    Timer(const Duration(seconds: 30), () => html.Url.revokeObjectUrl(url));
  }
}

AltaDocumentStorage createAltaDocumentStorageImpl() => WebAltaDocumentStorage();
