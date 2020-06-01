import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui show instantiateImageCodec, Codec;

import 'file_cache.dart';

class LocalCacheImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double height, width;

  const LocalCacheImage(
    this.url, {
    Key key,
    this.fit,
    this.height,
    this.width,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Image(
      height: height,
      width: width,
      image: FileCacheImage(url),
      fit: fit,
    );
  }
}

class FileCacheImage extends ImageProvider<FileCacheImage> {
  /// Creates an ImageProvider which loads an image from the [url], using the [scale].
  const FileCacheImage(
    this.url, {
    this.scale: 1.0,
  })  : assert(url != null),
        assert(scale != null);

  /// The URL from which the image will be fetched.
  final String url;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  @override
  Future<FileCacheImage> obtainKey(ImageConfiguration configuration) {
    return new SynchronousFuture<FileCacheImage>(this);
  }

  @override
  ImageStreamCompleter load(FileCacheImage key, DecoderCallback decode) {
    return new MultiFrameImageStreamCompleter(
      codec: _loadAsync(key),
      scale: key.scale,
    );
  }

  Future<ui.Codec> _loadAsync(FileCacheImage key) async {
    assert(key == this);
    FileCache fileCache = await FileCache.fromDefault();

    try {
      final Uint8List bytes = await fileCache.getBytes(key.url);
      return await ui.instantiateImageCodec(bytes);
    } catch (error) {
      return null;
    }
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final FileCacheImage typedOther = other;
    return url == typedOther.url && scale == typedOther.scale;
  }

  @override
  int get hashCode => hashValues(url, scale);

  @override
  String toString() => '$runtimeType("$url", scale: $scale)';
}
