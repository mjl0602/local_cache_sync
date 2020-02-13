import 'package:example/model/device.dart';
import 'package:flutter/material.dart';
import 'package:local_cache_sync/local_cache_sync.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Device> list = [];
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
