# local_cache_sync

A new Flutter package project.

## Getting Started

This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.


## Usage
Set Cache Path.
```dart
getTemporaryDirectory().then((uri) {
      LocalCacheSync.instance.setCachePath(uri.path);
});
```

Create class load from loader.

```dart

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
```