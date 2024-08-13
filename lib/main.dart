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
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Admin Dashboard'),
      ),
      child: SafeArea(
        child: Center(
          child: CupertinoButton(
            child: Text('Manage Places'),
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
