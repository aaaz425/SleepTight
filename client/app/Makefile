# Flutter/Dart 자주 쓰는 명령어 단축

icon:
	dart run flutter_launcher_icons

splash:
	dart run flutter_native_splash:create

run:
	flutter run

apk-build:
	flutter build apk --release

clean:
	flutter clean

pubget:
	flutter pub get

devices:
	flutter devices

apk-install:
	adb install build/app/outputs/flutter-apk/app-release.apk

# 빌드 + 설치를 한 번에 실행하는 명령어
apk-build-install: icon splash apk-build apk-install

apk-build-install-galaxys10: icon splash apk-build
	adb -s 192.168.137.89:35707 uninstall com.example.sleeptight
	adb -s 192.168.137.89:35707 install build/app/outputs/flutter-apk/app-release.apk

galaxy10-simulator: icon splash
	flutter run -d R39M208CZ1B

# ios simulator
ios-simulator: icon splash
	flutter run -d 8E36C206-B199-4E83-BFE2-5095FB37019B

# android simulator
android-simulator: icon splash
	flutter run -d emulator-5554
