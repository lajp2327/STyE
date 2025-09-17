import 'package:sistema_tickets_edis/domain/entities/ticket.dart';

/// Provides the mapping required by DMF for RM/FG tickets.
class DmfMapping {
  const DmfMapping();

  List<String> get headers => const <String>[
    'Folio',
    'Cliente_codigo',
    'Cliente_descripcion',
    'Destino_codigo',
    'Destino_descripcion',
    'Material_codigo',
    'Material_descripcion',
    'Norma_codigo',
    'Norma_descripcion',
    'PropQuim_codigo',
    'PropQuim_descripcion',
    'PropMec_codigo',
    'PropMec_descripcion',
    'NumeroParte_codigo',
    'NumeroParte_descripcion',
    'Solicitante',
    'FechaCreacion',
  ];

  List<String> toRow(Ticket ticket) {
    final TicketAltaDetails details = ticket.altaDetails!;
    return <String>[
      ticket.folio,
      details.cliente.code,
      details.cliente.description,
      details.destino.code,
      details.destino.description,
      details.material.code,
      details.material.description,
      details.norma.code,
      details.norma.description,
      details.propiedadesQuimicas.code,
      details.propiedadesQuimicas.description,
      details.propiedadesMecanicas.code,
      details.propiedadesMecanicas.description,
      details.numeroParte.code,
      details.numeroParte.description,
      ticket.requesterName,
      ticket.createdAt.toIso8601String(),
    ];
  }
}
