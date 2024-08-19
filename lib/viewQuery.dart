import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        middle: Text('View Queries'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select a State:'),
                  CupertinoButton(
                    child: Text(
                      _selectedState ?? 'Select State',
                      textAlign: TextAlign.left,
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
                ],
              ),
            ),
            if (_selectedState != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select an Itinerary:'),
                    CupertinoButton(
                      child: Text(
                        _selectedItineraryTitle ?? 'Select Itinerary',
                        textAlign: TextAlign.left,
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
                            _selectedItineraryTitle =
                                selectedItinerary['title'];
                          });
                        }
                      },
                    ),
                  ],
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
    );
  }
}

class QueryResultsPage extends StatelessWidget {
  final String destinationState;
  final String itineraryId;

  QueryResultsPage({
    required this.destinationState,
    required this.itineraryId,
  });

  @override
  Widget build(BuildContext context) {
    DocumentReference itineraryRef = FirebaseFirestore.instance
        .collection('destinations')
        .doc(destinationState)
        .collection('itineraries')
        .doc(itineraryId);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Query Results'),
      ),
      child: FutureBuilder<DocumentSnapshot>(
        future: itineraryRef.get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CupertinoActivityIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data available.'));
          }

          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          Map<String, dynamic> queries = data['query'] ?? {};

          if (queries.isEmpty) {
            return Center(child: Text('No queries found.'));
          }

          return CupertinoScrollbar(
            child: ListView.builder(
              itemCount: queries.length,
              itemBuilder: (context, index) {
                String queryKey = queries.keys.elementAt(index);
                Map<String, dynamic> queryData = queries[queryKey];

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CupertinoButton(
                    color: CupertinoColors.systemGrey5,
                    padding: EdgeInsets.all(10.0),
                    borderRadius: BorderRadius.circular(10.0),
                    onPressed: () {},
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking ID: $queryKey',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 5),
                        Text('Name: ${queryData['name']}'),
                        Text('Email: ${queryData['email']}'),
                        Text('Phone: ${queryData['phoneNumber']}'),
                        Text('Country: ${queryData['country']}'),
                        Text('State: ${queryData['state']}'),
                        Text(
                            'Tentative Arrival: ${queryData['tentativeArrival'].toDate()}'),
                        Text(
                            'Tentative Departure: ${queryData['tentativeDeparture'].toDate()}'),
                        Text('Number of Pax: ${queryData['numberOfPax']}'),
                        Text(
                            'Submitted At: ${queryData['submittedAt'].toDate()}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
