import 'package:docflow/Providers/firestore_provider.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () {
            if (titleController.text.isEmpty &&
                contentController.text.isEmpty) {
              firestoreProvider.deleteTask(docId: widget.docID as String).then((
                value,
              ) {
                Navigator.pop(context);
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
        ]
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextStyle(
                color: Colors.grey[900],
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: TextField(
                readOnly: true,
                controller: contentController,
                decoration: InputDecoration(
                  hintText: 'Content',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
                style: TextStyle(color: Colors.grey[900]),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
