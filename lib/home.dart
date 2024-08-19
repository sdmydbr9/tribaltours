import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'places.dart';
import 'itinerary.dart';

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoButton(
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
              SizedBox(height: 20),
              CupertinoButton(
                child: Text(
                  'Manage Itineraries',
                  style: CupertinoTheme.of(context).textTheme.textStyle,
                ),
                color: CupertinoColors.activeBlue,
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => ItineraryPage()),
                  );
                },
              ),
              SizedBox(height: 20),
              CupertinoButton(
                child: Text(
                  'Logout',
                  style: CupertinoTheme.of(context).textTheme.textStyle,
                ),
                color: CupertinoColors.destructiveRed,
                onPressed: () {
                  // Logic to log out and navigate back to login screen
                  Navigator.of(context).popUntil((route) =>
                      route.isFirst); // Navigate back to the login screen
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
