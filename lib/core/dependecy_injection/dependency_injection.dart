
import 'repositories.dart';

class DependencyInjection {
  DependencyInjection._();

  static void init() {
    // Accessing this getter initializes the shared dependencies.
    Repositories.dioClient;
  }
}
