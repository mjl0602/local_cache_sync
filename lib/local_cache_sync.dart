library local_cache_sync;

export './cacheViewTablePage.dart';
export './cacheChannelListPage.dart';
import 'dart:convert';
import 'dart:io';

/// LocalCacheSync单例，用于储存缓存路径，并暴露常用接口
class LocalCacheSync {
  // 工厂模式
  factory LocalCacheSync() => _getInstance();
  static LocalCacheSync get instance => _getInstance();
  static LocalCacheSync _instance;
  LocalCacheSync._internal() {
    // 初始化
  }
  static LocalCacheSync _getInstance() {
    if (_instance == null) {
      _instance = new LocalCacheSync._internal();
    }
    return _instance;
  }

  void Function(LocalCacheObject) willLoadValue;
  void Function(Map<String, dynamic>, LocalCacheObject) didLoadValue;

  Uri _cachePath;
  void setCachePath(Directory rootPath, [String cacheName = '']) =>
      _cachePath = rootPath.uri.resolve(cacheName);

  Uri get cachePath {
    assert(_cachePath != null, 'Cache path must not be null. 缓存路径不可设置为空。');
    return _cachePath;
  }

  static LocalCacheLoader loaderOfChannel(String channel) =>
      LocalCacheLoader(channel);
  static UserDefaultSync get userDefault => UserDefaultSync();
}

/// 封装了一个简单的读写方法，在不存在值时返回默认值
class DefaultValueCache<T> {
  final String key;
  final T defaultValue;

  const DefaultValueCache(this.key, [this.defaultValue]);

  T get value => LocalCacheSync.userDefault[key] ?? defaultValue;

  set value(T value) {
    LocalCacheSync.userDefault[key] = value;
  }
}

/// 用于储存用户缓存数据，继承自LocalCacheLoader，实现了自己的读写方法，并增加了类型判断
class UserDefaultSync extends LocalCacheLoader {
  UserDefaultSync() : super(r'_$LocalCacheDefault');

  dynamic operator [](String key) => getWithKey(key);

  void operator []=(String key, dynamic value) => setWithKey(key, value);

  /// 使用Key保存一个值
  LocalCacheObject setWithKey<T>(String k, T v) {
    return LocalCacheObject(k, channel, {'v': v})..save();
  }

  /// 使用Key获取一个值
  T getWithKey<T>(String k) {
    var map = LocalCacheObject(k, channel).value;
    if (map?.isEmpty != false) {
      return null;
    }
    return map['v'] is T ? map['v'] : null;
  }
}

/// 用于读取特定Channel的loader类，实现了增删查改方法
class LocalCacheLoader {
  final String channel;

  LocalCacheLoader(this.channel);

  Uri get directoryPath => LocalCacheSync().cachePath.resolve('$channel/');

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

class LocalCacheObject {
  final String id;

  String get realId => id.replaceAll(RegExp('[\\\\/:.]'), '_');

  String channel;
  LocalCacheObject(this.id,
      [this.channel = r'_$DefaultChannel', Map<String, dynamic> value])
      : this._value = value;

  Uri get path => LocalCacheSync().cachePath.resolve('$channel/');
  File get file => File.fromUri(path.resolve('$realId.json'));

  bool get isCache => _value != null;

  Map<String, dynamic> _value;

  Map<String, dynamic> get value {
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

  Map<String, dynamic> read() {
    if (!file.existsSync()) {
      return null;
    }
    var content = file.readAsStringSync();
    return json.decode(content);
  }

  File save() {
    return file
      ..createSync(recursive: true)
      ..writeAsStringSync(
        JsonEncoder.withIndent('   ').convert(_value ?? {}),
      );
  }

  delete() {
    _value = null;
    file.deleteSync();
  }
}
