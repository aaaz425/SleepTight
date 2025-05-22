enum WakeMethod { alarm, byPerson, self, noise, other }

extension WakeMethodExtension on WakeMethod {
  static WakeMethod fromJson(String value) {
    switch (value) {
      case 'ALARM':
        return WakeMethod.alarm;
      case 'BY_PERSON':
        return WakeMethod.byPerson;
      case 'SELF':
        return WakeMethod.self;
      case 'NOISE':
        return WakeMethod.noise;
      default:
        return WakeMethod.other;
    }
  }

  String toJson() {
    switch (this) {
      case WakeMethod.alarm:
        return 'ALARM';
      case WakeMethod.byPerson:
        return 'BY_PERSON';
      case WakeMethod.self:
        return 'SELF';
      case WakeMethod.noise:
        return 'NOISE';
      case WakeMethod.other:
        return 'OTHER';
    }
  }
}
