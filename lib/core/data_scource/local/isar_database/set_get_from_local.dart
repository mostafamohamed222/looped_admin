

import '../../../di/injection.dart';
import '../objectbox_database/objectbox_helper.dart';

class LocalDBController {

  static Future<String> get userSessionId async =>
      await getIt<ObjectBoxHelper>().get('userSessionId') ?? "";

  static Future<void> setuserSessionId(String v) async {
    return await getIt<ObjectBoxHelper>().put('userSessionId', v);
  }

  static Future<String> get userDomain async =>
      await getIt<ObjectBoxHelper>().get('UserDomain') ?? "";

  static Future<void> setUserDomain(String v) async {
    return await getIt<ObjectBoxHelper>().put('UserDomain', v);
  }
}
