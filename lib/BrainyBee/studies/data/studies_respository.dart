import 'package:mobile_app_project/BrainyBee/studies/model/homework_model.dart';
import 'package:mobile_app_project/BrainyBee/studies/model/timetable_model.dart';

/// Everything the rest of the app is allowed to ask of the Studies storage.
///
/// The Cubit only knows this interface, never where the data really lives.
/// Today the data lives on the device ([LocalStudiesRepository]). When sign-in
/// exists, a Firestore version will implement the same methods and nothing else
/// in the Studies feature has to change.
abstract class StudiesRepository {
  /// A stream that sends the timetable right away, and again every time it
  /// changes.
  Stream<Timetable> watchTimetable();

  /// Saves the whole timetable.
  Future<void> saveTimetable(Timetable timetable);

  /// A stream that sends the full list of homework right away, and again every
  /// time anything changes.
  Stream<List<Homework>> watchHomeworks();

  /// Creates the homework, or replaces it if one with the same id exists.
  Future<void> saveHomework(Homework homework);

  /// Deletes the homework.
  Future<void> deleteHomework(String homeworkId);

  /// A new unique id for a homework that does not exist yet.
  String generateId();
}