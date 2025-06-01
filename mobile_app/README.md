# winball flutter bot

##version of flutter in windows

```
Flutter 3.24.1 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 5874a72aa4 (7 months ago) • 2024-08-20 16:46:00 -0500
Engine • revision c9b9d5780d
Tools • Dart 3.5.1 • DevTools 2.37.2
```

### for creating a bot ui do the below :

change the botusername to your bot username in file app_config.dart
also you can change the casino wallet in previouse file
for creating bot UI's please run in project terminal

```
flutter pub get
flutter build web --pwa-startegy=none
```

and after that in the build/web of this project you must move it into the "/var/www/winball.xyz" of your server .
for panel.winball.xyz you must do the same
