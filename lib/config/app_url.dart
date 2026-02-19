class AppUrl {
  // ==================== BASE URL ====================
  static const String baseUrl = 'https://sbjct-valium-records-else.trycloudflare.com';

  // ==================== REGISTRATION ENDPOINTS ====================
  static const String communicatorRegister = '$baseUrl/api/auth/communicator/register/';
  static const String caregiverRegister = '$baseUrl/api/auth/caregiver/register/';

  // ==================== SHARED AUTH ENDPOINTS ====================
  static const String login = '$baseUrl/api/auth/login/';
  static const String verifyEmail = '$baseUrl/api/auth/verify-email/';
  static const String resendOtp = '$baseUrl/api/auth/resend-otp/';
  static const String forgotPassword = '$baseUrl/api/auth/password/reset-request/';
  static const String verifyResetOtp = '$baseUrl/api/auth/password/reset-verify-otp/';
  static const String resetPassword = '$baseUrl/api/auth/password/reset-confirm/';

  // ==================== TOKEN & AUTH ENDPOINTS ====================
  static const String tokenRefresh = '$baseUrl/api/auth/token/refresh/';
  static const String logout = '$baseUrl/api/auth/logout/';
  static const String changePassword = '$baseUrl/api/auth/password/change/';
  static const String deleteAccount = '$baseUrl/api/auth/account/parmanent/delete/';

  // ==================== PROFILE ENDPOINTS ====================
  static const String profile = '$baseUrl/api/auth/profile/';

  // ==================== SETTINGS ENDPOINTS ====================
  static const String privacyPolicy = '$baseUrl/api/settings/privacy-policy/';

  // ==================== INVITATION ENDPOINTS ====================
  static const String sendInvitation = '$baseUrl/api/auth/invitations/send/';
  static const String acceptInvitation = '$baseUrl/api/auth/invitations/accept/';
  static const String rejectInvitation = '$baseUrl/api/auth/invitations/reject/';
  static const String listInvitations = '$baseUrl/api/auth/invitations/';

  // ==================== CONNECTION ENDPOINTS ====================
  static const String listConnections = '$baseUrl/api/auth/connections/';
  static const String disconnectProfile = '$baseUrl/api/auth/connections/disconnect/';
  static const String connectionStats = '$baseUrl/api/auth/connections/stats/';

  // ==================== CAREGIVER ENDPOINTS ====================
  static const String copyDefaultContent = '$baseUrl/api/caregiver/customization/copy-defaults/';
}