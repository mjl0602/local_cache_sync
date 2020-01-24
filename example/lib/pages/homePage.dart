import 'package:example/model/device.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Demo'),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            height: 80,
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: <Widget>[
                RaisedButton(
                  child: Text('Add'),
                  onPressed: () {
                    var code = DateTime.now().millisecond.toString();
                    var device = Device(code, name: '测试:$code', uuid: 'test');
                    device.save();
                  },
                ),
                RaisedButton(
                  child: Text('Add'),
                  onPressed: () {
                    var code = DateTime.now().millisecond.toString();
                    var device = Device(code, name: '测试:$code', uuid: 'test');
                    device.save();
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
