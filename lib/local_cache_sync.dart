library local_cache_sync;

import 'dart:convert';
import 'dart:io';

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

  String _cachePath;
  void setCachePath(String path) => _cachePath = path;

  Uri get cachePath {
    assert(_cachePath != null, 'Cache path must not be null. 缓存路径不可设置为空。');
    return Uri.parse(_cachePath);
  }

  LocalCacheLoader loaderOfChannel(String channel) => LocalCacheLoader(channel);
  LocalCacheLoader userDefault() => LocalCacheLoader(r'_$LocalCacheDefault');
}

class LocalCacheLoader {
  final String channel;

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
        // TODO: 获取文件名]
        // var fileName = RegExp('(.*\/)*([^.]+).*').allMatches(file.path);
        // var fileName = file.path.matchAsPrefix(x)
        targetList.add(
          LocalCacheObject('TODO:', channel),
        );
      }
    }
    return targetList;
  }
  // TODO: 清除全部
  // TODO: 获取文件大小

  LocalCacheLoader(this.channel);

  LocalCacheObject create(String id, Map<String, dynamic> map) {
    return LocalCacheObject(id, channel, map);
  }
}

class LocalCacheObject {
  final String id;
  final String channel;
  LocalCacheObject(this.id,
      [this.channel = r'_$DefaultChannel', Map<String, dynamic> value])
      : this._value = value;

  Uri get path => LocalCacheSync().cachePath.resolve('$channel/');
  File get file => File.fromUri(path.resolve('$id.json'));

  bool get isCahce => _value != null;

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
    file.deleteSync();
  }
}
