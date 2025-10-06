import 'package:docflow/Providers/firestore_provider.dart';
import 'package:docflow/Utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ViewerDocsView extends StatefulWidget {
  String? titleData;
  String? contentData;
  String? docID;
  ViewerDocsView({
    super.key,
    required this.contentData,
    required this.titleData,
    required this.docID,
  });

  @override
  State<ViewerDocsView> createState() => _ViewerDocsViewState();
}

class _ViewerDocsViewState extends State<ViewerDocsView> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  List<String> emails = [];
  String? selectedEmail;
  String? selectedRole;
  @override
  void initState() {
    titleController = TextEditingController(text: widget.titleData);
    contentController = TextEditingController(text: widget.contentData);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreProvider = Provider.of<FirestoreProvider>(
      context,
      listen: true,
    );
    // final authProvider = Provider.of<AuthProvider>(context, listen: true);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 245, 247, 255), // Deep blue
                Color.fromARGB(255, 235, 255, 252), // Purple
                Color.fromARGB(255, 254, 241, 255), // Pink
                Color.fromARGB(255, 255, 247, 232), // Reddish-pink
              ],
              stops: [0.0, 0.3, 0.6, 1.0],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        child: Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: purpleColor.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            size: 25,
                            color: Colors.black,
                          ),
                        ),
                        onTap: () {
                          if (titleController.text.isEmpty &&
                              contentController.text.isEmpty) {
                            firestoreProvider
                                .deleteTask(docId: widget.docID as String)
                                .then((value) {
                                  Navigator.pop(context);
                                });
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                TextField(
                  controller: titleController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Title',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.grey[900],
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 18),
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: contentController,
                    decoration: InputDecoration(
                      hintText: 'Content',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 20,
                      ),
                    ),
                    style: TextStyle(color: Colors.grey[900], fontSize: 20),
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
