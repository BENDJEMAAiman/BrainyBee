import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_app_project/BrainyBee/habits/data/habit_repository.dart';
import 'package:mobile_app_project/BrainyBee/habits/model/habit_model.dart';

/// Keeps habits on the device (using shared_preferences) as one block of JSON
/// text. It is the temporary storage until Firestore and sign-in exist.
///
/// The habits are also kept in memory ([_habits]). Every change updates the
/// memory and tells listeners FIRST, then writes to the device, so the screen
/// reacts instantly and two quick changes in a row cannot overwrite each
/// other.
class LocalHabitRepository implements HabitRepository {
  LocalHabitRepository._(this._prefs, this._habits);

  /// Creates the repository and reads any habits saved earlier.
  /// Call it once at startup: `await LocalHabitRepository.create()`.
  static Future<LocalHabitRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalHabitRepository._(prefs, _readFrom(prefs));
  }

  static const String _storageKey = 'habits_v1';

  final SharedPreferences _prefs;
  final StreamController<List<Habit>> _changes =
      StreamController<List<Habit>>.broadcast();
  List<Habit> _habits;

  /// Reads the saved JSON. A damaged habit is skipped instead of crashing the
  /// whole app, and unreadable data simply gives an empty list.
  static List<Habit> _readFrom(SharedPreferences prefs) {
    final raw = prefs.getString(_storageKey);
    if (raw == null) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final habits = <Habit>[];
      for (final item in decoded) {
        try {
          habits.add(Habit.fromMap(Map<String, dynamic>.from(item as Map)));
        } catch (_) {
          // Skip this one damaged habit and keep the others.
        }
      }
      return habits;
    } catch (_) {
      return [];
    }
  }

  @override
  Stream<List<Habit>> watchHabits() async* {
    // First the current list, then every later change.
    yield List<Habit>.unmodifiable(_habits);
    yield* _changes.stream;
  }

  @override
  Future<void> saveHabit(Habit habit) async {
    final updated = List<Habit>.of(_habits);
    final index = updated.indexWhere((existing) => existing.id == habit.id);
    if (index == -1) {
      updated.add(habit);
    } else {
      updated[index] = habit;
    }
    await _commit(updated);
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    await _commit(
      _habits.where((habit) => habit.id != habitId).toList(),
    );
  }

  @override
  String generateId() => DateTime.now().microsecondsSinceEpoch.toString();

  /// Updates memory and listeners immediately, then writes to the device.
  Future<void> _commit(List<Habit> updated) async {
    _habits = updated;
    _changes.add(List<Habit>.unmodifiable(_habits));

    final json = jsonEncode([for (final habit in updated) habit.toMap()]);
    await _prefs.setString(_storageKey, json);
  }
}