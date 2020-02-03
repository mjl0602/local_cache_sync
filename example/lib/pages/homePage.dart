import 'package:example/model/device.dart';
import 'package:flutter/material.dart';

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
            child: RaisedButton(
              child: Text('Add'),
              onPressed: () {
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
            child: RaisedButton(
              child: Text('Read All'),
              onPressed: () {
                list = Device.all();
                print(list);
                setState(() {});
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
