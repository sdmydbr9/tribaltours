import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlacesPage extends StatefulWidget {
  @override
  _PlacesPageState createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage> {
  String? selectedState;
  TextEditingController attractionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    for (var state in states) {
      var stateDoc =
          await firestore.collection('destinations').doc(state).get();
      if (!stateDoc.exists) {
        await firestore
            .collection('destinations')
            .doc(state)
            .set({'state': state});
      }
    }
  }

  void _showStateSelector(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text('Select State'),
        actions: states.map((state) {
          return CupertinoActionSheetAction(
            onPressed: () {
              setState(() {
                selectedState = state;
              });
              Navigator.pop(context);
            },
            child: Text(state),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Manage Places - Northeast India'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () => _showStateSelector(context),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.inactiveGray),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Text(
                      selectedState ?? 'Select a State',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: selectedState == null
                            ? CupertinoColors.inactiveGray
                            : CupertinoColors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoTextField(
                controller: attractionController,
                placeholder: 'Enter Destination Name',
              ),
            ),
            CupertinoButton(
              child: Text('Save Destination'),
              color: CupertinoColors.activeGreen,
              onPressed: () {
                if (selectedState != null &&
                    attractionController.text.isNotEmpty) {
                  saveDestination();
                }
              },
            ),
            Expanded(
              child: selectedState == null
                  ? Center(
                      child:
                          Text('Please select a state to view destinations.'))
                  : StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('destinations')
                          .doc(selectedState)
                          .collection('destinations')
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CupertinoActivityIndicator());
                        }
                        var destinations = snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: destinations.length,
                          itemBuilder: (context, index) {
                            var destination = destinations[index];
                            return GestureDetector(
                              onTap: () {
                                // Handle tap if necessary
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 16.0, horizontal: 16.0),
                                decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: CupertinoColors.separator)),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(destination['name'],
                                        style: TextStyle(fontSize: 18.0)),
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      child: Icon(CupertinoIcons.delete,
                                          color:
                                              CupertinoColors.destructiveRed),
                                      onPressed: () {
                                        deleteDestination(destination.id);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void saveDestination() {
    if (selectedState != null && attractionController.text.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('destinations')
          .doc(selectedState)
          .collection('destinations')
          .add({
        'name': attractionController.text,
      });
      print(
          "Destination saved: ${attractionController.text} in state $selectedState");
      attractionController.clear();
    } else {
      print("State not selected or destination name is empty");
    }
  }

  void deleteDestination(String id) {
    FirebaseFirestore.instance
        .collection('destinations')
        .doc(selectedState)
        .collection('destinations')
        .doc(id)
        .delete();
  }
}

// Northeast India Data
List<String> states = [
  'Arunachal Pradesh',
  'Assam',
  'Manipur',
  'Meghalaya',
  'Mizoram',
  'Nagaland',
  'Sikkim',
  'Tripura',
];
