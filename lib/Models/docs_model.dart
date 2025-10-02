import 'package:cloud_firestore/cloud_firestore.dart' show FieldValue;

class DocModel {
  String? title;
  String? content;
  String? owenerID;
  String? email;
  List collaborators;

  DocModel({
    this.title,
    this.content,
    this.owenerID,
    this.email,
    this.collaborators = const [],
  });

  factory DocModel.fromMap(Map<String, dynamic> data) {
    return DocModel(
      title: data['title'],
      content: data['content'],
      owenerID: data['ownerid'],
      email: data['email'],
      collaborators: List<Map<String, dynamic>>.from(
        data['collaborators'] ?? [],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'ownerid': owenerID,
      'email': email,
      'lastUpdated': FieldValue.serverTimestamp(),
      'collaborators': collaborators,
    };
  }
}
