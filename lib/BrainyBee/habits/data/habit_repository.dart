import 'package:mobile_app_project/BrainyBee/habits/model/habit_model.dart';

/// Everything the rest of the app is allowed to ask of habit storage.
///
/// The Cubit only knows this interface, never where the data really lives.
/// Today the data lives on the device ([LocalHabitRepository]). When sign-in
/// exists, a Firestore version will implement the same four methods and
/// nothing else in the habits feature has to change.
abstract class HabitRepository {
  /// A stream that sends the full list of habits right away, and again every
  /// time anything changes.
  Stream<List<Habit>> watchHabits();

  /// Creates the habit, or replaces it if a habit with the same id exists.
  Future<void> saveHabit(Habit habit);

  /// Deletes the habit and all of its progress.
  Future<void> deleteHabit(String habitId);

  /// A new unique id for a habit that does not exist yet.
  String generateId();
}