import 'package:equatable/equatable.dart';

class AltaDocumentArtifact extends Equatable {
  const AltaDocumentArtifact({
    required this.reference,
    required this.fileName,
    required this.mimeType,
  });

  final String reference;
  final String fileName;
  final String mimeType;

  @override
  List<Object?> get props => <Object?>[reference, fileName, mimeType];
}

/// Result for RM/FG publication artifacts.
class AltaDocumentResult extends Equatable {
  const AltaDocumentResult({
    required this.pdf,
    required this.csv,
  });

  final AltaDocumentArtifact pdf;
  final AltaDocumentArtifact csv;

  @override
  List<Object?> get props => <Object?>[pdf, csv];
}
