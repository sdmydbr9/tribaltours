import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'edit_itinerary.dart';

class ViewItineraryPage extends StatefulWidget {
  @override
  _ViewItineraryPageState createState() => _ViewItineraryPageState();
}

class _ViewItineraryPageState extends State<ViewItineraryPage> {
  List<String> _states = [];
  String? _selectedState;
  List<DocumentSnapshot> _itineraries = [];

  @override
  void initState() {
    super.initState();
    _fetchStates();
  }

  Future<void> _fetchStates() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('destinations').get();
    setState(() {
      _states = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  Future<void> _fetchItineraries() async {
    if (_selectedState == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('destinations')
        .doc(_selectedState)
        .collection('itineraries')
        .get();

    setState(() {
      _itineraries = snapshot.docs;
    });
  }

  void _selectState() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text('Select State'),
          actions: _states.map((String state) {
            return CupertinoActionSheetAction(
              child: Text(state),
              onPressed: () {
                setState(() {
                  _selectedState = state;
                  _fetchItineraries();
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
          cancelButton: CupertinoActionSheetAction(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  void _editItinerary(DocumentSnapshot itinerary) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => EditItineraryPage(
          state: _selectedState!,
          itinerary: itinerary, // Passing the itinerary document
        ),
      ),
    ).then((value) {
      if (value == true) {
        _fetchItineraries(); // Refresh the list after editing
      }
    });
  }

  void _deleteItinerary(DocumentSnapshot itinerary) async {
    final docId = itinerary.id;

    await FirebaseFirestore.instance
        .collection('destinations')
        .doc(_selectedState)
        .collection('itineraries')
        .doc(docId)
        .delete();

    // Refresh the list of itineraries
    _fetchItineraries();

    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Deleted'),
          content: Text('Itinerary deleted successfully.'),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('View Itineraries'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 16),
            CupertinoButton(
              child: Text(
                  _selectedState == null ? 'Select State' : _selectedState!),
              onPressed: _selectState,
            ),
            Expanded(
              child: _selectedState == null
                  ? Center(
                      child: Text('Please select a state to view itineraries.'),
                    )
                  : _itineraries.isEmpty
                      ? Center(child: Text('No itineraries found.'))
                      : CupertinoScrollbar(
                          child: ListView.builder(
                            itemCount: _itineraries.length,
                            itemBuilder: (context, index) {
                              final itinerary = _itineraries[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {},
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        itinerary['title'],
                                        style: CupertinoTheme.of(context)
                                            .textTheme
                                            .navLargeTitleTextStyle,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Days: ${itinerary['days'].length} | Created: ${itinerary['createdAt'].toDate()}',
                                        style: CupertinoTheme.of(context)
                                            .textTheme
                                            .textStyle,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          CupertinoButton(
                                            padding: EdgeInsets.zero,
                                            child: Icon(CupertinoIcons.pencil),
                                            onPressed: () =>
                                                _editItinerary(itinerary),
                                          ),
                                          CupertinoButton(
                                            padding: EdgeInsets.zero,
                                            child: Icon(CupertinoIcons.delete),
                                            onPressed: () =>
                                                _deleteItinerary(itinerary),
                                          ),
                                        ],
                                      ),
                                      Divider(),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
