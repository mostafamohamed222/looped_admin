import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../error/exceptions.dart';
import 'objectbox.g.dart';
import 'save_data_model.dart';



class ObjectBoxHelper {
  late final Store store;
  late final Box<SaveDataModel> saveDataBox;
  static ObjectBoxHelper? _instance;

  ObjectBoxHelper._create(this.store) {
    saveDataBox = store.box<SaveDataModel>();
  }

  static Future<ObjectBoxHelper> create() async {
    if (_instance != null) return _instance!;
    late final docsDir;
    if (Platform.isIOS) {
       docsDir = await getApplicationDocumentsDirectory();
    } else {
      docsDir = await getExternalStorageDirectory();
    }
    final store = await openStore(
      directory: path.join(docsDir.path, "objectbox"),
    );
    _instance = ObjectBoxHelper._create(store);
    return _instance!;
  }

  Future<void> put(String dbKey, dynamic v) async {
    try {
      // First try to find existing record
      final query = saveDataBox.query(SaveDataModel_.key.equals(dbKey)).build();
      final existingRecord = query.findFirst();
      query.close();

      if (existingRecord != null) {
        // Update existing record
        existingRecord.value = jsonEncode(v);
        saveDataBox.put(existingRecord);
      } else {
        // Create new record
        final model = SaveDataModel(
          key: dbKey,
          value: jsonEncode(v),
        );
        saveDataBox.put(model);
      }
    } catch (e) {
      debugPrint("ObjectBox Error Exception");
      debugPrint(e.toString());
    }
  }

  Future<dynamic> get(String key) async {
    return await _basicErrorHandling(() async {
      try {
        final query = saveDataBox.query(SaveDataModel_.key.equals(key)).build();
        final result = query.findFirst();
        query.close();
        if (result != null) {
          return jsonDecode(result.value!);
        }
        return null;
      } catch (e) {
        return null;
      }
    });
  }

  Future<void> clear(String key) async {
    await _basicErrorHandling(() async {
      try {
        final query = saveDataBox.query(SaveDataModel_.key.equals(key)).build();
        final result = query.findFirst();
        query.close();
        if (result != null) {
          saveDataBox.remove(result.id);
        }
      } catch (e) {
        debugPrint(e.toString());
        return null;
      }
    });
  }

  Future<void> resetData() async {
    await _basicErrorHandling(() async {
      try {
        saveDataBox.removeAll();
      } catch (e) {
        debugPrint(e.toString());
        return null;
      }
    });
  }

  Future<T> _basicErrorHandling<T>(Future<T> Function() onSuccess) async {
    try {
      final f = await onSuccess.call();
      return f;
    } catch (e) {
      throw CacheException(e);
    }
  }
}
