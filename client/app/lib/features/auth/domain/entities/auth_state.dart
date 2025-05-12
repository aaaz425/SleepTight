import 'package:app/features/auth/data/models/enums/auth_status.dart';

class AuthState {
  final AuthStatus status;

  AuthState({required this.status});

  factory AuthState.initial() => AuthState(status: AuthStatus.guest);

  bool get isTemporaryRegistered => status == AuthStatus.incompleteRegistration;
  bool get isActiveUser => status == AuthStatus.active;
  bool get isPendingWithDrawUser => status == AuthStatus.pendingWithdraw;
}
