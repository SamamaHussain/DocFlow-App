import 'dart:developer' as dev;
import 'package:docflow/Docs/docs_edit_view.dart';
import 'package:docflow/Docs/editor_docs_view.dart';
import 'package:docflow/Docs/new_docs_view.dart';
import 'package:docflow/Docs/viewer_docs_view.dart';
import 'package:docflow/Providers/firestore_provider.dart';
import 'package:docflow/Widgets/snackbar_widget.dart';
import 'package:docflow/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:docflow/Providers/auth_provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    final firestoreProvider = Provider.of<FirestoreProvider>(
      context,
      listen: true,
    );

    dev.log('User model is: ${authProvider.userModel}');

    // List<dynamic> collaboratorsEmail = [];
    final filteredDocs = firestoreProvider.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['ownerid'] == authProvider.userModel!.uId;
    }).toList();

    final sharedDocs = firestoreProvider.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;

      final collaborators = List<Map<String, dynamic>>.from(
        data['collaborators'] ?? [],
      );

      // Since it's [{"email":"role", ...}] → only one map inside list
      if (collaborators.isEmpty) return false;

      final collabMap = collaborators.first; // take the first map
      return collabMap.containsKey(authProvider.userModel!.email);
    }).toList();

    return DefaultTabController(
      length: 2, // number of tabs
      child:
          authProvider.userModel?.uId == null ||
              authProvider.userModel?.FirstName == null
          ? Center(child: CircularProgressIndicator())
          : Scaffold(
              appBar: AppBar(
                title: Text('Hello ${authProvider.userModel!.FirstName}!'),
                bottom: const TabBar(
                  tabs: [
                    Tab(text: "My Docs"),
                    Tab(text: "Shared Docs"),
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Logout"),
                            content: const Text(
                              "Are you sure you want to log out?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Logout"),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        await authProvider.signOut().then((value) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const AuthView()),
                            (route) => false,
                          );
                        });
                      }
                    },
                    icon: Icon(Icons.logout_outlined),
                  ),
                ],
              ),
              body: TabBarView(
                children: [
                  Center(
                    child: ListView.builder(
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final doc = filteredDocs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        if (filteredDocs.isEmpty) {
                          return const Center(
                            child: Text("No documents found"),
                          );
                        }
                        return Card(
                          margin: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          child: ListTile(
                            title: Text(data['title'] ?? 'Untitled'),
                            subtitle: Text(data['content'] ?? 'No content'),
                            trailing: SizedBox(
                              width: 100,
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      final collaborators =
                                          List<Map<String, dynamic>>.from(
                                            data['collaborators'] ?? [],
                                          );

                                      // Flatten into emails list
                                      firestoreProvider.collabEmails =
                                          collaborators
                                              .expand((map) => map.keys)
                                              .toList();

                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          final provider = context
                                              .watch<FirestoreProvider>();

                                          if (firestoreProvider
                                              .collabEmails
                                              .isEmpty) {
                                            return AlertDialog(
                                              title: Text('Collaborators'),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              content: Center(
                                                child: Text(
                                                  'No collaborators yet.',
                                                ),
                                              ),
                                            );
                                          } else {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              title: const Text(
                                                "Collaborators",
                                              ),
                                              content: SizedBox(
                                                width: double.maxFinite,
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: provider
                                                      .collabEmails
                                                      .length,
                                                  itemBuilder: (context, index) {
                                                    final email = provider
                                                        .collabEmails[index];
                                                    final role = collaborators
                                                        .firstWhere(
                                                          (map) =>
                                                              map.containsKey(
                                                                email,
                                                              ),
                                                        )[email];
                                                    return ListTile(
                                                      title: Text(email),
                                                      subtitle: Text(
                                                        "Role: $role",
                                                      ),
                                                      trailing: SizedBox(
                                                        width: 150,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            TextButton(
                                                              onPressed: () {
                                                                firestoreProvider
                                                                    .deleteCollaborators(
                                                                      docId: doc
                                                                          .id,
                                                                      collaboratorEmail:
                                                                          email,
                                                                      Docmodel:
                                                                          provider
                                                                              .docModel,
                                                                    );
                                                              },
                                                              child: const Text(
                                                                "Remove",
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text("Close"),
                                                ),
                                              ],
                                            );
                                          }
                                        },
                                      );
                                    },
                                    icon: Icon(Icons.info_outline),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      firestoreProvider
                                          .deleteTask(docId: doc.id)
                                          .then(
                                            (value) => showMySnackBar(
                                              context,
                                              'Document deleted successfully!',
                                            ),
                                          );
                                    },
                                    icon: Icon(Icons.delete, color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DocsEditView(
                                    titleData: data['title'],
                                    contentData: data['content'],
                                    docID: doc.id,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Center(
                    child: ListView.builder(
                      itemCount: sharedDocs.length,
                      itemBuilder: (context, index) {
                        final doc = sharedDocs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        if (sharedDocs.isEmpty) {
                          return const Center(
                            child: Text("No documents found"),
                          );
                        }
                        return Card(
                          margin: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          child: ListTile(
                            title: Text(data['title'] ?? 'Untitled'),
                            subtitle: Text(data['content'] ?? 'No content'),
                            trailing: Icon(Icons.description),
                            onTap: () {
                              final collaborators =
                                  data['collaborators'] as List<dynamic>?;

                              // Get current user's email
                              final userEmail = authProvider.userModel!.email;
                              dev.log('$userEmail');

                              String? role;

                              if (collaborators != null &&
                                  collaborators.isNotEmpty &&
                                  userEmail != null) {
                                // since collaborators is a list of maps, loop through them
                                for (var collab in collaborators) {
                                  if (collab is Map<String, dynamic> &&
                                      collab.containsKey(userEmail)) {
                                    role = collab[userEmail];
                                    break;
                                  }
                                }
                              }

                              dev.log('$role');

                              if (role == "Editor") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditorDocsView(
                                      titleData: data['title'],
                                      contentData: data['content'],
                                      docID: doc.id,
                                    ),
                                  ),
                                );
                              } else if (role == "Viewer") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ViewerDocsView(
                                      // <- you need a read-only view
                                      titleData: data['title'],
                                      contentData: data['content'],
                                      docID: doc.id,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "You don’t have access to this document",
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DocsView()),
                  );
                },
                child: Icon(Icons.add),
              ),
            ),
    );
  }
}
