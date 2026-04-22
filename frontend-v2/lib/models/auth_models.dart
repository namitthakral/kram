class LoginRequest {
  LoginRequest({required this.password, this.email, this.phone, this.kramid})
    : assert(
        email != null || phone != null || kramid != null,
        'At least one of email, phone, or kramid must be provided',
      );

  final String? email;
  final String? phone;
  final String? kramid;
  final String password;

  Map<String, dynamic> toJson() {
    final data = {'password': password};

    if (email != null) {
      data['email'] = email!;
    }
    if (phone != null) {
      data['phone'] = phone!;
    }
    if (kramid != null) {
      data['kramid'] = kramid!;
    }

    return data;
  }
}

int? _institutionIdFromRelations(Map<String, dynamic> json) {
  final student = json['student'];
  final teacher = json['teacher'];
  final staff = json['staff'];
  if (student is Map && student['institutionId'] != null) {
    return int.tryParse(student['institutionId'].toString());
  }
  if (teacher is Map && teacher['institutionId'] != null) {
    return int.tryParse(teacher['institutionId'].toString());
  }
  if (staff is Map && staff['institutionId'] != null) {
    return int.tryParse(staff['institutionId'].toString());
  }
  return null;
}

class User {
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.uuid,
    this.kramid,
    this.phone,
    this.role,
    this.student,
    this.teacher,
    this.parent,
    this.staff,
    this.institutionId,
    this.institution,
    this.mustChangePassword,
    this.isTemporaryPassword,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    uuid: json['uuid'],
    kramid: json['kramid'],
    name: '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
    email: json['email'],
    phone: json['phone'],
    role: json['role'] != null ? Role.fromJson(json['role']) : null,
    student: json['student'], // We'll keep this simple for now
    teacher: json['teacher'], 
    parent: json['parent'],
    staff: json['staff'],
    institutionId: json['institutionId'] ?? _institutionIdFromRelations(json),
    institution:
        json['institution'] != null
            ? Institution.fromJson(json['institution'])
            : null,
    status: json['accountStatus'] ?? json['status'], // Support both field names
    mustChangePassword: json['mustChangePassword'] ?? false,
    isTemporaryPassword: json['isTemporaryPassword'] ?? false,
    createdAt:
        json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
    updatedAt:
        json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : DateTime.now(),
  );
  final int id;
  final String? uuid;
  final String? kramid;
  final String name;
  final String email;
  final String? phone;
  final Role? role;
  final dynamic student;
  final dynamic teacher;
  final dynamic parent;
  final dynamic staff;
  final int? institutionId;
  final Institution? institution;
  final String status;
  final bool? mustChangePassword;
  final bool? isTemporaryPassword;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get fullName => name;

  Map<String, dynamic> toJson() => {
    'id': id,
    'uuid': uuid,
    'kramid': kramid,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role?.toJson(),
    'student': student,
    'teacher': teacher,
    'parent': parent,
    'staff': staff,
    'institutionId': institutionId,
    'institution': institution?.toJson(),
    'status': status,
    'mustChangePassword': mustChangePassword,
    'isTemporaryPassword': isTemporaryPassword,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

class Role {
  Role({
    required this.id,
    required this.roleName,
    required this.description,
    required this.permissions,
    required this.createdAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) => Role(
    id: json['id'],
    roleName: json['roleName'],
    description: json['description'],
    permissions: List<String>.from(json['permissions'] ?? []),
    createdAt: DateTime.parse(json['createdAt']),
  );
  final int id;
  final String roleName;
  final String description;
  final List<String> permissions;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'roleName': roleName,
    'description': description,
    'permissions': permissions,
    'createdAt': createdAt.toIso8601String(),
  };
}

class Institution {
  Institution({required this.id, required this.name, this.type});

  factory Institution.fromJson(Map<String, dynamic> json) => Institution(
    id: json['id'],
    name: json['name'] ?? 'Unknown Institution',
    type: json['type'],
  );

  final int id;
  final String name;
  final String? type;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'type': type};
}

class AuthTokens {
  AuthTokens({
    required this.accessToken,
    required this.expiresIn,
    this.refreshToken,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
    accessToken: json['accessToken'],
    refreshToken: json['refreshToken'],
    expiresIn: json['expiresIn'],
  );
  final String accessToken;
  final String? refreshToken;
  final int expiresIn;

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    if (refreshToken != null) 'refreshToken': refreshToken,
    'expiresIn': expiresIn,
  };
}

class LoginResponse {
  LoginResponse({required this.user, required this.tokens});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Handle both response formats:
    // 1. With tokens object: {"user": {...}, "tokens": {...}}
    // 2. With tokens at root: {"user": {...}, "accessToken": "...", "refreshToken": "...", "expiresIn": ...}
    final AuthTokens tokens;
    if (json['tokens'] != null) {
      tokens = AuthTokens.fromJson(json['tokens']);
    } else {
      // Extract tokens from root level
      tokens = AuthTokens(
        accessToken: json['accessToken'] ?? '',
        refreshToken: json['refreshToken'],
        expiresIn: json['expiresIn'] ?? 3600,
      );
    }

    return LoginResponse(user: User.fromJson(json['user']), tokens: tokens);
  }
  final User user;
  final AuthTokens tokens;

  // Convenience getters for backward compatibility
  String get accessToken => tokens.accessToken;
  String? get refreshToken => tokens.refreshToken;
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;

  AuthException(this.message, {this.statusCode});

  @override
  String toString() => message;
}