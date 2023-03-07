library local_cache_sync;

export 'package:local_cache_sync/core/loader.dart';
export 'package:local_cache_sync/core/object.dart';
export 'package:local_cache_sync/pages/cacheChannelListPage.dart';
export 'package:local_cache_sync/pages/cacheViewTablePage.dart';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:local_cache_sync/core/loader.dart';
import 'package:local_cache_sync/core/object.dart';
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

  static LocalCacheLoader loaderOfChannel(String channel, [CacheType? type]) =>
      LocalCacheLoader(channel, type: type);
  // 用户偏好设置
  static UserDefaultSync get userDefault => UserDefaultSync();
}

/// 封装了一个简单的读写方法，在不存在值时返回默认值
class DefaultValueCache<T> extends ValueNotifier<T> {
  final String key;
  final T defaultValue;

  DefaultValueCache(this.key, this.defaultValue) : super(defaultValue);

  @override
  T get value => LocalCacheSync.userDefault[key] ?? defaultValue;

  @override
  set value(T? value) {
    LocalCacheSync.userDefault[key] = value;
    super.value = this.value;
  }
}

/// 用于储存用户缓存数据，继承自LocalCacheLoader，实现了自己的读写方法，并增加了类型判断
/// 用户缓存数据可以单独指定一个路径(使用setCachePath)
/// 例如，可以把其他数据放在会清理的文件夹，将用户缓存放在不会被清理的文件夹(token等数据)
class UserDefaultSync extends LocalCacheLoader {
  UserDefaultSync() : super(r'_$LocalCacheDefault');

  Uri get directoryPath => cachePath.resolve('$channel/');

  /// 用户缓存可以单独指定一个路径
  /// 例如，可以把其他数据放在会清理的文件夹，将用户缓存放在不会被清理的文件夹(token等数据)
  static void setCachePath(
    Directory rootPath, [
    String cacheName = 'sync_cache',
  ]) =>
      LocalCacheSync()._userDefaultCachePath = rootPath.uri.resolve(cacheName);

  static Uri get cachePath {
    return (LocalCacheSync()._userDefaultCachePath ??
        LocalCacheSync().cachePath)!;
  }

  dynamic operator [](String key) => getWithKey(key);

  void operator []=(String key, dynamic value) => setWithKey(key, value);

  /// 使用Key保存一个值
  UserDefaultCacheObject setWithKey<T>(String k, T v) {
    return UserDefaultCacheObject(k, channel, {'v': v})..saveAsJson();
  }

  /// 使用Key获取一个值
  T? getWithKey<T>(String k) {
    var map = UserDefaultCacheObject(k, channel).value;
    if (map?.isEmpty != false) {
      return null;
    }
    return map!['v'] is T ? map['v'] : null;
  }
}
