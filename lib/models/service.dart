class Service {
  final int? id;
  final String name;
  final String? description;
  final double price;
  final int duration;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;

  Service({
    this.id,
    required this.name,
    this.description,
    required this.price,
    required this.duration,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.status = 'active',
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Service copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    int? duration,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      duration: json['duration'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': status,
    };
  }
}
