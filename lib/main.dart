import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'places.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyC9UB3pJXVa1Qf-H3WJJzJ9gPliTzb7zQ4",
        authDomain: "tribaltours-c59b9.firebaseapp.com",
        projectId: "tribaltours-c59b9",
        storageBucket: "tribaltours-c59b9.appspot.com",
        messagingSenderId: "22261552958",
        appId: "1:22261552958:web:31edbdd46d6c4c9869fe6f",
        measurementId: "G-LN1M7B2V64"),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Travel Booking Admin',
      theme: _getCupertinoTheme(context),
      home: HomePage(),
    );
  }

  CupertinoThemeData _getCupertinoTheme(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return CupertinoThemeData(
      brightness: brightness,
      primaryColor: CupertinoColors.systemBlue,
      scaffoldBackgroundColor: brightness == Brightness.dark
          ? CupertinoColors.black
          : CupertinoColors.white,
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          color: brightness == Brightness.dark
              ? CupertinoColors.white
              : CupertinoColors.black,
        ),
        navTitleTextStyle: TextStyle(
          color: brightness == Brightness.dark
              ? CupertinoColors.white
              : CupertinoColors.black,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
        actionTextStyle: TextStyle(color: CupertinoColors.systemBlue),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Admin Dashboard',
          style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: CupertinoButton(
            child: Text(
              'Manage Places',
              style: CupertinoTheme.of(context).textTheme.textStyle,
            ),
            color: CupertinoColors.activeBlue,
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => PlacesPage()),
              );
            },
          ),
        ),
      ),
    );
  }
}
