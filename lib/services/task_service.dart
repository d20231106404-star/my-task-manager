import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

class TaskService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== CRUD OPERATIONS =====

  // CREATE: Add new task
  static Future<void> addTask(String title, String description) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    await _firestore.collection('tasks').add({
      'title': title,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
      'userId': userId,
    });
  }

  // READ: Get all tasks for current user (Stream)
  static Stream<QuerySnapshot> getTasks() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Stream.empty();
    }
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  // READ: Get all tasks as Future (one-time)
  static Future<List<Task>> getTasksOnce() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return [];

    QuerySnapshot snapshot = await _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .get();

    List<Task> tasks = snapshot.docs.map((doc) {
      return Task.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();

    // Sort by createdAt descending on client side
    tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return tasks;
  }

  // UPDATE: Edit existing task
  static Future<void> updateTask(
      String taskId, String title, String description) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    await _firestore.collection('tasks').doc(taskId).update({
      'title': title,
      'description': description,
    });
  }

  // DELETE: Delete task
  static Future<void> deleteTask(String taskId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    await _firestore.collection('tasks').doc(taskId).delete();
  }

  // DELETE ALL: Delete all tasks for current user
  static Future<void> deleteAllTasks() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    QuerySnapshot snapshot = await _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
