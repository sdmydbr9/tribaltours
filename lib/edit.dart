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
  List<TextEditingController> imageControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ]; // To store URLs

  @override
  void initState() {
    super.initState();
    infoController.text = widget.currentData['info'] ?? '';
    locationController.text = widget.currentData['location'] ?? '';
    bestTimeController.text = widget.currentData['best_time'] ?? '';
    knownForController.text = widget.currentData['known_for'] ?? '';
    recommendedDaysController.text =
        widget.currentData['recommended_days'] ?? '';

    // Populate the image URLs into the controllers if they exist
    List<dynamic>? images = widget.currentData['images'];
    if (images != null) {
      for (int i = 0; i < images.length && i < 4; i++) {
        imageControllers[i].text = images[i] ?? '';
      }
    }

    print("Initialized EditDestinationPage with ID: ${widget.destinationId}");
  }

  void saveChanges() {
    List<String> imageUrls = imageControllers
        .map((controller) => controller.text)
        .where((url) => url.isNotEmpty)
        .toList();

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
      'images': imageUrls,
    }).then((_) {
      print(
          "Changes saved successfully for destination ID: ${widget.destinationId}");
      Navigator.pop(context);
    }).catchError((error, stackTrace) {
      print("Error saving changes: $error");
      print("Stack trace: $stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save changes: $error')),
      );
    });
  }

  void showUrlPopup(int index) {
    TextEditingController urlController = imageControllers[index];

    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Edit Image URL'),
          content: Column(
            children: [
              CupertinoTextField(
                controller: urlController,
                placeholder: 'Enter Image URL',
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  // Updates the image URL in the controller
                });
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void addImageUrl() {
    if (imageControllers.length < 10) {
      setState(() {
        imageControllers.add(TextEditingController());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can only add up to 10 images.')),
      );
    }
  }

  void removeImageUrl(int index) {
    if (imageControllers.length > 1) {
      setState(() {
        imageControllers.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('At least one image is required.')),
      );
    }
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
                    SizedBox(height: 16.0),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ...List.generate(imageControllers.length, (index) {
                          return Stack(
                            children: [
                              GestureDetector(
                                onTap: () => showUrlPopup(index),
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  color: CupertinoColors.systemGrey5,
                                  child: imageControllers[index].text.isEmpty
                                      ? Icon(
                                          CupertinoIcons.photo,
                                          color: CupertinoColors.systemGrey,
                                          size: 100,
                                        )
                                      : Image.network(
                                          imageControllers[index].text,
                                          width: 100,
                                          height: 100,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Icon(
                                              CupertinoIcons.photo,
                                              color: CupertinoColors.systemGrey,
                                              size: 100,
                                            );
                                          },
                                        ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: Icon(CupertinoIcons.minus_circle),
                                  onPressed: () => removeImageUrl(index),
                                ),
                              ),
                            ],
                          );
                        }),
                        if (imageControllers.length < 10)
                          GestureDetector(
                            onTap: addImageUrl,
                            child: Container(
                              width: 100,
                              height: 100,
                              color: CupertinoColors.systemGrey5,
                              child: Center(
                                child: Icon(
                                  CupertinoIcons.add,
                                  color: CupertinoColors.systemGrey,
                                  size: 50,
                                ),
                              ),
                            ),
                          ),
                      ],
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
