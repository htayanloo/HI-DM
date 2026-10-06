/// Decisions made when seeding app defaults at startup.
class SeedUtils {
  /// Whether the default save path should be (re)written at startup.
  ///
  /// Returns false as soon as the user has explicitly customized the path —
  /// a user-chosen path must never be overwritten (that was the bug where the
  /// save path silently reset to the default on every relaunch).
  ///
  /// Otherwise the path is (re)seeded when it is empty or still points inside
  /// the sandbox container (a path the app generated itself, not the user).
  static bool shouldSeedSavePath({
    required bool customized,
    required String currentPath,
    required String containerHome,
  }) {
    if (customized) return false;
    if (currentPath.isEmpty) return true;
    if (containerHome.isNotEmpty &&
        containerHome != '/' &&
        currentPath.startsWith(containerHome)) {
      return true;
    }
    return false;
  }
}
