// lib/models/auth_model.dart

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String? profileImage;
  final String? bio;
  final bool? emailVerified;
  final bool? isActive;
  final bool? hasCompletedOnboarding;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.profileImage,
    this.bio,
    this.emailVerified,
    this.isActive,
    this.hasCompletedOnboarding,
    this.createdAt,
    this.updatedAt,
  });

  // Computed properties
  String get name => '$firstName $lastName'.trim();
  String get displayName => name.isNotEmpty ? name : 'User';
  
  String get initials {
    if (firstName.isEmpty && lastName.isEmpty) return 'U';
    if (firstName.isEmpty) return lastName[0].toUpperCase();
    if (lastName.isEmpty) return firstName[0].toUpperCase();
    return (firstName[0] + lastName[0]).toUpperCase();
  }
  
  String? get profileImageUrl => profileImage;
  
  String get displayRole {
    if (role.isEmpty) return 'Student';
    return role[0].toUpperCase() + role.substring(1).toLowerCase();
  }

  factory User.fromJson(Map<String, dynamic> json) {
    print('📦 Parsing User from: $json');
    
    // Handle both formats: with firstName/lastName or with name
    String firstName = json['firstName'] ?? json['first_name'] ?? json['first'] ?? '';
    String lastName = json['lastName'] ?? json['last_name'] ?? json['last'] ?? '';
    
    // If only 'name' is provided, try to split it
    if (firstName.isEmpty && lastName.isEmpty && json.containsKey('name')) {
      final fullName = json['name']?.toString() ?? '';
      final parts = fullName.trim().split(' ');
      if (parts.isNotEmpty) {
        firstName = parts.first;
        if (parts.length > 1) {
          lastName = parts.skip(1).join(' ');
        }
      }
    }
    
    return User(
      id: json['id']?.toString() ?? '',
      firstName: firstName,
      lastName: lastName,
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'STUDENT',
      profileImage: json['profileImage'] ?? json['avatar'] ?? json['photoURL'] ?? json['photo'],
      bio: json['bio'],
      emailVerified: json['emailVerified'] ?? json['isVerified'],
      isActive: json['isActive'],
      hasCompletedOnboarding: json['hasCompletedOnboarding'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'profileImage': profileImage,
      'bio': bio,
      'emailVerified': emailVerified,
      'isActive': isActive,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
  
  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? role,
    String? profileImage,
    String? bio,
    bool? emailVerified,
    bool? isActive,
    bool? hasCompletedOnboarding,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      emailVerified: emailVerified ?? this.emailVerified,
      isActive: isActive ?? this.isActive,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String? role;

  RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.role,
  });

  // Alternative constructor for backward compatibility
  RegisterRequest.fromFields({
    required String name,
    required String email,
    required String password,
    String? role,
  }) : this(
    firstName: name.split(' ').first,
    lastName: name.split(' ').skip(1).join(' '),
    email: email,
    password: password,
    role: role,
  );

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      if (role != null) 'role': role,
    };
  }
}

class AuthData {
  final User user;
  final String? token;
  final String? refreshToken;
  final String? expiresAt;

  AuthData({
    required this.user,
    this.token,
    this.refreshToken,
    this.expiresAt,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    print('📦 Parsing AuthData from: $json');
    
    // Handle different response formats
    User user;
    String? token;
    String? refreshToken;
    String? expiresAt;
    
    // If user is directly in the data
    if (json.containsKey('user') && json['user'] is Map) {
      user = User.fromJson(json['user']);
    } 
    // If the whole response is the user
    else if (json.containsKey('id') || json.containsKey('firstName')) {
      user = User.fromJson(json);
    }
    // If user is in 'data' field
    else if (json.containsKey('data') && json['data'] is Map) {
      final dataMap = json['data'] as Map<String, dynamic>;
      if (dataMap.containsKey('user')) {
        user = User.fromJson(dataMap['user']);
        token = dataMap['token'] ?? dataMap['accessToken'];
        refreshToken = dataMap['refreshToken'];
        expiresAt = dataMap['expiresAt']?.toString();
      } else {
        user = User.fromJson(dataMap);
        token = json['token'] ?? json['accessToken'];
        refreshToken = json['refreshToken'];
        expiresAt = json['expiresAt']?.toString();
      }
    } 
    else {
      user = User.fromJson(json);
    }
    
    // Get token from various possible locations
    token = token ?? json['token'] ?? json['accessToken'] ?? json['access_token'];
    refreshToken = refreshToken ?? json['refreshToken'] ?? json['refresh_token'];
    expiresAt = expiresAt ?? json['expiresAt']?.toString() ?? json['accessTokenExpiresAt']?.toString();
    
    return AuthData(
      user: user,
      token: token,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt,
    };
  }
}

class AuthResponse {
  final bool success;
  final AuthData? data;
  final String? message;
  final String? error;

  AuthResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    print('📦 Parsing AuthResponse from: $json');
    
    try {
      // Check if it's a success response
      final isSuccess = json['success'] ?? json['status'] == 'success' ?? true;
      
      // If there's an error message
      if (json.containsKey('message') && !isSuccess) {
        return AuthResponse(
          success: false,
          error: json['message'],
          message: json['message'],
        );
      }
      
      // If there's a 'data' field
      if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
        final dataMap = json['data'] as Map<String, dynamic>;
        return AuthResponse(
          success: isSuccess,
          data: AuthData.fromJson(dataMap),
          message: json['message'],
          error: json['error'],
        );
      }
      
      // If the response itself contains user/token
      if (json.containsKey('user') || json.containsKey('accessToken') || json.containsKey('token')) {
        return AuthResponse(
          success: isSuccess,
          data: AuthData.fromJson(json),
          message: json['message'],
          error: json['error'],
        );
      }
      
      // Fallback
      return AuthResponse(
        success: isSuccess,
        message: json['message'],
        error: json['error'] ?? 'Invalid response format',
      );
    } catch (e) {
      print('❌ AuthResponse parsing error: $e');
      return AuthResponse(
        success: false,
        error: 'Failed to parse response: $e',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'message': message,
      'error': error,
    };
  }
}