import 'package:local_cache_sync/local_cache_sync.dart';

class Device extends LocalCacheObject {
  Device.formMap(String id, Map value) : super(id, 'device', value);

  static List<Device> all() {
    return LocalCacheLoader('device')
        .all
        .map<Device>(
          (cache) => Device.formMap(cache.id, cache.value),
        )
        .toList();
  }

  Device(String id, {String name, String uuid})
      : super(
          id,
          'device',
          {'name': name, 'uuid': uuid},
        );

  String get name => value['name'];
  String get uuid => value['uuid'];
}
