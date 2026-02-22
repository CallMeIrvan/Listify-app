import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mendapatkan user ID saat ini
  String? get currentUserId => _auth.currentUser?.uid;

  // Referensi collection tasks untuk user tertentu
  CollectionReference _tasksCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('tasks');

  // Referensi collection users
  CollectionReference get _usersCollection => _firestore.collection('users');

  // Mendapatkan stream tasks
  Stream<QuerySnapshot> getTasks(String userId) {
    print('Getting tasks for user: $userId'); // Debug log
    return _tasksCollection(
      userId,
    ).orderBy('createdAt', descending: true).snapshots();
  }

  // Menambah task baru
  Future<void> addTask(
    String userId,
    String title, {
    String? description,
    DateTime? dueDate,
    String? project,
  }) async {
    try {
      print('Adding task - UserID: $userId, Title: $title'); // Debug log
      final docRef = await _tasksCollection(userId).add({
        'title': title,
        'description': description,
        'dueDate': dueDate?.toIso8601String(),
        'isDone': false,
        'userId': userId,
        'project': project ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Task added successfully with ID: ${docRef.id}'); // Debug log
    } catch (e) {
      print('Error adding task: $e'); // Debug log
      rethrow;
    }
  }

  // Mengupdate task
  Future<void> updateTask(
    String userId,
    String taskId,
    Map<String, dynamic> data,
  ) async {
    await _tasksCollection(
      userId,
    ).doc(taskId).update({...data, 'updatedAt': FieldValue.serverTimestamp()});
  }

  // Menghapus task
  Future<void> deleteTask(String userId, String taskId) async {
    await _tasksCollection(userId).doc(taskId).delete();
  }

  // Menghapus multiple tasks
  Future<void> deleteMultipleTasks(String userId, List<String> taskIds) async {
    final batch = _firestore.batch();
    for (var taskId in taskIds) {
      batch.delete(_tasksCollection(userId).doc(taskId));
    }
    await batch.commit();
  }

  // Register dengan email, password, dan nama
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      print('Attempting to register user: $email'); // Debug log
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print(
        'User registered successfully with ID: ${userCredential.user?.uid}',
      ); // Debug log

      // Simpan data user tambahan ke Firestore
      await _usersCollection.doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('User data saved to Firestore'); // Debug log
      return userCredential;
    } catch (e) {
      print('Error during registration: $e'); // Debug log
      rethrow;
    }
  }

  // Login dengan email dan password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Stream untuk status autentikasi
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Mendapatkan data user
  Future<DocumentSnapshot> getUserData(String userId) async {
    return await _usersCollection.doc(userId).get();
  }

  // Update nama user di Firestore
  Future<void> updateUserName(String? userId, String newName) async {
    if (userId == null) return;
    await _usersCollection.doc(userId).update({'name': newName});
  }
}
