import 'package:mobile_app_project/BrainyBee/timer/model/focus_session_model.dart';

/// Everything the rest of the app is allowed to ask of the timer's storage.
///
/// The Cubit only knows this interface, never where the data really lives.
/// Today the data lives on the device ([LocalTimerRepository]). When sign-in
/// exists, a Firestore version will implement the same methods and nothing else
/// in the Timer feature has to change.
abstract class TimerRepository {
  /// A stream that sends the full history right away, and again every time a
  /// session is added. (The hub will use it for "time studied" later.)
  Stream<List<FocusSession>> watchSessions();

  /// Adds a finished session to the history.
  Future<void> saveSession(FocusSession session);

  /// A new unique id for a session.
  String generateId();
}