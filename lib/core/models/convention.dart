class Convention {
  final int? id;
  final String name;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isClosed;

  const Convention({
    this.id,
    required this.name,
    required this.startDate,
    this.endDate,
    this.isClosed = false,
  });

  Convention copyWith({
    int? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    bool? isClosed,
    bool clearEndDate = false,
  }) {
    return Convention(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      isClosed: isClosed ?? this.isClosed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_closed': isClosed ? 1 : 0,
    };
  }

  factory Convention.fromMap(Map<String, dynamic> map) {
    return Convention(
      id: map['id'] as int?,
      name: map['name'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: map['end_date'] != null
          ? DateTime.parse(map['end_date'] as String)
          : null,
      isClosed: (map['is_closed'] as int) == 1,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory Convention.fromJson(Map<String, dynamic> json) =>
      Convention.fromMap(json);
}
