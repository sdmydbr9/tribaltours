import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: CupertinoFormSection(
                    header: Text('Booking ID: $queryKey'),
                    children: [
                      Row(
                        children: [
                          Icon(CupertinoIcons.person,
                              color: CupertinoColors.activeBlue),
                          SizedBox(width: 10),
                          Text(queryData['name']),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(CupertinoIcons.mail,
                              color: CupertinoColors.activeGreen),
                          SizedBox(width: 10),
                          Text(queryData['email']),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(CupertinoIcons.phone,
                              color: CupertinoColors.activeOrange),
                          SizedBox(width: 10),
                          Text(queryData['phoneNumber']),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(CupertinoIcons.map,
                              color: CupertinoColors.systemPurple),
                          SizedBox(width: 10),
                          Text(queryData['country']),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(CupertinoIcons.location,
                              color: CupertinoColors.systemRed),
                          SizedBox(width: 10),
                          Text(queryData['state']),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(CupertinoIcons.calendar,
                              color: CupertinoColors.systemYellow),
                          SizedBox(width: 10),
                          Text(queryData['tentativeArrival']
                              .toDate()
                              .toString()),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(CupertinoIcons.calendar_today,
                              color: CupertinoColors.systemIndigo),
                          SizedBox(width: 10),
                          Text(queryData['tentativeDeparture']
                              .toDate()
                              .toString()),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(CupertinoIcons.person_2,
                              color: CupertinoColors.systemTeal),
                          SizedBox(width: 10),
                          Text(queryData['numberOfPax'].toString()),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(CupertinoIcons.time,
                              color: CupertinoColors.systemGrey),
                          SizedBox(width: 10),
                          Text(queryData['submittedAt'].toDate().toString()),
                        ],
                      ),
                    ],
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
