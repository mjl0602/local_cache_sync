import 'dart:io';

import 'package:flutter/material.dart';
import 'package:local_cache_sync/image_cache/file_cache.dart';
import 'package:local_cache_sync/image_cache/file_cache_image.dart';
import 'package:local_cache_sync/local_cache_sync.dart';

class CacheImageTablePage extends StatefulWidget {
  const CacheImageTablePage({Key key}) : super(key: key);

  @override
  _CacheImageTablePageState createState() => _CacheImageTablePageState();
}

class _CacheImageTablePageState extends State<CacheImageTablePage> {
  List<File> list = [];

  @override
  void initState() {
    setState(() {
      list = LocalCacheSync.imageCache.all;
    });
    print(list[0].readAsBytesSync());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Image Cache'),
      ),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (ctx, index) => GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => SimpleDialog(
                children: <Widget>[
                  LocalCacheImage('https://segmentfault.com/img/bVbHoL3'),
                ],
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Image.memory(
              CacheEntry.fromFileSync(list[index]).bytes,
            ),
          ),
        ),
      ),
    );
  }
}
