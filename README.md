# local_cache_sync

一个非常简单易用的`Flutter`本地储存库，适用于在本地储存一列轻量数据（例如用户保存在本地的设备信息，或者缓存一系列用户信息）。

`local_cache_sync`的所有方法都是**同步**，而不是**异步**的。这意味着你不需要使用`await`就可以获取数据。在`flutter`中，这可以显著减少`StatefulWidget`的数量，大量减少代码的复杂度。

## Start

pubspec.yaml
```yaml
  path_provider: ^1.4.5
  local_cache_sync: ^1.1.0
```

Set Cache Path.

After 1.2.0:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalCacheSync.instance.setCachePath(
    await getTemporaryDirectory(),
    'example_app/',
  );
  runApp(MyApp());
}
```

Before(less than or equal to 1.1.1):
```dart
getTemporaryDirectory().then((uri) {
      LocalCacheSync.instance.setCachePath(uri.path);
});
```

### User Default Demo

`Switch`组件的值会被缓存到本地，即使重新启动App也会保留

使用`local_cache_sync`保存与读取参数都是同步的，这意味着赋值即是保存，而且在`StatelessWidget`中，可以立即使用数据。

```dart
Switch(
  value: LocalCacheSync.userDefault.getWithKey<bool>('switch-A'),
  onChanged: (v) {
    setState(() {
      LocalCacheSync.userDefault.setWithKey<bool>('switch-A', v);
    });
  },
),
```

## Usage: User Default Cache 用户偏好设置缓存

使用`local_cache_sync`实现保存用户自定义设置非常简单，**只需要赋值与取值，无需异步等待**，即可保存参数到本地。  
读取参数也是同步的，这意味着你可以在`StatelessWidget`中立即使用数据。

### Use Function：
Save values
```dart
LocalCacheSync.userDefault.setWithKey<bool>('isDarkMode',true);
LocalCacheSync.userDefault.setWithKey<String>('token','aabbccdd');
LocalCacheSync.userDefault.setWithKey<Map>('x-config',{'id':1243});
```
Read values
```dart
var res = LocalCacheSync.userDefault.getWithKey<bool>('isDarkMode');
var res = LocalCacheSync.userDefault.getWithKey<String>('token');
var res = LocalCacheSync.userDefault.getWithKey<Map>('x-config');
```
### Use operator:
Save values
```dart
LocalCacheSync.userDefault['isDarkMode'] = true;
LocalCacheSync.userDefault['token'] = 'aabbccdd';
LocalCacheSync.userDefault['x-config'] = {'id':1243};
```
Read values
```dart
bool res = LocalCacheSync.userDefault['isDarkMode'];
String res = LocalCacheSync.userDefault['token'];
Map res = LocalCacheSync.userDefault['x-config'];
```

## Usage: Table Cache 列表管理

如果你需要管理一系列值，请使用`LocalCacheLoader`，只需要一个`channel`标志，你就可以管理一系列值。    

### Lazy Load

`LocalCacheLoader`在内部实现了懒加载的效果：只有取`value`属性时数据才真正被加载。  

在应用中，加入你有1-100号设备显示在Listview.builder中，只有100号设备即将进入屏幕中时，100号设备的缓存参数才会被真正加载。也就是说LocalCacheLoader不会导致长列表卡顿。

### Model Example

我推荐你这样创建你的model：  
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
          (cache) => Device.fromJson(cache),
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

你也可以另外封装loader来读写其他信息，对于轻量级的储存，以上是非常简单易用的。


## 警告

不要在io密集型场景使用local_cache_sync，例如即时储存每秒10次的扫描结果。  
虽然flutter中阻塞主线程不会导致UI卡顿，但是你仍不应当在io密集型场景使用，这超出了local_cache_sync设计的工作范围。