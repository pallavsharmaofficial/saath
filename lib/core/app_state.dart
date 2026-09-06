import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { en, hi }

enum RelationshipStage { dating, engaged, married, longDistance, roughPatch }

/// Everything the app needs to remember between launches, persisted with
/// SharedPreferences for now (Drift replaces this in the couple-layer phase).
@immutable
class AppState {
  const AppState({
    this.language = AppLanguage.en,
    this.themeMode = ThemeMode.system,
    this.onboarded = false,
    this.userName = '',
    this.partnerName = '',
    this.relationshipStage,
    this.originStory = '',
    this.todayConnection,
    this.todayWord = '',
  });

  final AppLanguage language;
  final ThemeMode themeMode;
  final bool onboarded;
  final String userName;
  final String partnerName;
  final RelationshipStage? relationshipStage;
  final String originStory;
  final int? todayConnection;
  final String todayWord;

  String get partnerOrDefault => partnerName.isEmpty ? 'your partner' : partnerName;

  AppState copyWith({
    AppLanguage? language,
    ThemeMode? themeMode,
    bool? onboarded,
    String? userName,
    String? partnerName,
    RelationshipStage? relationshipStage,
    String? originStory,
    int? todayConnection,
    String? todayWord,
  }) {
    return AppState(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      onboarded: onboarded ?? this.onboarded,
      userName: userName ?? this.userName,
      partnerName: partnerName ?? this.partnerName,
      relationshipStage: relationshipStage ?? this.relationshipStage,
      originStory: originStory ?? this.originStory,
      todayConnection: todayConnection ?? this.todayConnection,
      todayWord: todayWord ?? this.todayWord,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static AppState _load(SharedPreferences p) {
    return AppState(
      language: AppLanguage.values[p.getInt('language') ?? 0],
      themeMode: ThemeMode.values[p.getInt('themeMode') ?? 0],
      onboarded: p.getBool('onboarded') ?? false,
      userName: p.getString('userName') ?? '',
      partnerName: p.getString('partnerName') ?? '',
      relationshipStage: (p.getInt('relStage') == null) ? null : RelationshipStage.values[p.getInt('relStage')!],
      originStory: p.getString('originStory') ?? '',
      todayConnection: p.getString('checkinDate') == _today() ? p.getInt('todayConnection') : null,
      todayWord: p.getString('checkinDate') == _today() ? (p.getString('todayWord') ?? '') : '',
    );
  }

  static String _today() {
    final d = DateTime.now();
    return '${d.year}-${d.month}-${d.day}';
  }

  Future<void> setLanguage(AppLanguage l) async {
    state = state.copyWith(language: l);
    await _prefs.setInt('language', l.index);
  }

  Future<void> setThemeMode(ThemeMode m) async {
    state = state.copyWith(themeMode: m);
    await _prefs.setInt('themeMode', m.index);
  }

  Future<void> setNames({required String user, required String partner}) async {
    state = state.copyWith(userName: user, partnerName: partner);
    await _prefs.setString('userName', user);
    await _prefs.setString('partnerName', partner);
  }

  Future<void> setRelationshipStage(RelationshipStage s) async {
    state = state.copyWith(relationshipStage: s);
    await _prefs.setInt('relStage', s.index);
  }

  Future<void> setOriginStory(String text) async {
    state = state.copyWith(originStory: text);
    await _prefs.setString('originStory', text);
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(onboarded: true);
    await _prefs.setBool('onboarded', true);
  }

  Future<void> checkIn({required int connection, String word = ''}) async {
    state = state.copyWith(todayConnection: connection, todayWord: word);
    await _prefs.setInt('todayConnection', connection);
    await _prefs.setString('todayWord', word);
    await _prefs.setString('checkinDate', _today());
  }

  /// Dev helper: wipe everything (Settings → Reset).
  Future<void> reset() async {
    await _prefs.clear();
    state = const AppState();
  }
}

final sharedPrefsProvider = Provider<SharedPreferences>((_) => throw UnimplementedError());

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (ref) => AppStateNotifier(ref.watch(sharedPrefsProvider)),
);
