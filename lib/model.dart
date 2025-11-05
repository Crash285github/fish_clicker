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

  final syncNotifier = ValueNotifier(0);
  bool _sendingRefreshRequests = false;

  String? _userId;
  String? get userId => _userId;
  set userId(final String? value) {
    _userId = value;
    _localClicks = 0;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) {
      if (value == null || value.isEmpty) {
        prefs.remove('user_id');
      } else {
        prefs.setString('user_id', value);
      }
    });
  }

  bool _muteAudio = false;
  bool get muteAudio => _muteAudio;
  set muteAudio(final bool value) {
    _muteAudio = value;
    notifyListeners();

    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('mute_audio', value);
    });
  }

  int _localClicks = 0;
  int get localClicks => _localClicks;
  void addClick() {
    _localClicks += 1;
    notifyListeners();
  }

  int get globalClicks {
    int total = _localClicks;
    for (final user in _leaderboard) {
      if (user.id == userId) {
        continue;
      }

      total += user.clicks;
    }
    return total;
  }

  Timer? _refreshTimer;

  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  final List<User> _leaderboard = [];
  List<User> get leaderboard => List.unmodifiable(
    _leaderboard..sort((a, b) => b.clicks.compareTo(a.clicks)),
  );

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await _getUserId();
    await _getMuteAudio();
    await refreshClicks();
    notifyListeners();

    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (userId == null) {
        return;
      }

      if (_sendingRefreshRequests) {
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
    _sendingRefreshRequests = true;
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

    // Get leaderboard
    final snapshot = await collectionRef.get();
    _leaderboard.clear();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      _leaderboard.add(User(id: doc.id, clicks: (data['clicks'] as int?) ?? 0));
    }

    syncNotifier.value++;
    _sendingRefreshRequests = false;
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

  Future<void> _getMuteAudio() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      muteAudio = prefs.getBool('mute_audio') ?? false;
    } catch (e) {
      prefs.clear();
    }

    notifyListeners();
  }
}

class User {
  final String id;
  final int clicks;

  User({required this.id, required this.clicks});
}
