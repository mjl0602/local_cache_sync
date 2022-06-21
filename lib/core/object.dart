import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:local_cache_sync/local_cache_sync.dart';

/// 保存用户数据，使用特殊路径
class UserDefaultCacheObject extends LocalCacheObject {
  UserDefaultCacheObject(String id,
      [String channel = r'_$DefaultChannel', Map<String, dynamic>? value])
      : super(id, channel: channel, value: value);
  @override
  Uri get path => UserDefaultSync.cachePath.resolve('$channel/');
}

class LocalCacheObject {
  final String id;
  final CacheType type;

  String get realId => id.replaceAll(RegExp('[\\\\/:.]'), '_');

  String channel;
  LocalCacheObject(
    this.id, {
    this.type = CacheType.json,
    this.channel = r'_$DefaultChannel',
    Map<String, dynamic>? value,
  }) : this._value = value;

  Uri get path => LocalCacheSync().cachePath!.resolve('$channel/');

  File get file => File.fromUri(path.resolve('$realId.$_extName'));

  String get _extName {
    switch (type) {
      case CacheType.json:
        return 'json';
      case CacheType.plain:
        return 'txt';
      case CacheType.raw:
        return 'byte';
    }
  }

  bool get isCache => _value != null;

  Map<String, dynamic>? _value;

  Map<String, dynamic>? get value {
    if (_value == null) {
      LocalCacheSync().willLoadValue?.call(this);
      _value = readJson();
      LocalCacheSync().didLoadValue?.call(_value, this);
    }
    return _value;
  }

  Uint8List? get byteValue {
    if (!file.existsSync()) {
      return null;
    }
    return file.readAsBytesSync();
  }

  String? get plainTextValue {
    if (!file.existsSync()) {
      return null;
    }
    return file.readAsStringSync();
  }

  Map<String, dynamic>? get jsonValue => readJson();

  clear() {
    _value = null;
  }

  Map<String, dynamic>? readJson() {
    if (!file.existsSync()) {
      return null;
    }
    var content = file.readAsStringSync();
    try {
      return json.decode(content);
    } catch (e) {
      print('Error Decode:$content($e)');
      return null;
    }
  }

  File saveAsJson() {
    return file
      ..createSync(recursive: true)
      ..writeAsStringSync(
        JsonEncoder.withIndent('   ').convert(_value ?? {}),
      );
  }

  void delete() {
    _value = null;
    file.deleteSync();
  }

  Future<Map<String, dynamic>?> readAsync() async {
    if (!file.existsSync()) {
      return null;
    }
    var content = await file.readAsString();
    try {
      return json.decode(content);
    } catch (e) {
      print('Error Decode:$content($e)');
      return null;
    }
  }

  Future<File> saveAsync() async {
    await file.create(recursive: true);
    await file.writeAsString(
      JsonEncoder.withIndent('   ').convert(_value ?? {}),
    );
    return file;
  }

  Future<void> deleteAsync() async {
    _value = null;
    await file.delete();
  }
}
