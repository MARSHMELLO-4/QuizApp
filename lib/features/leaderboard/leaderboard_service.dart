import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<List<Map<String, dynamic>>> giveLeaderboardService() async {
  try {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('score')
        .orderBy('score', descending: true)
        .get();

    List<Map<String, dynamic>> leaderboard = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      leaderboard.add({
        'name': data['name'],
        'score': data['score'],
        'uid': data['uid'],
      });
    }

    return leaderboard;
  } catch (e) {
    print('Error fetching leaderboard: $e');
    return [];
  }
}

Future<void> updateLeaderboard(int score) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    print("No user logged in.");
    return;
  }

  final uid = currentUser.uid;
  final name = currentUser.displayName ?? "Anonymous";

  final docRef = FirebaseFirestore.instance.collection('score').doc(uid);

  try {
    final doc = await docRef.get();

    if (doc.exists) {
      final currentScore = doc.data()?['score'] ?? 0;
      final newScore = currentScore + score;

      await docRef.update({
        'score': newScore,
        'name': name,
        'uid': uid,
      });

      print("Score updated. New score: $newScore");
    } else {
      // Create new document with the score
      await docRef.set({
        'score': score,
        'name': name,
        'uid': uid,
      });

      print("New leaderboard entry created.");
    }
  } catch (e) {
    print("Error updating leaderboard: $e");
  }
}
