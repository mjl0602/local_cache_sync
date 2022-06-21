import 'dart:io';

import 'package:local_cache_sync/core/object.dart';
import 'package:local_cache_sync/local_cache_sync.dart';

enum CacheType {
  json,
  plain,
  raw,
}

/// 用于读取特定Channel的loader类，实现了增删查改方法
class LocalCacheLoader {
  final String channel;
  final CacheType? type;

  LocalCacheLoader(
    this.channel, {
    this.type: CacheType.json,
  });

  Uri get directoryPath => LocalCacheSync().cachePath!.resolve('$channel/');

  /// 统计缓存信息
  CacheInfo get cacheInfo {
    List<FileSystemEntity> list = directory.listSync();
    if (list.length > 1000)
      return CacheInfo(
        cacheCount: list.length,
        cacheLength: -1,
      );
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
      count += file.lengthSync();
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
        CacheType type = CacheType.json;
        if (file.path.endsWith('.json')) type = CacheType.json;
        if (file.path.endsWith('.txt')) type = CacheType.plain;
        if (file.path.endsWith('.byte')) type = CacheType.raw;
        targetList.add(
          LocalCacheObject(
            file.path.split('/').last.split('.').first,
            channel: channel,
            type: type,
          ),
        );
      }
    }
    return targetList;
  }

  LocalCacheObject getById(String id) {
    return LocalCacheObject(id, channel: channel);
  }

  LocalCacheObject saveById(
    String id,
    Map<String, dynamic> value,
  ) {
    return LocalCacheObject(
      id,
      channel: channel,
      value: value,
    )..saveAsJson();
  }

  LocalCacheObject saveByIdAsync(
    String id,
    Map<String, dynamic> value,
  ) {
    return LocalCacheObject(
      id,
      channel: channel,
      value: value,
    )..saveAsync();
  }

  LocalCacheObject deleteById(String id) {
    return LocalCacheObject(
      id,
      channel: channel,
    )..delete();
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
