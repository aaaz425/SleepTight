enum WakeAwareness { no, normal, yes }

extension WakeAwarenessExtension on WakeAwareness {
  static WakeAwareness fromJson(String value) {
    switch (value) {
      case 'no':
        return WakeAwareness.no;
      case 'NORMAL':
        return WakeAwareness.normal;
      case 'YES':
        return WakeAwareness.yes;
      default:
        return WakeAwareness.no;
    }
  }

  String toJson() {
    switch (this) {
      case WakeAwareness.no:
        return 'NO';
      case WakeAwareness.normal:
        return 'NORMAL';
      case WakeAwareness.yes:
        return 'YES';
    }
  }
}
