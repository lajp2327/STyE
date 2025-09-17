import 'dart:io';
import 'dart:math' as math;

import 'package:csv/csv.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:sistema_tickets_edis/core/errors/failure.dart';
import 'package:sistema_tickets_edis/core/pdf/dmf_mapping.dart';
import 'package:sistema_tickets_edis/domain/entities/alta_document_result.dart';
import 'package:sistema_tickets_edis/domain/entities/ticket.dart';

/// Service responsible for generating PDF/CSV artifacts for RM/FG tickets.
class AltaDocumentService {
  AltaDocumentService({
    Future<Directory> Function()? directoryBuilder,
    DmfMapping? mapping,
  }) : _directoryBuilder = directoryBuilder ?? _defaultDirectoryBuilder,
       _mapping = mapping ?? const DmfMapping();

  final Future<Directory> Function() _directoryBuilder;
  final DmfMapping _mapping;

  static Future<Directory> _defaultDirectoryBuilder() async {
    try {
      final Directory base = await getApplicationDocumentsDirectory();
      final Directory target = Directory(p.join(base.path, 'rm_fg_docs'));
      if (!await target.exists()) {
        await target.create(recursive: true);
      }
      return target;
    } catch (_) {
      final Directory fallback = await Directory.systemTemp.createTemp(
        'rm_fg_docs',
      );
      return fallback;
    }
  }

  Future<AltaDocumentResult> generateRmFgDocuments(Ticket ticket) async {
    if (!ticket.isAltaRmFg || ticket.altaDetails == null) {
      throw const PersistenceFailure(
        'El ticket no contiene información RM/FG.',
      );
    }
    final Directory directory = await _directoryBuilder();
    final String sanitized = ticket.folio.replaceAll(
      RegExp('[^A-Za-z0-9_-]'),
      '_',
    );
    final String pdfPath = p.join(directory.path, '${sanitized}_rmfg.pdf');
    final String csvPath = p.join(directory.path, '${sanitized}_rmfg.csv');

    await _generatePdf(ticket, pdfPath);
    await _generateCsv(ticket, csvPath);

    return AltaDocumentResult(pdfPath: pdfPath, csvPath: csvPath);
  }

  Future<void> _generatePdf(Ticket ticket, String path) async {
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
    final File file = File(path);
    await file.writeAsBytes(await doc.save());
  }

  Future<void> _generateCsv(Ticket ticket, String path) async {
    final List<List<String>> rows = <List<String>>[
      List<String>.from(_mapping.headers),
      _mapping.toRow(ticket),
    ];
    final String csvData = const ListToCsvConverter().convert(rows);
    final File file = File(path);
    await file.writeAsString(csvData);
  }
}
