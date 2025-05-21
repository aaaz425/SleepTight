# --- Google Drive 업로드 관련 변수 ---
DRIVE_FOLDER_ID := 1n9kgxKuYCZkNL3oVY0opMEImHCHPQed5 # 실제 ID로 잘 설정되어 있음

# --- APK 이름 설정을 위한 변수 정의 ---
# 현재 날짜와 시간을 YYYYMMDDHHMM 형식으로 가져오기
CURRENT_DATETIME := $(shell date +'%Y%m%d%H%M')

# 원하는 APK 파일명의 "기본 부분" (ABI 정보와 .apk 확장자가 여기에 추가됨)
DESIRED_APK_BASENAME := $(CURRENT_DATETIME)-release # 예: 202405171030-release

# pubspec.yaml에서 앱 이름 (name: 필드) 추출 - 선택 사항
# APP_NAME_FROM_PUBSPEC := $(shell sed -n 's/name: //p' pubspec.yaml | head -n 1 | tr -d '[:space:]')
# APP_NAME := $(if $(APP_NAME_FROM_PUBSPEC),$(APP_NAME_FROM_PUBSPEC),sleeptight)
# 만약 앱 이름을 포함하고 싶다면 DESIRED_APK_BASENAME을 다음과 같이 수정:
# DESIRED_APK_BASENAME := $(APP_NAME)-$(CURRENT_DATETIME)-release

# Flutter --split-per-abi 사용 시 APK 파일이 생성되는 "실제" 디렉토리
FLUTTER_SPLIT_APK_OUTPUT_DIR := build/app/outputs/flutter-apk

# 이름이 변경된 APK 파일들을 저장할 최종 디렉토리
FINAL_RENAMED_APK_DIR := $(FLUTTER_SPLIT_APK_OUTPUT_DIR)/renamed-apks

# 설치 등에 사용할 대표 APK (예: arm64-v8a 버전). 필요에 따라 ABI 변경.
# 이 변수는 apk-build가 완료된 후 채워진 FINAL_RENAMED_APK_DIR 내부의 파일을 가리켜야 함.
TARGET_ABI_FOR_INSTALL := arm64-v8a # 주로 사용될 ABI 또는 테스트할 ABI
APK_FOR_INSTALL := $(FINAL_RENAMED_APK_DIR)/$(DESIRED_APK_BASENAME)-$(TARGET_ABI_FOR_INSTALL).apk


# Flutter/Dart 자주 쓰는 명령어 단축
icon:
	dart run flutter_launcher_icons

splash:
	dart run flutter_native_splash:create

run:
	flutter run

apk-build: icon splash
	@echo ">>> Building release APKs (split per ABI)..."
	flutter build apk --release --split-per-abi
	# 수정된 echo 문구: 실제 APK 생성 경로를 반영
	@echo ">>> Flutter build complete. Original APKs are in $(FLUTTER_SPLIT_APK_OUTPUT_DIR)/"

	@# 최종 저장 디렉토리 생성 (없으면)
	@mkdir -p $(FINAL_RENAMED_APK_DIR)

	@echo ">>> Renaming and moving APKs to $(FINAL_RENAMED_APK_DIR)/..."
	@found_apks=0; \
	for original_apk_path in $(FLUTTER_SPLIT_APK_OUTPUT_DIR)/app-*-release.apk; do \
		if [ -f "$$original_apk_path" ]; then \
			found_apks=1; \
			original_filename=$$(basename "$$original_apk_path"); \
			abi_type=$$(echo "$$original_filename" | sed -n 's/app-\(.*\)-release\.apk/\1/p'); \
			new_apk_filename="$(DESIRED_APK_BASENAME)-$$abi_type.apk"; \
			final_new_path="$(FINAL_RENAMED_APK_DIR)/$$new_apk_filename"; \
			echo ">>> Moving and Renaming '$$original_filename' to '$$final_new_path'"; \
			mv "$$original_apk_path" "$$final_new_path"; \
		fi; \
	done; \
	if [ "$$found_apks" -eq 0 ]; then \
		echo ">>> Error: No APKs found in $(FLUTTER_SPLIT_APK_OUTPUT_DIR) to rename. Check path and build output."; \
		exit 1; \
	else \
		echo ">>> APKs successfully renamed and moved to $(FINAL_RENAMED_APK_DIR)/"; \
	fi
# 위의 'fi' 다음에는 백슬래시(\)가 없어야 합니다.

clean:
	flutter clean
	@echo ">>> Removing renamed APKs directory..."
	@rm -rf $(FINAL_RENAMED_APK_DIR) # 선택 사항: renamed-apks 디렉토리도 삭제

pubget:
	flutter pub get

devices:
	flutter devices

# 이제 $(APK_FOR_INSTALL) 변수는 새로 이름 붙여진 특정 ABI의 파일을 가리킵니다.
apk-install: apk-build # apk-build를 먼저 실행하여 APK_FOR_INSTALL 경로가 유효하도록 함
	@echo ">>> Installing $(APK_FOR_INSTALL)..."
	adb install "$(APK_FOR_INSTALL)"

apk-build-install: apk-build apk-install

apk-build-install-galaxys10: apk-build
	@echo ">>> Uninstalling com.example.sleeptight from 192.168.137.89:46769..."
	adb -s 192.168.137.89:46769 uninstall com.example.sleeptight
	@echo ">>> Installing $(APK_FOR_INSTALL) on 192.168.137.89:46769..."
	adb -s 192.168.137.89:46769 install "$(APK_FOR_INSTALL)"

galaxy10-simulator: icon splash
	flutter run -d 192.168.137.89:46769

ios-simulator: icon splash
	flutter run -d 8E36C206-B199-4E83-BFE2-5095FB37019B

android-simulator: icon splash
	flutter run -d emulator-5554

# google-drive-upload 타겟: 모든 버전의 APK를 업로드합니다.
google-drive-upload: apk-build
	@echo ">>> Uploading all APKs from $(FINAL_RENAMED_APK_DIR)/ to Google Drive folder ID: $(DRIVE_FOLDER_ID)..."
	rclone copy "$(FINAL_RENAMED_APK_DIR)" "drive:" --drive-root-folder-id $(DRIVE_FOLDER_ID) --progress
	@echo ">>> Google Drive upload complete."

.PHONY: all icon splash apk-build clean pubget devices apk-install apk-build-install apk-build-install-galaxys10 galaxy10-simulator ios-simulator android-simulator google-drive-upload