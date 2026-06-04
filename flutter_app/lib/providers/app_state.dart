import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile.dart';

class AppState extends ChangeNotifier {
  List<Profile> profiles = [];
  Profile? currentProfile;

  AppState() {
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profilesJson = prefs.getString('profiles');
    final String? lastProfileId = prefs.getString('lastProfileId');

    if (profilesJson != null) {
      final List<dynamic> decoded = jsonDecode(profilesJson);
      profiles = decoded.map((p) => Profile.fromJson(p)).toList();
      
      if (profiles.isNotEmpty) {
        if (lastProfileId != null) {
          currentProfile = profiles.firstWhere((p) => p.id == lastProfileId, orElse: () => profiles.first);
        } else {
          currentProfile = profiles.first;
        }
      }
    } else {
      final defaultProfile = Profile(
        id: 'default_pc',
        name: 'Meu PC Principal',
        localIp: '',
        vpnIp: '',
        macAddress: '00:00:00:00:00:00',
        hasGamingMacros: true,
        hasSMBFiles: true,
      );

      profiles.add(defaultProfile);
      currentProfile = defaultProfile;
      _saveProfiles();
    }
    notifyListeners();
  }

  Future<void> _saveProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(profiles.map((p) => p.toJson()).toList());
    await prefs.setString('profiles', encoded);
    if (currentProfile != null) {
      await prefs.setString('lastProfileId', currentProfile!.id);
    }
  }

  void switchProfile(Profile profile) {
    currentProfile = profile;
    _saveProfiles();
    notifyListeners();
  }

  void addOrUpdateProfile(Profile profile) {
    final index = profiles.indexWhere((p) => p.id == profile.id);
    if (index >= 0) {
      profiles[index] = profile;
    } else {
      profiles.add(profile);
    }
    if (currentProfile?.id == profile.id || currentProfile == null) {
      currentProfile = profile;
    }
    _saveProfiles();
    notifyListeners();
  }

  void removeProfile(String id) {
    profiles.removeWhere((p) => p.id == id);
    if (currentProfile?.id == id) {
      currentProfile = profiles.isNotEmpty ? profiles.first : null;
    }
    _saveProfiles();
    notifyListeners();
  }
}
