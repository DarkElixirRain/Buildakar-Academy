// lib/models/auth_model.dart

class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? profileImage;
  final String? bio;
  final bool? emailVerified;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImage,
    this.bio,
    this.emailVerified,
    this.createdAt,
  });

  // Add displayName getter
  String get displayName => name;
  
  // Add initials getter
  String get initials {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }
  
  // Add profileImageUrl getter (alias for profileImage)
  String? get profileImageUrl => profileImage;
  
  // Add displayRole getter
  String get displayRole {
    if (role.isEmpty) return 'Student';
    return role[0].toUpperCase() + role.substring(1);
  }

  factory User.fromJson(Map<String, dynamic> json) {
    print('📦 Parsing User from: $json');
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['displayName'] ?? 'User',
      email: json['email'] ?? '',
      role: json['role'] ?? 'student',
      profileImage: json['profileImage'] ?? json['avatar'] ?? json['photoURL'],
      bio: json['bio'],
      emailVerified: json['emailVerified'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'profileImage': profileImage,
      'bio': bio,
      'emailVerified': emailVerified,
      'createdAt': createdAt?.toIso8601String(),
    };
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

  AuthData({
    required this.user,
    this.token,
    this.refreshToken,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    print('📦 Parsing AuthData from: $json');
    return AuthData(
      user: User.fromJson(json['user'] ?? json),
      token: json['token'] ?? json['accessToken'] ?? json['access_token'],
      refreshToken: json['refreshToken'] ?? json['refresh_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
      'refreshToken': refreshToken,
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
      // If the response has a 'data' field with 'user' inside
      if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
        final dataMap = json['data'] as Map<String, dynamic>;
        
        if (dataMap.containsKey('user') || dataMap.containsKey('token')) {
          return AuthResponse(
            success: json['success'] ?? true,
            data: AuthData.fromJson(dataMap),
            message: json['message'],
            error: json['error'],
          );
        }
      }
      
      // If the response is directly the AuthData
      if (json.containsKey('user') || json.containsKey('token')) {
        return AuthResponse(
          success: json['success'] ?? true,
          data: AuthData.fromJson(json),
          message: json['message'],
          error: json['error'],
        );
      }
      
      // If response has a 'status' field
      if (json.containsKey('status')) {
        final isSuccess = json['status'] == 'success' || json['status'] == true;
        return AuthResponse(
          success: isSuccess,
          data: json.containsKey('data') ? AuthData.fromJson(json['data']) : null,
          message: json['message'],
          error: json['error'],
        );
      }
      
      // Fallback: treat the whole response as AuthData
      try {
        return AuthResponse(
          success: true,
          data: AuthData.fromJson(json),
          message: 'Success',
        );
      } catch (e) {
        print('❌ Failed to parse as AuthData: $e');
        return AuthResponse(
          success: false,
          error: 'Failed to parse response: $e',
        );
      }
    } catch (e) {
      print('❌ AuthResponse parsing error: $e');
      return AuthResponse(
        success: false,
        error: 'Invalid response format: $e',
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