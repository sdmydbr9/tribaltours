import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditItineraryPage extends StatefulWidget {
  final String state;
  final DocumentSnapshot itinerary;

  EditItineraryPage({required this.state, required this.itinerary});

  @override
  _EditItineraryPageState createState() => _EditItineraryPageState();
}

class _EditItineraryPageState extends State<EditItineraryPage> {
  final TextEditingController _titleController = TextEditingController();
  List<Map<String, List<TextEditingController>>> _days = [];
  final Set<String> _selectedDestinations = {};
  List<String> _states = [];

  @override
  void initState() {
    super.initState();
    _fetchStates();
    _loadItineraryData();
  }

  Future<void> _fetchStates() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('destinations').get();
    setState(() {
      _states = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  void _loadItineraryData() {
    _titleController.text = widget.itinerary['title'];
    final List<dynamic> days = widget.itinerary['days'];

    for (var day in days) {
      final dayTitleController = TextEditingController(text: day['title']);
      final dayDetailsController = TextEditingController(text: day['details']);
      final List<TextEditingController> destinationControllers = [];

      for (var destination in day['destinations']) {
        destinationControllers.add(TextEditingController(text: destination));
        _selectedDestinations.add(destination);
      }

      _days.add({
        'title': [dayTitleController],
        'details': [dayDetailsController],
        'destinations': destinationControllers,
      });
    }
  }

  void _addDay() {
    setState(() {
      _days.add({
        'title': [TextEditingController()],
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
    if (_states.isEmpty) {
      return [];
    }

    List<String> destinations = [];

    final snapshot = await FirebaseFirestore.instance
        .collection('destinations')
        .doc(widget.state)
        .collection('destinations')
        .get();

    destinations.addAll(snapshot.docs
        .map((doc) => (doc['name'] as String).toLowerCase())
        .where((name) => !_selectedDestinations.contains(name)));

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

  void _submitItinerary() async {
    if (_titleController.text.isNotEmpty) {
      final title = _titleController.text;

      final itineraryRef = FirebaseFirestore.instance
          .collection('destinations')
          .doc(widget.state)
          .collection('itineraries')
          .doc(widget.itinerary.id);

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
        'createdAt': widget.itinerary['createdAt'],
      };

      // Log the data being saved
      print('Saving itinerary: $itineraryData');

      // Update the itinerary data in Firestore
      await itineraryRef.set(itineraryData);

      // Log success
      print('Itinerary updated successfully in Firestore.');

      // Show success alert
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Success'),
            content: Text('Itinerary updated successfully.'),
            actions: [
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context); // Dismiss the dialog
                  Navigator.pop(context); // Go back to the previous screen
                },
              ),
            ],
          );
        },
      );
    } else {
      print('Please enter a title.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Edit Itinerary'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _submitItinerary,
          child: Text('Save'),
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
                  itemCount: _days.length,
                  itemBuilder: (context, dayIndex) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Day ${dayIndex + 1}'),
                        CupertinoTextField(
                          controller: _days[dayIndex]['title']![0],
                          placeholder:
                              'Day Title', // Add placeholder for day title
                        ),
                        SizedBox(height: 8),
                        CupertinoTextField(
                          controller: _days[dayIndex]['details']![0],
                          placeholder: 'Details',
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
