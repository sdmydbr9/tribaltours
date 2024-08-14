import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'edit.dart';

class PlacesPage extends StatefulWidget {
  @override
  _PlacesPageState createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage> {
  String? selectedState;
  TextEditingController attractionController = TextEditingController();
  bool isButtonDisabled = true;

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

  Future<List<String>> _getSuggestions(String query) async {
    if (selectedState == null || query.isEmpty) {
      return [];
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('destinations')
        .doc(selectedState)
        .collection('destinations')
        .get();

    return snapshot.docs
        .map((doc) => doc['name'] as String)
        .where((name) => name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<bool> _destinationExists(String destinationName) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('destinations')
        .doc(selectedState)
        .collection('destinations')
        .where('name', isEqualTo: destinationName)
        .get();

    return snapshot.docs.isNotEmpty;
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
    final brightness = CupertinoTheme.of(context).brightness;
    final textColor = brightness == Brightness.dark
        ? CupertinoColors.white
        : CupertinoColors.black;

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(
              'Manage Places - Northeast India',
              style: TextStyle(color: textColor),
            ),
          ),
          SliverFillRemaining(
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
                                  : textColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CupertinoTypeAheadField<String>(
                      hideOnEmpty: true,
                      suggestionsCallback: (pattern) async {
                        return await _getSuggestions(pattern);
                      },
                      itemBuilder: (context, suggestion) {
                        return CupertinoListTile(
                          title: Text(suggestion),
                        );
                      },
                      onSelected: (suggestion) {
                        attractionController.text = suggestion;
                        _destinationExists(suggestion).then((exists) {
                          setState(() {
                            isButtonDisabled = exists;
                          });
                        });
                      },
                      builder: (context, controller, focusNode) {
                        return CupertinoTextField(
                          controller: controller,
                          focusNode: focusNode,
                          autofocus: true,
                          style: TextStyle(color: textColor),
                          placeholder: 'Enter Destination Name',
                        );
                      },
                      decorationBuilder: (context, child) => DecoratedBox(
                        decoration: BoxDecoration(
                          color: CupertinoTheme.of(context)
                              .barBackgroundColor
                              .withOpacity(1),
                          border: Border.all(
                            color: CupertinoDynamicColor.resolve(
                              CupertinoColors.systemGrey4,
                              context,
                            ),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: child,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    child: Text('Save Destination'),
                    color: isButtonDisabled
                        ? CupertinoColors.inactiveGray
                        : CupertinoColors.activeGreen,
                    onPressed: isButtonDisabled ? null : saveDestination,
                  ),
                  Expanded(
                    child: selectedState == null
                        ? Center(
                            child: Text(
                              'Please select a state to view destinations.',
                              style: TextStyle(color: textColor),
                            ),
                          )
                        : StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('destinations')
                                .doc(selectedState)
                                .collection('destinations')
                                .snapshots(),
                            builder:
                                (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                    child: CupertinoActivityIndicator());
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
                                                color:
                                                    CupertinoColors.separator)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(destination['name'],
                                              style: TextStyle(
                                                  fontSize: 18.0,
                                                  color: textColor)),
                                          Row(
                                            children: [
                                              CupertinoButton(
                                                padding: EdgeInsets.zero,
                                                child: Icon(
                                                    CupertinoIcons.pencil,
                                                    color: CupertinoColors
                                                        .activeBlue),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    CupertinoPageRoute(
                                                      builder: (context) =>
                                                          EditDestinationPage(
                                                        state: selectedState!,
                                                        destinationId:
                                                            destination.id,
                                                        currentData:
                                                            destination.data() as Map<String, dynamic>,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              CupertinoButton(
                                                padding: EdgeInsets.zero,
                                                child: Icon(
                                                    CupertinoIcons.delete,
                                                    color: CupertinoColors
                                                        .destructiveRed),
                                                onPressed: () {
                                                  deleteDestination(
                                                      destination.id);
                                                },
                                              ),
                                            ],
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
          ),
        ],
      ),
    );
  }

  void saveDestination() async {
    if (selectedState != null && attractionController.text.isNotEmpty) {
      final exists = await _destinationExists(attractionController.text);
      if (!exists) {
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
        setState(() {
          isButtonDisabled = true;
        });
      } else {
        print("Destination already exists");
      }
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
