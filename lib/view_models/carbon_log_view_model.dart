import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/carbon_activity.dart';

class CarbonLogViewModel with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<CarbonActivity> _activities = [];
  bool _isLoading = false;
  String? _error;

  final List<String> _ecoTips = [
    "Reduce, Reuse, Recycle: Follow the 3 R's diligently.",
    "Unplug electronics when not in use to save phantom energy.",
    "Choose public transport, cycling, or walking over driving.",
    "Eat more plant-based meals; less meat reduces your carbon footprint.",
    "Switch to energy-efficient LED light bulbs.",
    "Take shorter showers to conserve water and energy.",
    "Buy local and seasonal produce to reduce transportation emissions.",
    "Compost your food waste to prevent methane emissions in landfills.",
    "Support businesses with strong environmental policies.",
    "Educate yourself and others about climate change.",
  ];
  String _currentTip = '';

  List<CarbonActivity> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentTip => _currentTip;

  CarbonLogViewModel() {
    getDailyTip(); 
  }

  void getDailyTip() {
    _currentTip = _ecoTips[DateTime.now().day % _ecoTips.length];
    notifyListeners();
  }

  Future<void> fetchActivities() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _error = 'User not logged in. Cannot fetch activities.';
        _activities = [];
        return;
      }

      final response = await _supabase
          .from('carbon_activities')
          .select('*')
          .eq('user_id', userId) 
          .order('timestamp', ascending: false); 

      _activities = response
          .map<CarbonActivity>((json) => CarbonActivity.fromJson(json))
          .toList();
    } catch (e) {
      _error = 'Failed to fetch carbon activities: $e';
      _activities = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addActivity(CarbonActivity activity) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _error = 'User not logged in. Cannot add activity.';
        return;
      }

      final activityWithUser = CarbonActivity(
        userId: userId,
        transportMode: activity.transportMode,
        transportDistance: activity.transportDistance,
        electricityUsage: activity.electricityUsage,
        wasteWeight: activity.wasteWeight,
        timestamp: activity.timestamp,
        type: activity.type,
      );

      final response = await _supabase
          .from('carbon_activities')
          .insert(activityWithUser.toJson())
          .select(); 

      if (response.isNotEmpty) {
        _activities.insert(0, CarbonActivity.fromJson(response.first));
      } else {
        _error = 'Failed to add activity to Supabase.';
      }
    } catch (e) {
      _error = 'Failed to add carbon activity: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateActivity(CarbonActivity activity) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || activity.id == null) {
        _error = 'User not logged in or activity ID is missing. Cannot update.';
        return;
      }

      await _supabase
          .from('carbon_activities')
          .update(activity.toJson())
          .eq('id', activity.id as Object)
          .eq('user_id', userId);

      final index = _activities.indexWhere((a) => a.id == activity.id);
      if (index != -1) {
        _activities[index] = activity;
      }
    } catch (e) {
      _error = 'Failed to update carbon activity: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteActivity(String activityId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _error = 'User not logged in. Cannot delete activity.';
        return;
      }

      await _supabase
          .from('carbon_activities')
          .delete()
          .eq('id', activityId)
          .eq('user_id', userId);

      _activities.removeWhere((activity) => activity.id == activityId);
    } catch (e) {
      _error = 'Failed to delete carbon activity: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearActivities() {
    _activities.clear();
    notifyListeners();
  }

  double getTotalCarbonFootprint() {
    return _activities.fold(0.0, (sum, activity) => sum + activity.calculateCarbonFootprint());
  }
}