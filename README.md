# HangOut :iphone:
[![codecov](https://codecov.io/gh/MarcoBendinelli/HangOutApp/branch/main/graph/badge.svg?token=HGMS6OM6N9)](https://codecov.io/gh/MarcoBendinelli/HangOutApp)

HangOut is a modern mobile app that revolutionizes socializing. It offers a seamless user experience with four main pages: _My events_, _Explore_, _My groups_, and _Profile_. Users can discover events and groups based on specific interests, manage their activities, and personalize their account. HangOut also includes interactive pop-ups for viewing detailed information, accessing user profiles, creating events and groups, and managing notifications.


The application, developed by me and [Matteo](https://github.com/Beltrante), follows a **CI/CD** process thanks to Github actions and is currently available [here](https://play.google.com/store/apps/details?id=com.bendinelli.beltrante.hang_out_app). Elisa, an exceptional designer, contributes to the UI/UX. Explore her amazing work on her website [here](http://elisaciliberti.it/).

## Design Document

Check out the [Design Document](/design_document/HO_Design_Document.pdf) to learn more! This document includes (mainly) the following information:

* Key features of HangOut, including unified sign-in options, group and event exploration, creation and customization of groups and events, efficient organization, flexible modifications, chat functionality, profile and app settings management, and unified notifications management
* Use Cases illustrating various scenarios and interactions users may have with the application
* Wireframes providing visual representations of the app's interface design for both phone and tablet devices
* The hierarchy and flow of navigation
* Supported platforms
* Technologies and frameworks used in the development
* The high-level system architecture, component interaction, and design patterns utilized in the app
* Database services used
* The third-party APIs integrated
* Details strategies employed to optimize the performance
* Testing: the unit, widget, and integration testing process
* How code branches are organized
* Continuous integration and continuous deployment process.

## Phone Navigation Graph

<p align="center">
  <img width="800" src="ho_images/phone_navigation_graph.svg" alt="phone_navigation_Graph">
</p>

## Phone Screens

<p align="center">
  <img width="750" src="ho_images/phone/screens_1.png" alt="screens_1">
</p>

<p align="center">
  <img width="750" src="ho_images/phone/screens_2.png" alt="screens_2">
</p>

<p align="center">
  <img width="750" src="ho_images/phone/screens_3.png" alt="screens_3">
</p>

<p align="center">
  <img width="750" src="ho_images/phone/screens_4.png" alt="screens_4">
</p>

<p align="center">
  <img width="750" src="ho_images/phone/screens_5.png" alt="screens_5">
</p>

<p align="center">
  <img width="750" src="ho_images/phone/screens_6.png" alt="screens_6">
</p>

<p align="center">
  <img width="750" src="ho_images/phone/screens_7.png" alt="screens_7">
</p>

<p align="center">
  <img width="750" src="ho_images/phone/screens_8.png" alt="screens_8">
</p>

<p align="center">
  <img width="750" src="ho_images/phone/screens_9.png" alt="screens_9">
</p>

<p align="center">
  <img width="750" src="ho_images/phone/screens_10.png" alt="screens_10">
</p>

<p align="center">
  <img width="750" src="ho_images/phone/screens_11.png" alt="screens_11">
</p>

## Tablet Screens

<p align="center">
  <img width="600" src="ho_images/tablet/1.PNG" alt="1">
</p>

<p align="center">
  <img width="600" src="ho_images/tablet/2.PNG" alt="2">
</p>

<p align="center">
  <img width="600" src="ho_images/tablet/3.PNG" alt="3">
</p>

<p align="center">
  <img width="600" src="ho_images/tablet/4.PNG" alt="4">
</p>

<p align="center">
  <img width="600" src="ho_images/tablet/5.PNG" alt="5">
</p>

<p align="center">
  <img width="600" src="ho_images/tablet/6.PNG" alt="6">
</p>

<p align="center">
  <img width="600" src="ho_images/tablet/7.PNG" alt="7">
</p>

## Test Coverage

<p align="center">
  <img width="750" src="ho_images/test_coverage.svg" alt="test_coverage">
</p>

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
