import 'package:example/model/device.dart';
import 'package:flutter/material.dart';
import 'package:local_cache_sync/local_cache_sync.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('local_cache_sync'),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 20),
        child: Column(
          children: <Widget>[
            Center(
              child: MaterialButton(
                color: Colors.orange,
                textColor: Colors.white,
                child: Text('List Demo(Device Manage)'),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => ListDemoPage(),
                  ));
                },
              ),
            ),
            Center(
              child: MaterialButton(
                color: Colors.orange,
                textColor: Colors.white,
                child: Text('View All Channel'),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => CacheChannelListPage(),
                  ));
                },
              ),
            ),
            Center(
              child: MaterialButton(
                color: Colors.orange,
                textColor: Colors.white,
                child: Text('View All Image Cache'),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => CacheImageTablePage(),
                  ));
                },
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 40),
              child: Text("Simple Userdefault Demo:"),
            ),
            // 你可以使用[]操作符或者getWithKey方法
            Switch(
              value: LocalCacheSync.userDefault['switch-A'] == true,
              onChanged: (v) {
                setState(() {
                  LocalCacheSync.userDefault['switch-A'] = v;
                });
              },
            ),
            // []与getWithKey是等效的
            Switch(
              value: LocalCacheSync.userDefault.getWithKey<bool>('switch-A') ??
                  false,
              onChanged: (v) {
                setState(() {
                  LocalCacheSync.userDefault.setWithKey<bool>('switch-A', v);
                });
              },
            ),
            Switch(
              value: LocalCacheSync.userDefault['switch-B'] == true,
              onChanged: (v) {
                setState(() {
                  LocalCacheSync.userDefault['switch-B'] = v;
                });
              },
            ),
            Switch(
              value: LocalCacheSync.userDefault['switch-C'] == true,
              onChanged: (v) {
                setState(() {
                  LocalCacheSync.userDefault['switch-C'] = v;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ListDemoPage extends StatefulWidget {
  @override
  _ListDemoPageState createState() => _ListDemoPageState();
}

class _ListDemoPageState extends State<ListDemoPage> {
  List<Device> list = Device.all();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Demo'),
        actions: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              child: Container(
                color: Colors.black.withOpacity(0),
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Center(
                  child: Text('Add'),
                ),
              ),
              onTap: () {
                var code = DateTime.now().millisecond.toString();
                var device = Device(uuid: code, name: '测试:$code', type: 1);
                device.save();
                list = Device.all();
                print(list);
                setState(() {});
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              child: Container(
                color: Colors.black.withOpacity(0),
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Center(
                  child: Text('Manage'),
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => CacheViewTablePage('device'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (ctx, index) => Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(list[index].uuid),
        ),
      ),
    );
  }
}
