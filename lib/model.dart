import 'dart:async';
import 'dart:math';

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

  double _money = 0;
  double get money => _money;
  set money(final double value) {
    _money = value;
    notifyListeners();
  }

  bool _canBuyOrSellStocks = false;
  bool get canBuyOrSellStocks => _canBuyOrSellStocks;
  set canBuyOrSellStocks(final bool value) {
    _canBuyOrSellStocks = value;
    notifyListeners();
  }

  int _stocks = 0;
  int get stocks => _stocks;
  set stocks(final int value) {
    _stocks = value;
    notifyListeners();
  }

  double _stockMultiplier = 1.0;
  double get stockMultiplier => _stockMultiplier;
  set stockMultiplier(final double value) {
    _stockMultiplier = value;
    notifyListeners();
  }

  static const double stockBasePrice = 5.0;
  double get stockPrice => stockBasePrice * stockMultiplier;

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
    await _getStocks();
    await _getMoney();
    await sync();
    notifyListeners();

    // sync clicks every 30 seconds
    Timer.periodic(const Duration(seconds: 30), (_) async {
      if (userId == null) {
        return;
      }

      if (_sendingRefreshRequests) {
        return;
      }

      money += Random().nextDouble() * 3;

      await sync();
      notifyListeners();
    });

    // stocks
    Timer.periodic(const Duration(seconds: 2), recalculateStocks);
  }

  void recalculateStocks(_) {
    final minValue = 0.5 - _stockMultiplier;
    final maxValue = 3 - _stockMultiplier;
    final rand = Random().nextDouble() * (maxValue - minValue) + minValue;

    final extra = Random().nextDouble() * 0.2 - 0.2;

    stockMultiplier += rand + extra;
    canBuyOrSellStocks = true;
  }

  VoidCallback? get buyStock =>
      canBuyOrSellStocks && money >= stockPrice ? _buyStock : null;
  void _buyStock() {
    if (money >= stockPrice) {
      money -= stockPrice;
      stocks += 1;

      canBuyOrSellStocks = false;
    }
  }

  VoidCallback? get sellStock =>
      canBuyOrSellStocks && stocks >= 1 ? _sellStock : null;
  void _sellStock() {
    if (stocks >= 1) {
      money += stockPrice;
      stocks -= 1;

      canBuyOrSellStocks = false;
    }
  }

  VoidCallback? get convertMoneyToPoints =>
      money >= 1 ? _convertMoneyToPoints : null;
  void _convertMoneyToPoints() {
    final pointsToAdd = money ~/ 1;
    money -= pointsToAdd;
    _localClicks += pointsToAdd.toInt();
    notifyListeners();
  }

  Future<void> sync() async {
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

    await SharedPreferences.getInstance().then((prefs) {
      prefs.setDouble('money', money);
      prefs.setInt('stocks', stocks);
    });

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

  Future<void> _getStocks() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      stocks = prefs.getInt('stocks') ?? 0;
    } catch (e) {
      prefs.clear();
    }

    notifyListeners();
  }

  Future<void> _getMoney() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      money = prefs.getDouble('money') ?? 0;
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
