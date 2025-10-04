import 'dart:developer' as dev;
import 'package:docflow/Docs/docs_edit_view.dart';
import 'package:docflow/Docs/editor_docs_view.dart';
import 'package:docflow/Docs/new_docs_view.dart';
import 'package:docflow/Docs/viewer_docs_view.dart';
import 'package:docflow/Providers/firestore_provider.dart';
import 'package:docflow/Utils/colors.dart';
import 'package:docflow/Widgets/snackbar_widget.dart';
import 'package:docflow/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:docflow/Providers/auth_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isMyDocsSelected = true; // State to track selected tab

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    final firestoreProvider = Provider.of<FirestoreProvider>(
      context,
      listen: true,
    );

    dev.log('User model is: ${authProvider.userModel}');

    final filteredDocs = firestoreProvider.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['ownerid'] == authProvider.userModel!.uId;
    }).toList();

    final sharedDocs = firestoreProvider.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final collaborators = List<Map<String, dynamic>>.from(
        data['collaborators'] ?? [],
      );
      if (collaborators.isEmpty) return false;
      final collabMap = collaborators.first;
      return collabMap.containsKey(authProvider.userModel!.email);
    }).toList();

    final currentDocs = _isMyDocsSelected ? filteredDocs : sharedDocs;

    return authProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            backgroundColor: Colors.transparent,
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
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Custom Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Hello ${authProvider.userModel!.FirstName}!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Logout"),
                                    content: const Text(
                                      "Are you sure you want to log out?",
                                    ),
                                    actions: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          color: purpleColor.withOpacity(0.3),
                                        ),
                                        child: TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text(
                                            "Cancel",
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          color: purpleColor.withOpacity(0.3),
                                        ),
                                        child: TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text(
                                            "Logout",
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirm == true) {
                                await authProvider.signOut().then((value) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AuthView(),
                                    ),
                                    (route) => false,
                                  );
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: purpleColor.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.logout_outlined,
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Clickable Tabs
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isMyDocsSelected = true;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: _isMyDocsSelected
                                      ? purpleColor
                                      : const Color.fromARGB(
                                          255,
                                          247,
                                          247,
                                          255,
                                        ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "My Docs",
                                  style: TextStyle(
                                    color: _isMyDocsSelected
                                        ? Colors.black
                                        : Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isMyDocsSelected = false;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: !_isMyDocsSelected
                                      ? purpleColor
                                      : Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "Shared Docs",
                                  style: TextStyle(
                                    color: !_isMyDocsSelected
                                        ? Colors.black
                                        : Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Document List
                      Expanded(
                        child: currentDocs.isEmpty
                            ? const Center(child: Text("No documents found"))
                            : ListView.builder(
                                itemCount: currentDocs.length,
                                itemBuilder: (context, index) {
                                  final doc = currentDocs[index];
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: GestureDetector(
                                      child: Container(
                                        padding: const EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                          color: purpleColor.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data['title'] ?? 'Untitled',
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(height: 15),
                                            Text(
                                              data['content'] ?? 'No content',
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(height: 15),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    timeago.format(
                                                      data['lastUpdated']
                                                              ?.toDate() ??
                                                          DateTime.now(),
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  if (_isMyDocsSelected) ...[
                                                    Row(
                                                      children: [
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: purpleColor
                                                                    .withOpacity(
                                                                      0.3,
                                                                    ),
                                                              ),
                                                          child: IconButton(
                                                            onPressed: () {
                                                              final collaborators =
                                                                  List<
                                                                    Map<
                                                                      String,
                                                                      dynamic
                                                                    >
                                                                  >.from(
                                                                    data['collaborators'] ??
                                                                        [],
                                                                  );
                                                              firestoreProvider
                                                                      .collabEmails =
                                                                  collaborators
                                                                      .expand(
                                                                        (
                                                                          map,
                                                                        ) => map
                                                                            .keys,
                                                                      )
                                                                      .toList();
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder: (context) {
                                                                  final provider =
                                                                      context
                                                                          .watch<
                                                                            FirestoreProvider
                                                                          >();
                                                                  if (provider
                                                                      .collabEmails
                                                                      .isEmpty) {
                                                                    return AlertDialog(
                                                                      title: const Text(
                                                                        'Collaborators',
                                                                      ),
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              16,
                                                                            ),
                                                                      ),
                                                                      content: ConstrainedBox(
                                                                        constraints: const BoxConstraints(
                                                                          maxWidth:
                                                                              200,
                                                                        ), // Compact width
                                                                        child: Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min, // Fit content height
                                                                          children: [
                                                                            Text(
                                                                              'No collaborators yet.',
                                                                              textAlign: TextAlign.center,
                                                                              style: TextStyle(
                                                                                color: Colors.black,
                                                                                fontSize: 16,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      actions: [
                                                                        Container(
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(
                                                                              10,
                                                                            ),
                                                                            color: purpleColor.withOpacity(
                                                                              0.3,
                                                                            ), // Match your app’s style
                                                                          ),
                                                                          child: TextButton(
                                                                            onPressed: () => Navigator.pop(
                                                                              context,
                                                                            ),
                                                                            child: const Text(
                                                                              "Close",
                                                                              style: TextStyle(
                                                                                color: Colors.black,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  }
                                                                  return AlertDialog(
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            16,
                                                                          ),
                                                                    ),
                                                                    title: const Text(
                                                                      "Collaborators",
                                                                    ),
                                                                    content: SizedBox(
                                                                      width: double
                                                                          .maxFinite,
                                                                      child: ListView.builder(
                                                                        shrinkWrap:
                                                                            true,
                                                                        itemCount: provider
                                                                            .collabEmails
                                                                            .length,
                                                                        itemBuilder:
                                                                            (
                                                                              context,
                                                                              index,
                                                                            ) {
                                                                              final email = provider.collabEmails[index];
                                                                              final role = collaborators.firstWhere(
                                                                                (
                                                                                  map,
                                                                                ) => map.containsKey(
                                                                                  email,
                                                                                ),
                                                                              )[email];
                                                                              return ListTile(
                                                                                title: Text(
                                                                                  email,
                                                                                  style: TextStyle(
                                                                                    fontSize: 13,
                                                                                  ),
                                                                                ),
                                                                                subtitle: Text(
                                                                                  "Role: $role",
                                                                                ),
                                                                                trailing: SizedBox(
                                                                                  width: 80,
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                                    children: [
                                                                                      TextButton(
                                                                                        onPressed: () {
                                                                                          firestoreProvider.deleteCollaborators(
                                                                                            docId: doc.id,
                                                                                            collaboratorEmail: email,
                                                                                            Docmodel: provider.docModel,
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
                                                                            Navigator.pop(
                                                                              context,
                                                                            ),
                                                                        child: const Text(
                                                                          "Close",
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            icon: Icon(
                                                              Icons
                                                                  .info_outline,
                                                              color:
                                                                  Color.fromARGB(
                                                                    255,
                                                                    43,
                                                                    43,
                                                                    43,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 10),

                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: purpleColor
                                                                    .withOpacity(
                                                                      0.3,
                                                                    ),
                                                              ),
                                                          child: IconButton(
                                                            onPressed: () {
                                                              firestoreProvider
                                                                  .deleteTask(
                                                                    docId:
                                                                        doc.id,
                                                                  )
                                                                  .then(
                                                                    (
                                                                      value,
                                                                    ) => showMySnackBar(
                                                                      context,
                                                                      'Document deleted successfully!',
                                                                    ),
                                                                  );
                                                            },
                                                            icon: Icon(
                                                              Icons.delete,
                                                              color:
                                                                  Color.fromARGB(
                                                                    255,
                                                                    207,
                                                                    72,
                                                                    62,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      onTap: () {
                                        if (_isMyDocsSelected) {
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
                                        } else {
                                          final collaborators =
                                              data['collaborators']
                                                  as List<dynamic>?;
                                          final userEmail =
                                              authProvider.userModel!.email;
                                          dev.log('$userEmail');
                                          String? role;
                                          if (collaborators != null &&
                                              collaborators.isNotEmpty &&
                                              userEmail != null) {
                                            for (var collab in collaborators) {
                                              if (collab
                                                      is Map<String, dynamic> &&
                                                  collab.containsKey(
                                                    userEmail,
                                                  )) {
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
                                                  titleData: data['title'],
                                                  contentData: data['content'],
                                                  docID: doc.id,
                                                ),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "You don’t have access to this document",
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: purpleColor,
              shape: CircleBorder(),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DocsView()),
                );
              },
              child: Icon(Icons.add, color: Colors.black),
            ),
          );
  }
}
