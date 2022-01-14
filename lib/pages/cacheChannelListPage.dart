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
    var channelList = Directory.fromUri(
      LocalCacheSync.instance!.cachePath!,
    ).listSync();
    // 补上用户的
    if (UserDefaultSync.cachePath != LocalCacheSync.instance!.cachePath!) {
      channelList = Directory.fromUri(
            UserDefaultSync.cachePath,
          ).listSync() +
          channelList;
    }
    for (var channel in channelList) {
      list.add(channel.path);
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
          fullChannelPath: list[index],
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
  final String? fullChannelPath;
  final Function? onTap;

  String get name => fullChannelPath!.split('/').last;

  CacheInfo get cacheInfo => LocalCacheLoader(name).cacheInfo;

  const _Row({
    Key? key,
    this.fullChannelPath,
    this.onTap,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap as void Function()?,
      child: Container(
        color: Colors.white,
        margin: EdgeInsets.only(bottom: 1),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Text(name),
              ],
            ),
            Container(height: 6),
            Text(
              "($cacheInfo)",
              style: TextStyle(
                fontSize: 12,
                color: Colors.red,
              ),
            ),
            Container(height: 6),
            Text(
              fullChannelPath!,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xff9b9b9b),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
