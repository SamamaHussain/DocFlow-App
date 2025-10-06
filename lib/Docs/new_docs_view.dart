import 'package:docflow/Providers/auth_provider.dart';
import 'package:docflow/Providers/firestore_provider.dart';
import 'package:docflow/Utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DocsView extends StatefulWidget {
  const DocsView({super.key});

  @override
  State<DocsView> createState() => _DocsViewState();
}

class _DocsViewState extends State<DocsView> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  @override
  void initState() {
    titleController = TextEditingController();
    contentController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    final firestoreProvider = Provider.of<FirestoreProvider>(
      context,
      listen: true,
    );
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
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
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
                            Navigator.pop(context);
                          } else {
                            firestoreProvider
                                .addTask(
                                  ownerId: authProvider.userModel!.uId!,
                                  title: titleController.text,
                                  content: contentController.text,
                                  email: authProvider.userModel!.email!,
                                )
                                .then((value) {
                                  Navigator.pop(context);
                                });
                          }
                        },
                      ),
                    ),
                    Center(
                      child: const Text(
                        'Add Note',
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 6),
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
                    controller: contentController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 6),
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
