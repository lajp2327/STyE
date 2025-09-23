class Ticket {
  const Ticket({
    required this.id,
    required this.title,
    required this.priority,
    required this.status,
  });

  final String id;
  final String title;
  final String priority;
  final String status;

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['new_ticketid'] as String? ?? '',
      title: json['new_title'] as String? ?? '',
      priority: json['new_priority'] as String? ?? '',
      status: json['new_status'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'new_ticketid': id,
        'new_title': title,
        'new_priority': priority,
        'new_status': status,
      };

  Map<String, dynamic> toCreatePayload() => <String, dynamic>{
        'new_title': title,
        'new_priority': priority,
        'new_status': status,
      };

  Map<String, dynamic> toUpdatePayload() => <String, dynamic>{
        if (title.isNotEmpty) 'new_title': title,
        if (priority.isNotEmpty) 'new_priority': priority,
        if (status.isNotEmpty) 'new_status': status,
      };

  Ticket copyWith({
    String? id,
    String? title,
    String? priority,
    String? status,
  }) {
    return Ticket(
      id: id ?? this.id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      status: status ?? this.status,
    );
  }
}
