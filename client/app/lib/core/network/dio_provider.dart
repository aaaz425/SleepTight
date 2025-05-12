import 'package:app/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dio_client.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  final apiErrorHandler = ref.watch(apiErrorHandlerProvider);

  return DioClient(apiErrorHandler: apiErrorHandler, container: ref.container);
});
