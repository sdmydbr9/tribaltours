import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItineraryPage extends StatefulWidget {
  @override
  _ItineraryPageState createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  final TextEditingController _titleController = TextEditingController();
  List<String?> _selectedStates = [null];
  List<Map<String, List<TextEditingController>>> _days = [];
  final Set<String> _selectedDestinations = {};
  List<String> _states = [];

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

  void _addDay() {
    setState(() {
      _days.add({
        'title': [TextEditingController()], // Add controller for title
        'details': [TextEditingController()],
        'destinations': [TextEditingController()],
      });
    });
  }

  void _removeDay() {
    if (_days.isNotEmpty) {
      setState(() {
        for (var controller in _days.last['destinations']!) {
          _selectedDestinations.remove(controller.text);
        }
        _days.removeLast();
      });
    }
  }

  Future<List<String>> _getDestinations() async {
    if (_selectedStates.isEmpty) {
      return [];
    }

    List<String> destinations = [];

    for (var state in _selectedStates.whereType<String>()) {
      final snapshot = await FirebaseFirestore.instance
          .collection('destinations')
          .doc(state)
          .collection('destinations')
          .get();

      destinations.addAll(snapshot.docs
          .map((doc) => (doc['name'] as String).toLowerCase())
          .where((name) => !_selectedDestinations.contains(name)));
    }

    return destinations;
  }

  void _selectDestination(int dayIndex, int destIndex) async {
    final destinations = await _getDestinations();

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text('Select Destination'),
          actions: destinations.map((String destination) {
            return CupertinoActionSheetAction(
              child: Text(destination),
              onPressed: () {
                _days[dayIndex]['destinations']![destIndex].text = destination;
                setState(() {
                  _selectedDestinations.add(destination);
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

  void _addDestination(int dayIndex) {
    setState(() {
      _days[dayIndex]['destinations']!.add(TextEditingController());
    });
  }

  void _removeDestination(int dayIndex, int destIndex) {
    setState(() {
      _selectedDestinations
          .remove(_days[dayIndex]['destinations']![destIndex].text);
      _days[dayIndex]['destinations']!.removeAt(destIndex);
    });
  }

  void _selectState(int index) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text('Select State'),
          actions: _states
              .where((state) => !_selectedStates.contains(state))
              .map((String state) {
            return CupertinoActionSheetAction(
              child: Text(state),
              onPressed: () {
                setState(() {
                  _selectedStates[index] = state;
                  _selectedDestinations.clear();
                  for (var day in _days) {
                    for (var controller in day['destinations']!) {
                      controller.clear();
                    }
                  }
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

  void _addState() {
    setState(() {
      _selectedStates.add(null);
    });
  }

  void _removeState(int index) {
    setState(() {
      _selectedStates.removeAt(index);
      _selectedDestinations.clear();
      for (var day in _days) {
        for (var controller in day['destinations']!) {
          controller.clear();
        }
      }
    });
  }

  void _submitItinerary() async {
    if (_selectedStates.isNotEmpty && _titleController.text.isNotEmpty) {
      final title = _titleController.text;

      // Iterate over each selected state
      for (var state in _selectedStates.whereType<String>()) {
        final itineraryRef = FirebaseFirestore.instance
            .collection('destinations')
            .doc(state)
            .collection('itineraries')
            .doc(); // Generate a new document ID

        // Prepare the data for each day
        List<Map<String, dynamic>> daysData = [];
        for (var i = 0; i < _days.length; i++) {
          final day = _days[i];
          daysData.add({
            'day': i + 1,
            'title': day['title']![0].text, // Include the title of the day
            'details': day['details']![0].text,
            'destinations': day['destinations']!
                .map((controller) => controller.text)
                .toList(),
          });
        }

        // Prepare the itinerary data
        final itineraryData = {
          'title': title,
          'days': daysData,
          'createdAt': Timestamp.now(),
        };

        // Add the itinerary data to Firestore
        await itineraryRef.set(itineraryData);
      }

      // Show success alert
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Success'),
            content: Text('Itinerary submitted successfully.'),
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

      // Clear the form
      _titleController.clear();
      _selectedStates = [null];
      _days.clear();
      _selectedDestinations.clear();

      setState(() {}); // Refresh the UI
    } else {
      print('Please select at least one state and enter a title.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Manage Itinerary'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _submitItinerary,
          child: Text('Submit'),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CupertinoTextField(
                  controller: _titleController,
                  placeholder: 'Title',
                ),
                SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _selectedStates.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Expanded(
                          child: CupertinoTextField(
                            placeholder: _selectedStates[index] == null
                                ? 'Select State'
                                : _selectedStates[index],
                            readOnly: true,
                            onTap: () => _selectState(index),
                          ),
                        ),
                        if (index > 0)
                          CupertinoButton(
                            child: Icon(CupertinoIcons.minus_circle),
                            onPressed: () => _removeState(index),
                          ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 16),
                CupertinoButton(
                  child: Text('Select Another State'),
                  onPressed: _addState,
                ),
                SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _days.length,
                  itemBuilder: (context, dayIndex) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Day ${dayIndex + 1}'),
                            SizedBox(width: 16),
                            Expanded(
                              child: CupertinoTextField(
                                controller: _days[dayIndex]
                                    ['title']![0], // Use the correct controller
                                placeholder: 'Title',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        CupertinoTextField(
                          controller: _days[dayIndex]['details']![0],
                          placeholder: 'Details',
                          maxLines:
                              6, // Allows for a larger input area for paragraphs
                          minLines:
                              3, // Sets the minimum number of visible lines
                        ),
                        SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _days[dayIndex]['destinations']!.length,
                          itemBuilder: (context, destIndex) {
                            return Row(
                              children: [
                                Expanded(
                                  child: CupertinoTextField(
                                    controller: _days[dayIndex]
                                        ['destinations']![destIndex],
                                    placeholder: 'Destination',
                                    readOnly: true,
                                    onTap: () =>
                                        _selectDestination(dayIndex, destIndex),
                                  ),
                                ),
                                if (destIndex > 0)
                                  CupertinoButton(
                                    child: Icon(CupertinoIcons.minus_circle),
                                    onPressed: () =>
                                        _removeDestination(dayIndex, destIndex),
                                  ),
                              ],
                            );
                          },
                        ),
                        CupertinoButton(
                          child: Icon(CupertinoIcons.add_circled),
                          onPressed: () => _addDestination(dayIndex),
                        ),
                        SizedBox(height: 16),
                      ],
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoButton(
                      child: Icon(CupertinoIcons.add),
                      onPressed: _addDay,
                    ),
                    CupertinoButton(
                      child: Icon(CupertinoIcons.minus),
                      onPressed: _removeDay,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
