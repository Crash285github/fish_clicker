import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fish_clicker/firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FishClickerModel extends ChangeNotifier {
  static final FishClickerModel _instance = FishClickerModel._internal();
  factory FishClickerModel() => _instance;
  FishClickerModel._internal();

  String? _userId;
  String? get userId => _userId;
  set userId(final String? value) {
    refreshClicks().whenComplete(() {
      _userId = value;
      _localClicks = 0;
      notifyListeners();
    });

    SharedPreferences.getInstance().then((prefs) {
      if (value == null || value.isEmpty) {
        prefs.remove('user_id');
      } else {
        prefs.setString('user_id', value);
      }
    });
  }

  int _localClicks = 0;
  int get localClicks => _localClicks;
  void addClick() {
    _localClicks += 1;
    notifyListeners();
  }

  int _globalClicks = 0;
  int get globalClicks => _globalClicks + _localClicks;

  Timer? _refreshTimer;

  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await _getUserId();
    await refreshClicks();
    notifyListeners();

    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (userId == null) {
        return;
      }

      await refreshClicks();
      notifyListeners();
    });
  }

  void shutdown() {
    _refreshTimer?.cancel();
  }

  Future<void> refreshClicks() async {
    final collectionRef = firestore.collection('clicks');

    // Update user clicks
    if (userId != null && userId!.isNotEmpty) {
      final docRef = collectionRef.doc(userId.toString());
      final docSnapshot = await docRef.get();
      final data = docSnapshot.data();
      final serverClicks = (data?['clicks'] as int?) ?? 0;

      if (serverClicks < _localClicks) {
        await docRef.set({'clicks': _localClicks});
      } else if (serverClicks > _localClicks) {
        _localClicks = serverClicks;
        notifyListeners();
      }
    }

    // Get global clicks
    final snapshot = await collectionRef.get();
    int totalClicks = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (doc.id == userId.toString()) continue;
      totalClicks += (data['clicks'] as int?) ?? 0;
    }

    _globalClicks = totalClicks;
    notifyListeners();
  }

  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      userId = prefs.getString('user_id');
    } catch (e) {
      prefs.clear();
    }

    if (userId == null) {
      return;
    }

    notifyListeners();
  }
}
