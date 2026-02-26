import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../models/student.dart';

/// Authentication service for student login using student ID
class AuthService {
  /// Sign in with student ID
  /// Uses Supabase Auth with student_id as the unique identifier
  Future<Student?> signInWithStudentId(String studentId) async {
    try {
      // In a real implementation, you would authenticate via Supabase Auth
      // For student ID-based auth, we'll use a custom approach:
      // 1. Sign in anonymously or with a generated email
      // 2. Fetch student record from database
      
      // Generate a deterministic email from student ID for Supabase Auth
      final email = '$studentId@student.resq.internal';
      final password = _generatePasswordFromStudentId(studentId);

      // Try to sign in first
      AuthResponse? authResponse;
      try {
        authResponse = await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        // If sign in fails, try to sign up
        authResponse = await supabase.auth.signUp(
          email: email,
          password: password,
          data: {'student_id': studentId},
        );
      }

      if (authResponse.user == null) {
        throw Exception('Authentication failed');
      }

      // Fetch student record from database
      final response = await supabase
          .from('students')
          .select()
          .eq('student_id', studentId)
          .single();

      return Student.fromJson(response);
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  /// Get current authenticated student
  Future<Student?> getCurrentStudent() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      // Extract student_id from user metadata or email
      final studentId = user.userMetadata?['student_id'] as String? ??
          user.email?.split('@').first;

      if (studentId == null) return null;

      final response = await supabase
          .from('students')
          .select()
          .eq('student_id', studentId)
          .single();

      return Student.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Get current student ID from auth session
  String? getCurrentStudentId() {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    return user.userMetadata?['student_id'] as String? ??
        user.email?.split('@').first;
  }

  /// Check if user is authenticated
  bool get isAuthenticated => supabase.auth.currentUser != null;

  /// Sign out
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  /// Generate a deterministic password from student ID
  /// This is a simple hash for demo purposes - in production, use proper authentication
  String _generatePasswordFromStudentId(String studentId) {
    // Simple deterministic password generation
    // In production, consider using a proper password or OTP system
    return 'ResQ_${studentId}_2026';
  }

  /// Refresh student data from database
  Future<Student?> refreshStudentData() async {
    return await getCurrentStudent();
  }

  /// Check if student exists in database
  Future<bool> checkStudentExists(String studentId) async {
    try {
      final response = await supabase
          .from('students')
          .select('student_id')
          .eq('student_id', studentId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }
}
