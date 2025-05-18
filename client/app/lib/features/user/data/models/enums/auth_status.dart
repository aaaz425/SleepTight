enum AuthStatus {
  guest('guest'),
  incompleteRegistration('incomplete_registration'),
  active('active'),
  pendingWithdraw('pending_withdraw');

  final String value;
  const AuthStatus(this.value);

  // 문자열 → AuthStatus 변환 (백엔드에서 받은 값 파싱용)
  static AuthStatus fromString(String? value) {
    return AuthStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AuthStatus.guest,
    );
  }
}
