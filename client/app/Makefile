DRIVE_FOLDER_ID := 1n9kgxKuYCZkNL3oVY0opMEImHCHPQed5

# --- APK 이름 설정을 위한 변수 정의 ---
# 현재 날짜와 시간을 YYYYMMDDHHMM 형식으로 가져오기
CURRENT_DATETIME := $(shell date +'%Y%m%d%H%M')

# 원하는 APK 파일명 생성 (예: 202405171030-release.apk)
DESIRED_APK_FILENAME := $(CURRENT_DATETIME)-release.apk

# pubspec.yaml에서 앱 이름 (name: 필드) 추출 - 선택 사항 (파일명에 앱 이름을 포함하고 싶다면)
# APP_NAME_FROM_PUBSPEC := $(shell sed -n 's/name: //p' pubspec.yaml | head -n 1 | tr -d '[:space:]')
# APP_NAME := $(if $(APP_NAME_FROM_PUBSPEC),$(APP_NAME_FROM_PUBSPEC),sleeptight)
# 만약 앱 이름을 포함하고 싶다면 DESIRED_APK_FILENAME을 다음과 같이 수정:
# DESIRED_APK_FILENAME := $(APP_NAME)-$(CURRENT_DATETIME)-release.apk

# APK 파일이 생성될 기본 디렉토리
APK_OUTPUT_DIR := build/app/outputs/flutter-apk
# Flutter가 기본적으로 생성하는 APK 파일명
DEFAULT_FLUTTER_APK_NAME := app-release.apk

# 최종 APK 경로 및 파일명 (다른 타겟에서 이 변수를 사용)
APK := $(APK_OUTPUT_DIR)/$(DESIRED_APK_FILENAME)


# Flutter/Dart 자주 쓰는 명령어 단축

icon:
	dart run flutter_launcher_icons

splash:
	dart run flutter_native_splash:create

run:
	flutter run

apk-build: icon splash
	@echo ">>> Building release APK..."
	flutter build apk --release
	@echo ">>> Flutter build complete. Default APK: $(APK_OUTPUT_DIR)/$(DEFAULT_FLUTTER_APK_NAME)"
	@# 빌드된 기본 이름의 APK 파일이 존재하는지 확인 후 이름 변경
	@if [ -f "$(APK_OUTPUT_DIR)/$(DEFAULT_FLUTTER_APK_NAME)" ]; then \
		echo ">>> Renaming APK to $(DESIRED_APK_FILENAME)..."; \
		mv "$(APK_OUTPUT_DIR)/$(DEFAULT_FLUTTER_APK_NAME)" "$(APK)"; \
		echo ">>> APK successfully renamed. Available at: $(APK)"; \
	else \
		echo ">>> Error: Default APK not found at $(APK_OUTPUT_DIR)/$(DEFAULT_FLUTTER_APK_NAME). Renaming failed."; \
		exit 1; \
	fi

clean:
	flutter clean

pubget:
	flutter pub get

devices:
	flutter devices

# 이제 $(APK) 변수는 새로 이름 붙여진 파일을 가리킵니다.
apk-install:
	adb install "$(APK)"

apk-build-install: apk-build apk-install

apk-build-install-galaxys10: apk-build
	adb -s 192.168.137.89:35707 uninstall com.example.sleeptight
	adb -s 192.168.137.89:35707 install "$(APK)"

galaxy10-simulator: icon splash
	flutter run -d R39M208CZ1B

# ios simulator
ios-simulator: icon splash
	flutter run -d 8E36C206-B199-4E83-BFE2-5095FB37019B

# android simulator
android-simulator: icon splash
	flutter run -d emulator-5554

# google-drive-upload 타겟도 새 이름의 APK를 사용합니다.
google-drive-upload: apk-build
	rclone copy "$(APK)" drive: --drive-root-folder-id $(DRIVE_FOLDER_ID) --progress