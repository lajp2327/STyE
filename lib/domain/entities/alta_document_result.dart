import 'package:equatable/equatable.dart';

/// Result for RM/FG publication artifacts.
class AltaDocumentResult extends Equatable {
  const AltaDocumentResult({
    required this.pdfPath,
    required this.csvPath,
  });

  final String pdfPath;
  final String csvPath;

  @override
  List<Object?> get props => <Object?>[pdfPath, csvPath];
}
