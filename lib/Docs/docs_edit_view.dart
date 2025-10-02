import 'package:docflow/Providers/auth_provider.dart';
import 'package:docflow/Providers/firestore_provider.dart';
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
        actions: [
          IconButton(
            onPressed: () async {
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
                        onPressed: () => Navigator.pop(context), // cancel
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final email = emailController.text;
                          final role = selectedRole;
                          firestoreProvider
                              .updateCollaborators(
                                collaboratorEmail: selectedEmail as String,
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
            icon: Icon(Icons.share),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
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
