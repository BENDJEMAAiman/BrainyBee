import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_app_project/BrainyBee/timer/data/timer_repository.dart';
import 'package:mobile_app_project/BrainyBee/timer/model/focus_session_model.dart';

/// Keeps the session history on the device (using shared_preferences) as one
/// block of JSON text. It is the temporary storage until Firestore and sign-in
/// exist.
///
/// Like the other local storages, the history is also kept in memory. A change
/// updates the memory and tells listeners FIRST, then writes to the device.
class LocalTimerRepository implements TimerRepository {
  LocalTimerRepository._(this._prefs, this._sessions);

  /// Creates the repository and reads any history saved earlier.
  /// Call it once at startup: `await LocalTimerRepository.create()`.
  static Future<LocalTimerRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalTimerRepository._(prefs, _readFrom(prefs));
  }

  static const String _storageKey = 'focus_sessions_v1';

  final SharedPreferences _prefs;
  final StreamController<List<FocusSession>> _changes =
      StreamController<List<FocusSession>>.broadcast();
  List<FocusSession> _sessions;

  /// Reads the saved JSON. A damaged session is skipped instead of crashing
  /// the whole app, and unreadable data simply gives an empty list.
  static List<FocusSession> _readFrom(SharedPreferences prefs) {
    final raw = prefs.getString(_storageKey);
    if (raw == null) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final sessions = <FocusSession>[];
      for (final item in decoded) {
        try {
          sessions.add(
            FocusSession.fromMap(Map<String, dynamic>.from(item as Map)),
          );
        } catch (_) {
          // Skip this one damaged session and keep the others.
        }
      }
      return sessions;
    } catch (_) {
      return [];
    }
  }

  @override
  Stream<List<FocusSession>> watchSessions() async* {
    // First the current history, then every later change.
    yield List<FocusSession>.unmodifiable(_sessions);
    yield* _changes.stream;
  }

  @override
  Future<void> saveSession(FocusSession session) async {
    // Updates memory and listeners immediately, then writes to the device.
    _sessions = [..._sessions, session];
    _changes.add(List<FocusSession>.unmodifiable(_sessions));

    final json = jsonEncode([for (final item in _sessions) item.toMap()]);
    await _prefs.setString(_storageKey, json);
  }

  @override
  String generateId() => DateTime.now().microsecondsSinceEpoch.toString();
}