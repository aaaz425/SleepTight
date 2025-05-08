import 'package:permission_handler/permission_handler.dart';

// Future<void> requestExactAlarmPermission() async {
//   PermissionStatus status = await Permission.notification.request();

//   if (status.isGranted) {
//     print("Permission granted");
//   } else {
//     print("Permission denied");
//     // 권한이 거부되었을 때 사용자에게 안내 메시지 또는 설정 화면으로 유도할 수 있음
//     openAppSettings(); // 설정 화면으로 이동
//   }
// }

Future<void> requestExactAlarmPermission() async {
  final status = await Permission.scheduleExactAlarm.status;
  print('Schedule exact alarm permission: $status.');
  if (status.isDenied) {
    print('Requesting schedule exact alarm permission...');
    final res = await Permission.scheduleExactAlarm.request();
    print(
      'Schedule exact alarm permission ${res.isGranted ? '' : 'not'} granted.',
    );
  }

  PermissionStatus notiStatus = await Permission.notification.request();

  if (notiStatus.isGranted) {
    print("Permission granted");
  } else {
    print("Permission denied");
    openAppSettings();
  }
}
