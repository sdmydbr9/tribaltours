import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditDestinationPage extends StatefulWidget {
  final String state;
  final String destinationId;
  final Map<String, dynamic> currentData;

  EditDestinationPage({
    required this.state,
    required this.destinationId,
    required this.currentData,
  });

  @override
  _EditDestinationPageState createState() => _EditDestinationPageState();
}

class _EditDestinationPageState extends State<EditDestinationPage> {
  TextEditingController infoController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController bestTimeController = TextEditingController();
  TextEditingController knownForController = TextEditingController();
  TextEditingController recommendedDaysController = TextEditingController();

  @override
  void initState() {
    super.initState();
    infoController.text = widget.currentData['info'] ?? '';
    locationController.text = widget.currentData['location'] ?? '';
    bestTimeController.text = widget.currentData['best_time'] ?? '';
    knownForController.text = widget.currentData['known_for'] ?? '';
    recommendedDaysController.text =
        widget.currentData['recommended_days'] ?? '';
  }

  void saveChanges() {
    FirebaseFirestore.instance
        .collection('destinations')
        .doc(widget.state)
        .collection('destinations')
        .doc(widget.destinationId)
        .update({
      'info': infoController.text,
      'location': locationController.text,
      'best_time': bestTimeController.text,
      'known_for': knownForController.text,
      'recommended_days': recommendedDaysController.text,
    }).then((_) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text('${widget.currentData['name'] ?? 'Destination'}'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Text('Save'),
              onPressed: saveChanges,
            ),
          ),
          SliverFillRemaining(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CupertinoTextField(
                      controller: infoController,
                      placeholder: 'Brief Description',
                      maxLines: 3,
                    ),
                    SizedBox(height: 16.0),
                    CupertinoTextField(
                      controller: locationController,
                      placeholder: 'Location (Coordinates)',
                    ),
                    SizedBox(height: 16.0),
                    CupertinoTextField(
                      controller: bestTimeController,
                      placeholder: 'Best Time to Visit',
                    ),
                    SizedBox(height: 16.0),
                    CupertinoTextField(
                      controller: knownForController,
                      placeholder: 'Known For',
                    ),
                    SizedBox(height: 16.0),
                    CupertinoTextField(
                      controller: recommendedDaysController,
                      placeholder: 'Recommended Number of Days',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
