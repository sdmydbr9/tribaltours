import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'query_details.dart';

class ViewQueries extends StatefulWidget {
  final String destinationState;
  final String itineraryId;

  ViewQueries({required this.destinationState, required this.itineraryId});

  @override
  _ViewQueriesState createState() => _ViewQueriesState();
}

class _ViewQueriesState extends State<ViewQueries> {
  List<String> _states = [];
  List<DocumentSnapshot> _itineraries = [];
  String? _selectedState;
  String? _selectedItineraryId;
  String? _selectedItineraryTitle;

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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        middle: Text('View Queries'),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CupertinoButton(
                  child: Text(
                    _selectedState != null
                        ? 'Selected State: $_selectedState'
                        : 'Select a State',
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () async {
                    String? selected = await showCupertinoModalPopup<String>(
                      context: context,
                      builder: (BuildContext context) {
                        return CupertinoActionSheet(
                          actions: _states.map((state) {
                            return CupertinoActionSheetAction(
                              child: Text(state, textAlign: TextAlign.left),
                              onPressed: () {
                                Navigator.pop(context, state);
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
                    if (selected != null) {
                      setState(() {
                        _selectedState = selected;
                        _selectedItineraryId = null;
                        _selectedItineraryTitle = null;
                      });
                      _fetchItineraries();
                    }
                  },
                ),
              ),
              if (_selectedState != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CupertinoButton(
                    child: Text(
                      _selectedItineraryTitle != null
                          ? 'Selected Itinerary: $_selectedItineraryTitle'
                          : 'Select an Itinerary',
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () async {
                      final selectedItinerary =
                          await showCupertinoModalPopup<Map<String, String>>(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoActionSheet(
                            actions: _itineraries.map((itinerary) {
                              final data =
                                  itinerary.data() as Map<String, dynamic>?;
                              final title = data?['title'] ?? 'Untitled';
                              return CupertinoActionSheetAction(
                                child: Text(title, textAlign: TextAlign.left),
                                onPressed: () {
                                  Navigator.pop(context, {
                                    'id': itinerary.id,
                                    'title': title,
                                  });
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
                      if (selectedItinerary != null) {
                        setState(() {
                          _selectedItineraryId = selectedItinerary['id'];
                          _selectedItineraryTitle = selectedItinerary['title'];
                        });
                      }
                    },
                  ),
                ),
              SizedBox(height: 20),
              CupertinoButton(
                child: Text('View Queries'),
                color: CupertinoColors.activeBlue,
                onPressed:
                    (_selectedState != null && _selectedItineraryId != null)
                        ? () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => QueryResultsPage(
                                  destinationState: _selectedState!,
                                  itineraryId: _selectedItineraryId!,
                                ),
                              ),
                            );
                          }
                        : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
