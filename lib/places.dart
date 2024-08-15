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
  bool isAddingDestination = false;

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

  Future<bool> _destinationExists(String destinationName) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('destinations')
        .doc(selectedState)
        .collection('destinations')
        .where('name', isEqualTo: destinationName)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<List<String>> _getSuggestions(String query) async {
    if (selectedState == null || query.length < 3) {
      return [];
    }

    String lowercaseQuery = query.toLowerCase();

    final snapshot = await FirebaseFirestore.instance
        .collection('destinations')
        .doc(selectedState)
        .collection('destinations')
        .where('name', isGreaterThanOrEqualTo: lowercaseQuery)
        .where('name', isLessThan: lowercaseQuery + 'z')
        .get();

    return snapshot.docs
        .map((doc) => (doc['name'] as String).toLowerCase())
        .toList();
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
            largeTitle: LayoutBuilder(
              builder: (context, constraints) {
                final title = selectedState != null
                    ? 'Manage Places - $selectedState'
                    : 'Manage Places - Northeast India';

                final textStyle = TextStyle(
                  fontSize: _calculateTextSize(title, constraints.maxWidth),
                  color: textColor,
                );

                return Text(
                  title,
                  style: textStyle,
                );
              },
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(
                isAddingDestination ? CupertinoIcons.minus : CupertinoIcons.add,
                color: isAddingDestination
                    ? CupertinoColors.destructiveRed
                    : CupertinoColors.activeGreen,
              ),
              onPressed: () {
                setState(() {
                  isAddingDestination = !isAddingDestination;
                });
              },
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
                          border:
                              Border.all(color: CupertinoColors.inactiveGray),
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
                  if (isAddingDestination) ...[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CupertinoTypeAheadField<String>(
                        textFieldConfiguration: CupertinoTextFieldConfiguration(
                          controller: attractionController,
                          placeholder: 'Enter Destination Name',
                          style: TextStyle(color: textColor),
                          onChanged: (text) async {
                            final suggestions = await _getSuggestions(text);
                            setState(() {
                              isButtonDisabled =
                                  suggestions.isEmpty && text.isNotEmpty
                                      ? false
                                      : suggestions.isNotEmpty;
                            });
                          },
                        ),
                        suggestionsCallback: _getSuggestions,
                        itemBuilder: (context, suggestion) {
                          return Container(
                            color: Colors.transparent,
                            padding: const EdgeInsets.all(8.0),
                            child: Text(suggestion,
                                style: TextStyle(color: textColor)),
                          );
                        },
                        onSuggestionSelected: (suggestion) {
                          attractionController.text = suggestion;
                          setState(() {
                            isButtonDisabled = true;
                          });
                        },
                        noItemsFoundBuilder: (context) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('No suggestions found.',
                                style: TextStyle(color: textColor)),
                          );
                        },
                      ),
                    ),
                    CupertinoButton(
                      child: Text('Save Destination'),
                      color: isButtonDisabled
                          ? CupertinoColors.inactiveGray
                          : CupertinoColors.activeGreen,
                      onPressed: isButtonDisabled ? null : saveDestination,
                    ),
                  ],
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
                            builder: (context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                    child: CupertinoActivityIndicator());
                              }

                              var destinations = snapshot.data!.docs
                                  .map((doc) => formatName(doc['name']))
                                  .toList();

                              destinations.sort((a, b) =>
                                  a.toLowerCase().compareTo(b.toLowerCase()));

                              return ListView.builder(
                                itemCount: destinations.length,
                                itemBuilder: (context, index) {
                                  String formattedName = destinations[index];

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
                                          Text(
                                            '${index + 1}. $formattedName',
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                color: textColor),
                                          ),
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
                                                        destinationId: snapshot
                                                            .data!
                                                            .docs[index]
                                                            .id,
                                                        currentData: snapshot
                                                                .data!
                                                                .docs[index]
                                                                .data()
                                                            as Map<String,
                                                                dynamic>,
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
                                                  deleteDestination(snapshot
                                                      .data!.docs[index].id);
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

  double _calculateTextSize(String text, double maxWidth) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: 22.0), // Start with a large font size
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: maxWidth);

    if (textPainter.didExceedMaxLines) {
      return maxWidth / text.length * 1.6; // Adjusting factor
    }

    return 22.0; // Default font size
  }

  String formatName(String name) {
    return name
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
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
          isAddingDestination = false;
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
