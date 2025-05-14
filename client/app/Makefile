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

# 여러 명령어를 한 번에 실행하고 싶을 때
all: clean pubget icon splash build