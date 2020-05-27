import 'dart:io';

import 'package:flutter/material.dart';
import 'package:local_cache_sync/local_cache_sync.dart';

class CacheChannelListPage extends StatefulWidget {
  @override
  _CacheChannelListPageState createState() => _CacheChannelListPageState();
}

class _CacheChannelListPageState extends State<CacheChannelListPage> {
  List<String> list = [];

  @override
  void initState() {
    var res = LocalCacheSync.instance.cachePath;
    var channelList = Directory.fromUri(res).listSync();
    for (var channel in channelList) {
      var name = channel.path.split('/').last;
      list.add(name);
      print(name);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('All Channel'),
      ),
      backgroundColor: Color(0xfff5f5f4),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (ctx, index) => _Row(
          channel: list[index],
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => CacheViewTablePage(list[index]),
            ));
          },
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String channel;
  final Function onTap;

  const _Row({
    Key key,
    this.channel,
    this.onTap,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        margin: EdgeInsets.only(bottom: 1),
        padding: EdgeInsets.all(24),
        child: Text(channel),
      ),
    );
  }
}
