# Play Store Upload Checklist (Android)

## 1) Required Build Artifact
- `app-release.aab` (release, signed with upload key).
- Current project status: `android/app/build.gradle.kts` still signs release with debug key. Replace with release signing config before upload.

## 2) Graphics / Store Listing Assets
- App icon: `512 x 512` PNG (no alpha recommended).
- Feature graphic: `1024 x 500` PNG/JPEG.
- Phone screenshots: minimum 2 (recommended 4+ high-quality screenshots).
- Short description and full description.
- Privacy policy URL.

Reference (official):  
https://support.google.com/googleplay/android-developer/answer/9866151?hl=en

## 3) Policy / Forms in Play Console
- App content questionnaire.
- Data safety form.
- Ads declaration.
- Content rating questionnaire.
- Target audience & news declarations (if applicable).

## 4) Local Automation Added
- Screenshot automation test:  
  `integration_test/play_store_screenshots_test.dart`
- Screenshot capture script:  
  `scripts/capture_play_store_screenshots.sh`
- Release artifact script:  
  `scripts/prepare_play_console_artifacts.sh`

## 5) Commands
```bash
# Capture screenshots (requires connected Android device/emulator)
bash scripts/capture_play_store_screenshots.sh

# Build AAB + collect artifact (requires release signing config)
bash scripts/prepare_play_console_artifacts.sh
```
