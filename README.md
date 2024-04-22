# HangOutApp
[![codecov](https://codecov.io/gh/MarcoBendinelli/HangOutApp/branch/main/graph/badge.svg?token=HGMS6OM6N9)](https://codecov.io/gh/MarcoBendinelli/HangOutApp)

Hang Out mobile Application developed in Flutter!

This project started as a University project for the course Development and Implementation of a Mobile Application.

Read the [DesignDocument](/design_document/HO_Design_Document.pdf.pdf) if you are want to discover more!

## Additional Information

### Firebase Config
* code/android/app : your google-services.json
* code/lib : your firebase_options.dart
* code/ios : your firebase_app_id_file.json
* code/ios : your GoogleService-Info.plist
* code/ios/Runner/Info.plist : your keys in the ```m4rc0``` section

### Run Integration Tests:

* ```firebase emulators:start```
* ```flutter test integration_test/app_test.dart```
* or to all in one with screenshots
* ```firebase emulators:exec "flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart"```

### For CI
* Create ```key.properties``` and ```key.jks``` following the Flutter guide and put them in a ```key_files``` folder
* Zip it to ```key_files.zip```, encrypt it with ```gpg --symmetric --cipher-algo AES256 key_files.zip```, and insert a password to be used later
* Put encrypted file in the Android folder and save the password in ```secrets.ANDROID_KEYS_SECRET_PASSPHRASE```
