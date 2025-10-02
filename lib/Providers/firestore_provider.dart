import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docflow/Models/docs_model.dart';
import 'package:flutter/material.dart';

class FirestoreProvider extends ChangeNotifier {
  DocModel docModel = DocModel();
  List<DocumentSnapshot> docs = [];
  bool isLoading = false;
  bool isCompleted = false;
  List collabEmails = [];

  FirestoreProvider() {
    fetchTasks();
  }

  Future<void> addTask({
    required String ownerId,
    required String title,
    required String content,
    required String email,
  }) async {
    try {
      docModel = DocModel(
        owenerID: ownerId,
        content: content,
        title: title,
        email: email,
        collaborators: [],
      );

      //   'collaborators': {'uid456': 'editor', 'uid789': 'viewer'},

      await FirebaseFirestore.instance.collection('docs').add(docModel.toMap());
      fetchTasks();
      dev.log('Task added by user: $ownerId');
    } catch (e) {
      dev.log('Error adding task: $e');
    }
    notifyListeners();
    // await fetchTasks(uid);
  }

  Future<void> fetchTasks() async {
    isLoading = true;
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('docs')
          .orderBy('lastUpdated', descending: true)
          .get();

      docs = querySnapshot.docs;
      // dev.log('Docs fetched successfully for user');
    } catch (e) {
      dev.log('Error fetching tasks');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTask({
    required String docId,
    required String title,
    required String content,
  }) async {
    try {
      final updatedData = {
        'title': title,
        'content': content,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('docs')
          .doc(docId)
          .update(updatedData);

      dev.log('Task updated: $docId');
      fetchTasks(); // refresh the list after update
    } catch (e) {
      dev.log('Error updating task: $e');
    }
    notifyListeners();
  }

  Future<void> deleteTask({required String docId}) async {
    notifyListeners();
    try {
      await FirebaseFirestore.instance.collection('docs').doc(docId).delete();

      dev.log('Task deleted successfully');
      await fetchTasks();
    } catch (e) {
      dev.log('Error deleting task: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateCollaborators({
    required String docId,
    required String collaboratorEmail,
    required String role,
  }) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('docs').doc(docId);
      // Get current collaborators list (or empty)
      final snapshot = await docRef.get();
      final data = snapshot.data();
      final collaborators = List<Map<String, dynamic>>.from(
        data?['collaborators'] ?? [],
      );
      bool updated = false; // Update if exists
      for (var collaborator in collaborators) {
        if (collaborator.keys.first == collaboratorEmail) {
          collaborator[collaboratorEmail] = role;
          updated = true;
          break;
        }
      }

      // Add new if not found
      if (!updated) {
        collaborators.add({collaboratorEmail: role});
      }

      // Save back to Firestore

      await docRef.update({'collaborators': collaborators});

      dev.log('Collaborator $collaboratorEmail set as $role for doc $docId');
    } catch (e) {
      dev.log('Error adding/updating collaborator: $e');
    }
    notifyListeners();
  }

  Future<void> deleteCollaborators({
    required String docId,
    required String collaboratorEmail,
    required DocModel Docmodel,
  }) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('docs').doc(docId);

      // Get current collaborators list (or empty)
      final snapshot = await docRef.get();
      final data = snapshot.data();
      final collaborators = List<Map<String, dynamic>>.from(
        data?['collaborators'] ?? [],
      );

      collaborators.removeWhere(
        (element) => element.keys.first == collaboratorEmail,
      );

      collabEmails.remove(collaboratorEmail);

      await docRef.update({'collaborators': collaborators});

      Docmodel.collaborators = collaborators;

      dev.log('Collaborator $collaboratorEmail removed from doc $docId');
      await fetchTasks();
    } catch (e) {
      dev.log('Error adding/updating collaborator: $e');
    }
    notifyListeners();
  }
}
