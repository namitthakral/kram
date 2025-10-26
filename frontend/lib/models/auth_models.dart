class LoginRequest {
  LoginRequest({required this.email, required this.password});
  final String email;
  final String password;

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequest {
  RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.roleId,
    this.phoneNumber,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final int roleId;
  final String? phoneNumber;

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'password': password,
    'roleId': roleId,
    if (phoneNumber != null) 'phoneNumber': phoneNumber,
  };
}

class RegisterResponse {
  RegisterResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      RegisterResponse(
        success: json['success'],
        message: json['message'],
        data: RegisteredUser.fromJson(json['data']),
      );
  final bool success;
  final String message;
  final RegisteredUser data;
}

class RegisteredUser {
  RegisteredUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.name,
    required this.email,
    required this.status,
    required this.createdAt,
    this.phoneNumber,
    this.role,
  });

  factory RegisteredUser.fromJson(Map<String, dynamic> json) => RegisteredUser(
    id: json['id'],
    firstName: json['firstName'],
    lastName: json['lastName'],
    name: json['name'],
    email: json['email'],
    phoneNumber: json['phoneNumber'],
    role: json['role'] != null ? Role.fromJson(json['role']) : null,
    status: json['status'],
    createdAt: DateTime.parse(json['createdAt']),
  );

  final int id;
  final String firstName;
  final String lastName;
  final String name;
  final String email;
  final String? phoneNumber;
  final Role? role;
  final String status;
  final DateTime createdAt;
}

class LoginResponse {
  LoginResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    user: User.fromJson(json['user']),
    accessToken: json['accessToken'],
    refreshToken: json['refreshToken'],
  );
  final User user;
  final String accessToken;
  final String refreshToken;
}

class User {
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.phone,
    this.role,
    this.student,
    this.teacher,
    this.parent,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
    role: json['role'] != null ? Role.fromJson(json['role']) : null,
    student: json['student'] != null ? Student.fromJson(json['student']) : null,
    teacher: json['teacher'] != null ? Teacher.fromJson(json['teacher']) : null,
    parent: json['parent'] != null ? Parent.fromJson(json['parent']) : null,
    status: json['status'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
  final int id;
  final String name;
  final String email;
  final String? phone;
  final Role? role;
  final Student? student;
  final Teacher? teacher;
  final Parent? parent;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role?.toJson(),
    'student': student?.toJson(),
    'teacher': teacher?.toJson(),
    'parent': parent?.toJson(),
    'status': status,
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

class Student {
  Student({
    required this.id,
    required this.studentId,
    this.admissionNumber,
    this.rollNumber,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json['id'],
    studentId: json['studentId'],
    admissionNumber: json['admissionNumber'],
    rollNumber: json['rollNumber'],
  );
  final int id;
  final String studentId;
  final String? admissionNumber;
  final String? rollNumber;

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'admissionNumber': admissionNumber,
    'rollNumber': rollNumber,
  };
}

class Teacher {
  Teacher({required this.id, required this.teacherId, this.employeeId});

  factory Teacher.fromJson(Map<String, dynamic> json) => Teacher(
    id: json['id'],
    teacherId: json['teacherId'],
    employeeId: json['employeeId'],
  );
  final int id;
  final String teacherId;
  final String? employeeId;

  Map<String, dynamic> toJson() => {
    'id': id,
    'teacherId': teacherId,
    'employeeId': employeeId,
  };
}

class Parent {
  Parent({required this.id, required this.parentId});

  factory Parent.fromJson(Map<String, dynamic> json) =>
      Parent(id: json['id'], parentId: json['parentId']);
  final int id;
  final String parentId;

  Map<String, dynamic> toJson() => {'id': id, 'parentId': parentId};
}
