class Communication {
  final int id;
  final int? institutionId;
  final String title;
  final String content;
  final String communicationType;
  final String priority;
  final List<String>? targetAudience;
  final bool isEmergency;
  final bool isPinned;
  final bool isActive;
  final DateTime publishDate;
  final DateTime? expiryDate;
  final String? attachmentUrl;
  final int? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isRead;

  Communication({
    required this.id,
    this.institutionId,
    required this.title,
    required this.content,
    required this.communicationType,
    required this.priority,
    this.targetAudience,
    required this.isEmergency,
    required this.isPinned,
    required this.isActive,
    required this.publishDate,
    this.expiryDate,
    this.attachmentUrl,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.isRead = false,
  });

  factory Communication.fromJson(Map<String, dynamic> json) {
    return Communication(
      id: json['id'],
      institutionId: json['institutionId'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      communicationType: json['communicationType'] ?? 'General',
      priority: json['priority'] ?? 'Normal',
      targetAudience: json['targetAudience'] != null
          ? List<String>.from(json['targetAudience'])
          : null,
      isEmergency: json['isEmergency'] ?? false,
      isPinned: json['isPinned'] ?? false,
      isActive: json['isActive'] ?? true,
      publishDate: json['publishDate'] != null ? DateTime.parse(json['publishDate']) : DateTime.now(),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      attachmentUrl: json['attachmentUrl'],
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'institutionId': institutionId,
      'title': title,
      'content': content,
      'communicationType': communicationType,
      'priority': priority,
      'targetAudience': targetAudience,
      'isEmergency': isEmergency,
      'isPinned': isPinned,
      'isActive': isActive,
      'publishDate': publishDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'attachmentUrl': attachmentUrl,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isRead': isRead,
    };
  }
}
