import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../app_logo_circular_progress_indicator.dart';
import '../custom_colors.dart';
import 'image_asset.dart';

class BaseImage extends StatelessWidget {
  const BaseImage({
    required this.asset,
    super.key,
    this.defaultAsset,
    this.height,
    this.color,
    this.width = 50,
    this.showCircularLoader = true,
    this.fit = BoxFit.cover,
  });
  final Asset asset;
  final LocalAsset? defaultAsset;
  final double? height;
  final double width;
  final bool showCircularLoader;
  final BoxFit fit;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (asset.url == '') {
      return _defaultAssetImage(
        defaultAsset: defaultAsset,
        height: height,
        width: width,
      );
    } else if (asset is NetworkAsset) {
      if (_isSvgImage(asset.url)) {
        return SvgPicture.network(
          asset.url,
          placeholderBuilder:
              (BuildContext context) =>
                  _placeholderBuilder(context, showCircularLoader),
          height: height,
          width: width,
          fit: fit,
        );
      } else if (defaultAsset != null) {
        return CachedNetworkImage(
          height: height,
          width: width,
          // memCacheHeight: _memCacheHeight,
          // memCacheWidth: _memCacheWidth,
          imageUrl: asset.url,
          placeholder:
              (context, url) => _defaultAssetImage(
                defaultAsset: defaultAsset,
                height: height,
                width: width,
              ),
          errorWidget:
              (context, url, error) => _error404(
                defaultAsset: defaultAsset,
                height: height,
                width: width,
              ),
          fit: fit,
        );
      } else {
        return CachedNetworkImage(
          height: height,
          width: width,
          // memCacheHeight: _memCacheHeight,
          // memCacheWidth: _memCacheWidth,
          imageUrl: asset.url,
          progressIndicatorBuilder:
              (context, url, downloadProgress) => Center(
                child:
                    showCircularLoader
                        ? const AppLogoCircularProgressIndicator()
                        : const SizedBox(width: 1, height: 1),
              ),
          errorWidget:
              (context, url, error) => _error404(
                defaultAsset: defaultAsset,
                height: height,
                width: width,
              ),
          fit: fit,
        );
      }
    } else {
      if (_isSvgImage(asset.url)) {
        return SvgPicture.asset(
          asset.url,
          height: height,
          width: width,
          fit: fit,
          colorFilter: ColorFilter.mode(
            color ?? CustomAppColors.grey01,
            BlendMode.srcIn,
          ),
        );
      } else {
        return Image(
          image: AssetImage(asset.url),
          height: height,
          width: width,
          fit: fit,
        );
      }
    }
  }
}

Widget _error404({
  LocalAsset? defaultAsset,
  double? height = 20,
  double? width,
}) => Stack(
  children: <Widget>[
    Container(
      alignment: Alignment.center,
      child: _defaultAssetImage(
        defaultAsset: defaultAsset,
        height: height,
        width: width,
      ),
    ),
    Container(
      alignment: Alignment.center,
      child: Text(
        '!',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.red, fontSize: height! * 0.7),
      ),
    ),
  ],
);

Widget _placeholderBuilder(BuildContext context, bool showCircularLoader) =>
    Padding(
      padding: const EdgeInsets.all(4.0),
      child: Center(
        child:
            showCircularLoader
                ? const AppLogoCircularProgressIndicator()
                : const SizedBox(width: 1, height: 1),
      ),
    );

Widget _defaultAssetImage({
  LocalAsset? defaultAsset,
  double? height,
  double? width,
}) {
  if (_isSvgImage(defaultAsset!.url)) {
    return SvgPicture.asset(defaultAsset.url, height: height, width: width);
  }
  return Image(
    image: AssetImage(defaultAsset.url),
    height: height,
    width: width,
  );
}

bool _isSvgImage(String url) => url.toLowerCase().endsWith('.svg');

class Image404 extends StatelessWidget {
  const Image404({super.key, this.size});
  final Size? size;

  @override
  Widget build(BuildContext context) =>
      _error404(height: size!.height, width: size!.width);
}
