import 'dart:async';
import 'dart:convert';

import 'package:mobile_app_project/BrainyBee/studies/data/studies_respository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_app_project/BrainyBee/studies/model/homework_model.dart';
import 'package:mobile_app_project/BrainyBee/studies/model/timetable_model.dart';

/// Keeps the timetable and the homework on the device (using
/// shared_preferences), each as one block of JSON text. It is the temporary
/// storage until Firestore and sign-in exist.
///
/// Like the habits storage, everything is also kept in memory. Every change
/// updates the memory and tells listeners FIRST, then writes to the device, so
/// the screen reacts instantly and two quick changes in a row cannot overwrite
/// each other.
class LocalStudiesRepository implements StudiesRepository {
  LocalStudiesRepository._(this._prefs, this._timetable, this._homeworks);

  /// Creates the repository and reads anything saved earlier.
  /// Call it once at startup: `await LocalStudiesRepository.create()`.
  static Future<LocalStudiesRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStudiesRepository._(
      prefs,
      _readTimetable(prefs),
      _readHomeworks(prefs),
    );
  }

  static const String _timetableKey = 'timetable_v1';
  static const String _homeworksKey = 'homeworks_v1';

  final SharedPreferences _prefs;
  final StreamController<Timetable> _timetableChanges =
      StreamController<Timetable>.broadcast();
  final StreamController<List<Homework>> _homeworkChanges =
      StreamController<List<Homework>>.broadcast();

  Timetable _timetable;
  List<Homework> _homeworks;

  /// Reads the saved timetable. Unreadable data simply gives an empty one.
  static Timetable _readTimetable(SharedPreferences prefs) {
    final raw = prefs.getString(_timetableKey);
    if (raw == null) return const Timetable();

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return Timetable.fromMap(decoded);
    } catch (_) {
      return const Timetable();
    }
  }

  /// Reads the saved homework. A damaged item is skipped instead of crashing
  /// the whole app, and unreadable data simply gives an empty list.
  static List<Homework> _readHomeworks(SharedPreferences prefs) {
    final raw = prefs.getString(_homeworksKey);
    if (raw == null) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final homeworks = <Homework>[];
      for (final item in decoded) {
        try {
          homeworks.add(
            Homework.fromMap(Map<String, dynamic>.from(item as Map)),
          );
        } catch (_) {
          // Skip this one damaged item and keep the others.
        }
      }
      return homeworks;
    } catch (_) {
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Timetable
  // ---------------------------------------------------------------------------

  @override
  Stream<Timetable> watchTimetable() async* {
    // First the current timetable, then every later change.
    yield _timetable;
    yield* _timetableChanges.stream;
  }

  @override
  Future<void> saveTimetable(Timetable timetable) async {
    _timetable = timetable;
    _timetableChanges.add(timetable);
    await _prefs.setString(_timetableKey, jsonEncode(timetable.toMap()));
  }

  // ---------------------------------------------------------------------------
  // Homework
  // ---------------------------------------------------------------------------

  @override
  Stream<List<Homework>> watchHomeworks() async* {
    yield List<Homework>.unmodifiable(_homeworks);
    yield* _homeworkChanges.stream;
  }

  @override
  Future<void> saveHomework(Homework homework) async {
    final updated = List<Homework>.of(_homeworks);
    final index = updated.indexWhere((existing) => existing.id == homework.id);
    if (index == -1) {
      updated.add(homework);
    } else {
      updated[index] = homework;
    }
    await _commitHomeworks(updated);
  }

  @override
  Future<void> deleteHomework(String homeworkId) async {
    await _commitHomeworks(
      _homeworks.where((homework) => homework.id != homeworkId).toList(),
    );
  }

  @override
  String generateId() => DateTime.now().microsecondsSinceEpoch.toString();

  /// Updates memory and listeners immediately, then writes to the device.
  Future<void> _commitHomeworks(List<Homework> updated) async {
    _homeworks = updated;
    _homeworkChanges.add(List<Homework>.unmodifiable(_homeworks));

    final json = jsonEncode([for (final homework in updated) homework.toMap()]);
    await _prefs.setString(_homeworksKey, json);
  }
}