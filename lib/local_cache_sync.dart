library local_cache_sync;

export 'pages/cacheViewTablePage.dart';
export 'pages/cacheChannelListPage.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:local_cache_sync/pages/cacheChannelListPage.dart';

/// LocalCacheSync单例，用于储存缓存路径，并暴露常用接口
class LocalCacheSync {
  // 工厂模式
  factory LocalCacheSync() => _getInstance()!;
  static LocalCacheSync? get instance => _getInstance();
  static LocalCacheSync? _instance;
  LocalCacheSync._internal() {
    // 初始化
  }
  static LocalCacheSync? _getInstance() {
    if (_instance == null) {
      _instance = new LocalCacheSync._internal();
    }
    return _instance;
  }

  static Future<void> pushDetailPage(BuildContext context) =>
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => CacheChannelListPage(),
        ),
      );

  /// 全局拦截器，即将加载某个数据时触发，可以用来构建全局缓存
  void Function(LocalCacheObject)? willLoadValue;

  /// 全局拦截器，已经加载完某个数据时
  void Function(Map<String, dynamic>?, LocalCacheObject)? didLoadValue;

  Uri? _cachePath;
  void setCachePath(Directory rootPath, [String cacheName = 'sync_cache']) =>
      _cachePath = rootPath.uri.resolve(cacheName);

  Uri? get cachePath {
    assert(
      _cachePath != null,
      '\nERROR: Cache path must not be null.' '\nERROR:缓存路径不可设置为空。',
    );
    return _cachePath;
  }

  /// 用户缓存可以单独指定一个路径
  /// 例如，可以把其他数据放在会清理的文件夹，将用户缓存放在不会被清理的文件夹(token等数据)
  Uri? _userDefaultCachePath;

  static LocalCacheLoader loaderOfChannel(String channel) =>
      LocalCacheLoader(channel);
  // 用户偏好设置
  static UserDefaultSync get userDefault => UserDefaultSync();
}

/// 封装了一个简单的读写方法，在不存在值时返回默认值
class DefaultValueCache<T> {
  final String key;
  final T defaultValue;

  const DefaultValueCache(this.key, this.defaultValue);

  T get value => LocalCacheSync.userDefault[key] ?? defaultValue;

  set value(T? value) {
    LocalCacheSync.userDefault[key] = value;
  }
}

/// 用于储存用户缓存数据，继承自LocalCacheLoader，实现了自己的读写方法，并增加了类型判断
/// 用户缓存数据可以单独指定一个路径(使用setCachePath)
/// 例如，可以把其他数据放在会清理的文件夹，将用户缓存放在不会被清理的文件夹(token等数据)
class UserDefaultSync extends LocalCacheLoader {
  UserDefaultSync() : super(r'_$LocalCacheDefault');

  Uri get directoryPath =>
      (LocalCacheSync()._userDefaultCachePath ?? LocalCacheSync().cachePath)!
          .resolve('$channel/');

  /// 用户缓存可以单独指定一个路径
  /// 例如，可以把其他数据放在会清理的文件夹，将用户缓存放在不会被清理的文件夹(token等数据)
  static void setCachePath(
    Directory rootPath, [
    String cacheName = 'sync_cache',
  ]) =>
      LocalCacheSync()._userDefaultCachePath = rootPath.uri.resolve(cacheName);

  static Uri? get cachePath {
    assert(
      LocalCacheSync()._userDefaultCachePath != null,
      '\nERROR: Cache path must not be null.' '\nERROR:缓存路径不可设置为空。',
    );
    return LocalCacheSync()._userDefaultCachePath;
  }

  dynamic operator [](String key) => getWithKey(key);

  void operator []=(String key, dynamic value) => setWithKey(key, value);

  /// 使用Key保存一个值
  LocalCacheObject setWithKey<T>(String k, T v) {
    return LocalCacheObject(k, channel, {'v': v})..save();
  }

  /// 使用Key获取一个值
  T? getWithKey<T>(String k) {
    var map = LocalCacheObject(k, channel).value;
    if (map?.isEmpty != false) {
      return null;
    }
    return map!['v'] is T ? map['v'] : null;
  }
}

