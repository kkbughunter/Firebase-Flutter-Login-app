# Google & Gmail Auth

```bash
flutter pub add firebase_core flutter_signin_button firebase_auth google_sign_in
```
### Enable assets images folder
```yaml
flutter:
    uses-material-design: true

    assets:
        - assets/images/
```

### Add Firebase with app 
```
dart pub global activate flutterfire_cli
flutterfire configure --project=*****
```

### Enable Firebase Auth service
![image](https://github.com/user-attachments/assets/210577db-cc55-4547-96e4-c38d1982ee17)


### Add SHA1 & SHA256 value 
linux & macOS
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```
```bash
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```
or
```bash
keytool -list -v -alias androiddebugkey -keystore "$env:USERPROFILE\.android\debug.keystore" -storepass android -keypass android
```

![image](https://github.com/user-attachments/assets/6fb5a912-844e-400a-b38b-492f2b56c2d7)
