import 'dart:io';
import 'package:local_cache_sync/local_cache_sync.dart';

/// 用于读取特定Channel的loader类，实现了增删查改方法
class LocalCacheImageLoader {
  final String channel;

  LocalCacheImageLoader(this.channel);

  Uri get directoryPath => LocalCacheSync().cachePath!.resolve('$channel/');

  Directory get directory {
    var d = Directory.fromUri(directoryPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return d;
  }

  List<File> get all {
    var list = directory.listSync(
      recursive: true,
    );
    List<File> l = [];
    for (var file in list) {
      if (file is File) {
        l.add(file);
      }
    }
    return l;
  }
}