import 'package:docflow/Providers/auth_provider.dart';
import 'package:docflow/Providers/firestore_provider.dart';
import 'package:docflow/Utils/colors.dart';
import 'package:docflow/Widgets/snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class DocsEditView extends StatefulWidget {
  String? titleData;
  String? contentData;
  String? docID;
  DocsEditView({
    super.key,
    required this.contentData,
    required this.titleData,
    required this.docID,
  });

  @override
  State<DocsEditView> createState() => _DocsEditViewState();
}

class _DocsEditViewState extends State<DocsEditView> {
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
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
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
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                            });
                      } else {
                        firestoreProvider
                            .updateTask(
                              docId: widget.docID as String,
                              title: titleController.text,
                              content: contentController.text,
                            )
                            .then((value) {
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                            });
                      }
                    },
                  ),
                  const Text('Edit Note', style: TextStyle(fontSize: 25)),
                  GestureDetector(
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: purpleColor.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.share, size: 25, color: Colors.black),
                    ),
                    onTap: () async {
                      emails = await authProvider.fetchEmails();
                      selectedRole = "Viewer"; // default value
                      final TextEditingController emailController =
                          TextEditingController();

                      showDialog(
                        // ignore: use_build_context_synchronously
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Add Collaborator"),
                            content: StatefulBuilder(
                              builder: (context, setState) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Email input
                                    DropdownButtonFormField<String>(
                                      initialValue: selectedEmail,
                                      hint: const Text("Select user email"),
                                      items: emails.map((email) {
                                        return DropdownMenuItem<String>(
                                          value: email,
                                          child: Text(email),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        selectedEmail = value;
                                      },
                                    ),

                                    const SizedBox(height: 16),
                                    // Role dropdown
                                    DropdownButtonFormField<String>(
                                      value: selectedRole,
                                      decoration: const InputDecoration(
                                        labelText: "Select Role",
                                        border: OutlineInputBorder(),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: "Viewer",
                                          child: Text("Viewer"),
                                        ),
                                        DropdownMenuItem(
                                          value: "Editor",
                                          child: Text("Editor"),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        if (value != null) {
                                          selectedRole = value;
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context), // cancel
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  final email = emailController.text;
                                  final role = selectedRole;
                                  firestoreProvider
                                      .updateCollaborators(
                                        collaboratorEmail:
                                            selectedEmail as String,
                                        docId: widget.docID as String,
                                        role: selectedRole as String,
                                      )
                                      .then((value) {
                                        showMySnackBar(
                                          context,
                                          'New Collaborator added!',
                                        );
                                      });
                                  debugPrint("Email: $email, Role: $role");
                                  Navigator.pop(context);
                                },
                                child: const Text("Save"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 25),
              TextField(
                controller: titleController,
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
                  controller: contentController,
                  decoration: InputDecoration(
                    hintText: 'Content',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 20),
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
    );
  }
}