/// 用于读取特定Channel的loader类，实现了增删查改方法
class LocalCacheLoader {
  final String channel;

  LocalCacheLoader(this.channel);

  Uri get directoryPath => LocalCacheSync().cachePath!.resolve('$channel/');

  /// 统计缓存信息
  CacheInfo get cacheInfo {
    List<FileSystemEntity> list = directory.listSync();
    var fileList =
        list.where((element) => element is File).toList().cast<File>();
    if (r'_$LocalCacheImage.image' == channel) {
      var dList = list
          .where(
            (element) => element is Directory,
          )
          .toList()
          .cast<Directory>();
      for (var d in dList) {
        var list = d
            .listSync()
            .where((element) => element is File)
            .toList()
            .cast<File>();
        // print(list);
        fileList.addAll(list);
      }
    }
    var count = 0;
    for (var file in fileList) {
      count += file.readAsBytesSync().length;
    }
    return CacheInfo(
      cacheCount: fileList.length,
      cacheLength: count,
    );
  }

  Directory get directory {
    var d = Directory.fromUri(directoryPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return d;
  }

  List<LocalCacheObject> get all {
    List<FileSystemEntity> list = directory.listSync();
    List<LocalCacheObject> targetList = [];
    for (var file in list) {
      if (file is File) {
        targetList.add(
          LocalCacheObject(file.path.split('/').last.split('.').first, channel),
        );
      }
    }
    return targetList;
  }

  LocalCacheObject getById(String id) {
    return LocalCacheObject(id, channel);
  }

  LocalCacheObject saveById(String id, Map<String, dynamic> value) {
    return LocalCacheObject(id, channel, value)..save();
  }

  LocalCacheObject deleteById(String id) {
    return LocalCacheObject(id, channel)..delete();
  }

  // 清除全部
  void clearAll() {
    directory.deleteSync(recursive: true);
  }
}

class CacheInfo {
  final int? cacheCount;
  final int? cacheLength;

  CacheInfo({this.cacheCount, this.cacheLength});

  String get sizeDesc => calculateSize(cacheLength! / 1);

  static String calculateSize(double limit) {
    var size = '';
    if (limit < 0.1 * 1024) {
      size = limit.toStringAsFixed(2) + ' B';
    } else if (limit < 0.1 * 1024 * 1024) {
      size = (limit / 1024).toStringAsFixed(2) + ' KB';
    } else if (limit < 0.1 * 1024 * 1024 * 1024) {
      size = (limit / (1024 * 1024)).toStringAsFixed(2) + ' MB';
    } else {
      size = (limit / (1024 * 1024 * 1024)).toStringAsFixed(2) + ' GB';
    }
    var sizeStr = size + '';
    var index = sizeStr.indexOf('.');
    String dou = sizeStr.substring(index + 1, index + 1 + 2);
    if (dou == '00') {
      return sizeStr.substring(0, index) +
          sizeStr.substring(index + 3, index + 3 + 2);
    }
    return size;
  }

  @override
  String toString() {
    return "Cache Count: $cacheCount / Cache Data: $sizeDesc";
  }
}

class LocalCacheObject {
  final String id;

  String get realId => id.replaceAll(RegExp('[\\\\/:.]'), '_');

  String channel;
  LocalCacheObject(this.id,
      [this.channel = r'_$DefaultChannel', Map<String, dynamic>? value])
      : this._value = value;

  Uri get path => LocalCacheSync().cachePath!.resolve('$channel/');
  File get file => File.fromUri(path.resolve('$realId.json'));

  bool get isCache => _value != null;

  Map<String, dynamic>? _value;

  Map<String, dynamic>? get value {
    if (_value == null) {
      LocalCacheSync().willLoadValue?.call(this);
      _value = read();
      LocalCacheSync().didLoadValue?.call(_value, this);
    }
    return _value;
  }

  clear() {
    _value = null;
  }

  Map<String, dynamic>? read() {
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

  File save() {
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
