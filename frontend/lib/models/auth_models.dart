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
    required this.tokens,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    user: User.fromJson(json['user']),
    tokens: AuthTokens.fromJson(json['tokens']),
  );
  final User user;
  final AuthTokens tokens;

  // Convenience getters for backward compatibility
  String get accessToken => tokens.accessToken;
  String get refreshToken => tokens.refreshToken;
}

class AuthTokens {
  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
    accessToken: json['accessToken'],
    refreshToken: json['refreshToken'],
    expiresIn: json['expiresIn'],
  );
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresIn': expiresIn,
  };
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
  Teacher({
    required this.id,
    required this.userId,
    required this.institutionId,
    required this.employeeId,
    required this.designation,
    required this.experienceYears,
    required this.employmentType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.specialization,
    this.qualification,
    this.joinDate,
    this.salary,
    this.officeLocation,
    this.officeHours,
    this.researchInterests,
    this.publications,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) => Teacher(
    id: json['id'],
    userId: json['userId'],
    institutionId: json['institutionId'],
    employeeId: json['employeeId'],
    designation: json['designation'],
    specialization: json['specialization'],
    qualification: json['qualification'],
    experienceYears: json['experienceYears'],
    joinDate: json['joinDate'] != null ? DateTime.parse(json['joinDate']) : null,
    salary: json['salary'],
    employmentType: json['employmentType'],
    officeLocation: json['officeLocation'],
    officeHours: json['officeHours'],
    researchInterests: json['researchInterests'],
    publications: json['publications'],
    status: json['status'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
  final int id;
  final int userId;
  final int institutionId;
  final String employeeId;
  final String designation;
  final String? specialization;
  final String? qualification;
  final int experienceYears;
  final DateTime? joinDate;
  final String? salary;
  final String employmentType;
  final String? officeLocation;
  final String? officeHours;
  final String? researchInterests;
  final String? publications;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'institutionId': institutionId,
    'employeeId': employeeId,
    'designation': designation,
    'specialization': specialization,
    'qualification': qualification,
    'experienceYears': experienceYears,
    'joinDate': joinDate?.toIso8601String(),
    'salary': salary,
    'employmentType': employmentType,
    'officeLocation': officeLocation,
    'officeHours': officeHours,
    'researchInterests': researchInterests,
    'publications': publications,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
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
