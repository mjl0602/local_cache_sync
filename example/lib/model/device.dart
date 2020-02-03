import 'package:local_cache_sync/local_cache_sync.dart';

class Device {
  final String uuid;
  final String name;
  final int type;

  Device({
    this.uuid,
    this.name,
    this.type,
  });

  Device.formJson(Map<String, dynamic> map)
      : this(
          uuid: map['uuid'],
          name: map['name'],
          type: map['type'],
        );

  static LocalCacheLoader get _loader => LocalCacheLoader('device');

  static List<Device> all() {
    return _loader.all
        .map<Device>(
          (cache) => Device(
            uuid: cache.id,
            name: cache.value['name'],
            type: cache.value['type'],
          ),
        )
        .toList();
  }

  LocalCacheObject save() {
    return Device._loader.saveById(uuid, jsonMap);
  }

  Map<String, dynamic> get jsonMap => {
        'uuid': uuid,
        'name': name,
        'type': type,
      };
}
