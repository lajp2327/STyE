import 'dart:math' as math;
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:sistema_tickets_edis/core/errors/failure.dart';
import 'package:sistema_tickets_edis/core/pdf/dmf_mapping.dart';
import 'package:sistema_tickets_edis/core/pdf/storage/alta_document_storage.dart';
import 'package:sistema_tickets_edis/domain/entities/alta_document_result.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket.dart';

/// Service responsible for generating PDF/CSV artifacts for RM/FG tickets.
class AltaDocumentService {
  AltaDocumentService({
    AltaDocumentStorage? storage,
    DmfMapping? mapping,
  })  : _storage = storage ?? createAltaDocumentStorage(),
        _mapping = mapping ?? const DmfMapping();

  final AltaDocumentStorage _storage;
  final DmfMapping _mapping;

  Future<AltaDocumentResult> generateRmFgDocuments(Ticket ticket) async {
    if (!ticket.isAltaRmFg || ticket.altaDetails == null) {
      throw const PersistenceFailure(
        'El ticket no contiene información RM/FG.',
      );
    }

    final String sanitized = ticket.folio.replaceAll(
      RegExp('[^A-Za-z0-9_-]'),
      '_',
    );
    final String baseName = '${sanitized}_rmfg';

    final Uint8List pdfBytes = await _generatePdf(ticket);
    final String csvData = _generateCsv(ticket);

    return _storage.save(
      ticket: ticket,
      baseName: baseName,
      pdfBytes: pdfBytes,
      csvData: csvData,
    );
  }

  Future<Uint8List> _generatePdf(Ticket ticket) async {
    final TicketAltaDetails details = ticket.altaDetails!;
    final pw.Document doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
          textDirection: pw.TextDirection.ltr,
          orientation: pw.PageOrientation.portrait,
          margin: const pw.EdgeInsets.all(32),
          buildBackground: (_) => pw.Container(
            alignment: pw.Alignment.centerRight,
            padding: const pw.EdgeInsets.only(top: 40),
            child: pw.Transform.rotate(
              angle: -math.pi / 2.4,
              child: pw.Text(
                'RM/FG',
                style: pw.TextStyle(color: PdfColors.grey300, fontSize: 72),
              ),
            ),
          ),
        ),
        build: (pw.Context context) => <pw.Widget>[
          pw.Header(level: 0, child: pw.Text('Alta de número de parte RM/FG')),
          pw.Paragraph(text: 'Ticket ${ticket.folio} - ${ticket.title}'),
          pw.Paragraph(text: 'Solicitante: ${ticket.requesterName}'),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headers: const <String>['Campo', 'Valor'],
            data: <List<String>>[
              <String>[
                'Cliente',
                '${details.cliente.code} - ${details.cliente.description}',
              ],
              <String>[
                'Destino',
                '${details.destino.code} - ${details.destino.description}',
              ],
              <String>[
                'Material',
                '${details.material.code} - ${details.material.description}',
              ],
              <String>[
                'Norma',
                '${details.norma.code} - ${details.norma.description}',
              ],
              <String>[
                'Propiedades químicas',
                '${details.propiedadesQuimicas.code} - ${details.propiedadesQuimicas.description}',
              ],
              <String>[
                'Propiedades mecánicas',
                '${details.propiedadesMecanicas.code} - ${details.propiedadesMecanicas.description}',
              ],
              <String>[
                'Número de parte',
                '${details.numeroParte.code} - ${details.numeroParte.description}',
              ],
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Paragraph(text: 'Descripción del requerimiento:'),
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
            ),
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(ticket.description),
          ),
        ],
      ),
    );
    return Uint8List.fromList(await doc.save());
  }

  String _generateCsv(Ticket ticket) {
    final List<List<String>> rows = <List<String>>[
      List<String>.from(_mapping.headers),
      _mapping.toRow(ticket),
    ];
    return const ListToCsvConverter().convert(rows);
  }
}
