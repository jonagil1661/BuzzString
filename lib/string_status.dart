class StringStatus {
  final String stringName;
  final bool isInStock;
  final String imagePath;

  StringStatus({
    required this.stringName,
    required this.isInStock,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'stringName': stringName,
      'isInStock': isInStock,
      'imagePath': imagePath,
    };
  }

  factory StringStatus.fromMap(Map<String, dynamic> map) {
    return StringStatus(
      stringName: map['stringName'] ?? '',
      isInStock: map['isInStock'] ?? true,
      imagePath: map['imagePath'] ?? '',
    );
  }

  StringStatus copyWith({
    String? stringName,
    bool? isInStock,
    String? imagePath,
  }) {
    return StringStatus(
      stringName: stringName ?? this.stringName,
      isInStock: isInStock ?? this.isInStock,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
