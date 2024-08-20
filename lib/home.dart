import 'package:flutter/cupertino.dart';
import 'places.dart';
import 'itinerary.dart';
import 'viewitinerary.dart';
import 'viewQuery.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.location),
            label: 'Manage Places',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.calendar),
            label: 'Manage Itineraries',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.eye),
            label: 'View Itineraries',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.mail),
            label: 'View Queries',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        Widget page;
        switch (index) {
          case 0:
            page = PlacesPage();
            break;
          case 1:
            page = ItineraryPage();
            break;
          case 2:
            page = ViewItineraryPage();
            break;
          case 3:
            page = ViewQueries(
              destinationState: '',
              itineraryId: '',
            );
            break;
          default:
            page = PlacesPage();
        }
        return CupertinoPageScaffold(
          child: page,
        );
      },
    );
  }
}
