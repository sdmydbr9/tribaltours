import 'package:flutter/cupertino.dart';
import 'places.dart';
import 'itinerary.dart';
import 'viewitinerary.dart';
import 'viewQuery.dart';

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
                  'View Itineraries',
                  style: CupertinoTheme.of(context).textTheme.textStyle,
                ),
                color: CupertinoColors.activeBlue,
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => ViewItineraryPage()),
                  );
                },
              ),
              SizedBox(height: 20),
              CupertinoButton(
                child: Text(
                  'View Queries',
                  style: CupertinoTheme.of(context).textTheme.textStyle,
                ),
                color: CupertinoColors.activeBlue,
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => ViewQueries(
                              destinationState: '',
                              itineraryId: '',
                            )),
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
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
