import 'package:database_repository_functions/src/configs/database_configs.dart';
import 'package:hive/hive.dart';

class DatabaseRepositoryFunctions {
  const DatabaseRepositoryFunctions();
  void initHiveDb({required String path}) {
    try {
      Hive.init(path);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveUsersToDb({required String userJson}) async {
    final box = await Hive.openBox(
      DatabaseConfigs.usersKey,
    );
    box.put(
      DatabaseConfigs.usersKey,
      userJson,
    );
  }

  Future<String?> get getUserFromDb async {
    final box = await Hive.openBox(
      DatabaseConfigs.usersKey,
    );
    final String? json = box.get(
      DatabaseConfigs.usersKey,
    );
    return json;
  }
}
