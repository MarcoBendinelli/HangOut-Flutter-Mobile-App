#!/bin/sh
# --batch to prevent interactive command
# --yes to assume "yes" for questions
gpg --quiet --batch --yes --decrypt --passphrase="$ANDROID_KEYS_SECRET_PASSPHRASE" \
--output android/key_files.zip android/key_files.zip.gpg && cd android && jar xvf key_files.zip && cd -
ls -d $PWD/android/*
mv ./android/key_files/key.jks ./android
mv ./android/key_files/key.properties ./android
# move your file according to path in key.properties