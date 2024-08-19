import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItineraryPage extends StatefulWidget {
  @override
  _ItineraryPageState createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  final TextEditingController _titleController = TextEditingController();
  String? _selectedState;
  List<Map<String, TextEditingController>> _days = [];
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
        'details': TextEditingController(),
        'destination': TextEditingController(),
      });
    });
  }

  void _removeDay() {
    if (_days.isNotEmpty) {
      setState(() {
        _selectedDestinations.remove(_days.last['destination']!.text);
        _days.removeLast();
      });
    }
  }

  Future<List<String>> _getDestinations() async {
    if (_selectedState == null) {
      return [];
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('destinations')
        .doc(_selectedState)
        .collection('destinations')
        .get();

    return snapshot.docs
        .map((doc) => (doc['name'] as String).toLowerCase())
        .where((name) => !_selectedDestinations.contains(name))
        .toList();
  }

  void _selectDestination(int index) async {
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
                _days[index]['destination']!.text = destination;
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
                  _selectedDestinations.clear();
                  _days.forEach((day) => day['destination']!.clear());
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

  void _submitItinerary() {
    if (_selectedState != null && _titleController.text.isNotEmpty) {
      // Implement the submission logic here.
      print(
          'Itinerary submitted: Title - ${_titleController.text}, State - $_selectedState');
    } else {
      // Handle the case where state or title is not selected
      print('Please select a state and enter a title.');
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CupertinoTextField(
                controller: _titleController,
                placeholder: 'Title',
              ),
              SizedBox(height: 16),
              CupertinoTextField(
                placeholder: 'Select State',
                readOnly: true,
                onTap: _selectState,
                controller: TextEditingController(text: _selectedState),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _days.length,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Day ${index + 1}'),
                        CupertinoTextField(
                          controller: _days[index]['details'],
                          placeholder: 'Details',
                        ),
                        SizedBox(height: 8),
                        CupertinoTextField(
                          controller: _days[index]['destination'],
                          placeholder: 'Destination',
                          readOnly: true,
                          onTap: () => _selectDestination(index),
                        ),
                        SizedBox(height: 16),
                      ],
                    );
                  },
                ),
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
    );
  }
}
