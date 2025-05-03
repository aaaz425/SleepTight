import 'package:go_router/go_router.dart';
import '../../../features/user/presentation/screens/user_screen.dart';

// Todo: 라우팅 설정
final appRouter = GoRouter(
  routes: [GoRoute(path: '/', builder: (context, state) => const UserScreen())],
);
