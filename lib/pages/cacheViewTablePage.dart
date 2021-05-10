library local_cache_sync;

import 'package:flutter/material.dart';
import 'package:local_cache_sync/local_cache_sync.dart';

class CacheViewTablePage extends StatefulWidget {
  final String channel;

  const CacheViewTablePage(this.channel, {Key? key}) : super(key: key);

  @override
  _CacheViewTablePageState createState() => _CacheViewTablePageState();
}

class _CacheViewTablePageState extends State<CacheViewTablePage> {
  List<LocalCacheObject> list = [];

  @override
  void initState() {
    setState(() {
      list = LocalCacheLoader(widget.channel).all;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(widget.channel),
      ),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (ctx, index) => _Row(
          object: list[index],
          onDelete: () {
            list[index].delete();
            setState(() {
              list = LocalCacheLoader(widget.channel).all;
            });
          },
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final LocalCacheObject? object;

  final Function? onDelete;

  const _Row({
    Key? key,
    this.object,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> kvChildren = [];
    var value = object!.value;
    if (value == null) {
      value = {
        'Error': 'Json Encode Error',
      };
    }
    List<String> l = value.keys.toList();
    for (var i = 0; i < l.length; i++) {
      var k = l[i];
      kvChildren.add(
        _KeyValueText(
          k: k,
          v: value[k].toString(),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xfff5f5f4),
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text(
                    'ID:${object!.id}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.36),
                    ),
                  ),
                ),
                Column(
                  children: kvChildren,
                ),
              ],
            ),
          ),
          Column(
            children: <Widget>[
              IconButton(
                hoverColor: Color(0xfff5f5f4),
                color: Colors.red,
                icon: Icon(
                  Icons.delete,
                ),
                onPressed: onDelete as void Function()?,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _KeyValueText extends StatelessWidget {
  final String? k, v;
  const _KeyValueText({
    Key? key,
    this.k,
    this.v,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            padding: EdgeInsets.symmetric(
              vertical: 3,
              horizontal: 6,
            ),
            margin: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              k ?? "[??]",
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v ?? '[Unknown Value]',
              maxLines: 100,
            ),
          ),
        ],
      ),
    );
  }
}
