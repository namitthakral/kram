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

class Institution {
  Institution({required this.id, required this.name, this.type});

  factory Institution.fromJson(Map<String, dynamic> json) =>
      Institution(id: json['id'], name: json['name'], type: json['type']);

  final int id;
  final String name;
  final String? type;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'type': type};
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
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
    role: json['role'] != null ? Role.fromJson(json['role']) : null,
    student: json['student'] != null ? Student.fromJson(json['student']) : null,
    teacher: json['teacher'] != null ? Teacher.fromJson(json['teacher']) : null,
    parent: json['parent'] != null ? Parent.fromJson(json['parent']) : null,
    staff: json['staff'] != null ? Staff.fromJson(json['staff']) : null,
    institutionId: json['institutionId'] ?? _institutionIdFromRelations(json),
    institution:
        json['institution'] != null
            ? Institution.fromJson(json['institution'])
            : null,
    status: json['status'],
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
  final Student? student;
  final Teacher? teacher;
  final Parent? parent;
  final Staff? staff;
  final int? institutionId;
  final Institution? institution;
  final String status;
  final bool? mustChangePassword;
  final bool? isTemporaryPassword;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'uuid': uuid,
    'kramid': kramid,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role?.toJson(),
    'student': student?.toJson(),
    'teacher': teacher?.toJson(),
    'parent': parent?.toJson(),
    'staff': staff?.toJson(),
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

class Student {
  Student({
    required this.id,
    required this.userId,
    this.institutionId,
    this.programId,
    this.admissionNumber,
    this.rollNumber,
    this.admissionDate,
    this.graduationDate,
    this.currentSemester,
    this.currentYear,
    this.section,
    this.studentType,
    this.residentialStatus,
    this.transportRequired,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.bloodGroup,
    this.medicalConditions,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json['id'],
    userId: json['userId'],
    institutionId: json['institutionId'],
    programId: json['programId'],
    admissionNumber: json['admissionNumber'],
    rollNumber: json['rollNumber'],
    admissionDate:
        json['admissionDate'] != null
            ? DateTime.parse(json['admissionDate'])
            : null,
    graduationDate:
        json['graduationDate'] != null
            ? DateTime.parse(json['graduationDate'])
            : null,
    currentSemester: json['currentSemester'],
    currentYear: json['currentYear'],
    section: json['section'],
    studentType: json['studentType'],
    residentialStatus: json['residentialStatus'],
    transportRequired: json['transportRequired'] ?? false,
    emergencyContactName: json['emergencyContactName'],
    emergencyContactPhone: json['emergencyContactPhone'],
    bloodGroup: json['bloodGroup'],
    medicalConditions: json['medicalConditions'],
    status: json['status'],
    createdAt:
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    updatedAt:
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
  );
  final int id;
  final int userId;
  final int? institutionId;
  final int? programId;
  final String? admissionNumber;
  final String? rollNumber;
  final DateTime? admissionDate;
  final DateTime? graduationDate;
  final int? currentSemester;
  final int? currentYear;
  final String? section;
  final String? studentType;
  final String? residentialStatus;
  final bool? transportRequired;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? bloodGroup;
  final String? medicalConditions;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'institutionId': institutionId,
    'programId': programId,
    'admissionNumber': admissionNumber,
    'rollNumber': rollNumber,
    'admissionDate': admissionDate?.toIso8601String(),
    'graduationDate': graduationDate?.toIso8601String(),
    'currentSemester': currentSemester,
    'currentYear': currentYear,
    'section': section,
    'studentType': studentType,
    'residentialStatus': residentialStatus,
    'transportRequired': transportRequired,
    'emergencyContactName': emergencyContactName,
    'emergencyContactPhone': emergencyContactPhone,
    'bloodGroup': bloodGroup,
    'medicalConditions': medicalConditions,
    'status': status,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
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
    this.uuid,
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
    uuid: json['uuid'],
    userId: json['userId'],
    institutionId: json['institutionId'],
    employeeId: json['employeeId'],
    designation: json['designation'],
    specialization: json['specialization'],
    qualification: json['qualification'],
    experienceYears: json['experienceYears'] ?? 0,
    joinDate:
        json['joinDate'] != null ? DateTime.parse(json['joinDate']) : null,
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
  final String? uuid;
  final int userId;
  final int institutionId;
  final String employeeId;
  final String? designation;
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
    'uuid': uuid,
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
  Parent({
    required this.id,
    this.userId,
    this.studentId,
    this.relation,
    this.occupation,
    this.annualIncome,
    this.educationLevel,
    this.isPrimaryContact = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Parent.fromJson(Map<String, dynamic> json) => Parent(
    id: json['id'],
    userId: json['userId'],
    studentId: json['studentId'],
    relation: json['relation'],
    occupation: json['occupation'],
    annualIncome: json['annualIncome'],
    educationLevel: json['educationLevel'],
    isPrimaryContact: json['isPrimaryContact'] ?? false,
    createdAt:
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    updatedAt:
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
  );

  final int id;
  final int? userId;
  final int? studentId;
  final String? relation;
  final String? occupation;
  final String? annualIncome;
  final String? educationLevel;
  final bool isPrimaryContact;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'studentId': studentId,
    'relation': relation,
    'occupation': occupation,
    'annualIncome': annualIncome,
    'educationLevel': educationLevel,
    'isPrimaryContact': isPrimaryContact,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}

class Staff {
  Staff({
    required this.id,
    required this.userId,
    required this.institutionId,
    this.employeeId,
    this.staffType,
    this.designation,
  });

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
    id: json['id'],
    userId: json['userId'],
    institutionId: json['institutionId'],
    employeeId: json['employeeId'],
    staffType: json['staffType'],
    designation: json['designation'],
  );

  final int id;
  final int userId;
  final int institutionId;
  final String? employeeId;
  final String? staffType;
  final String? designation;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'institutionId': institutionId,
    'employeeId': employeeId,
    'staffType': staffType,
    'designation': designation,
  };
}
