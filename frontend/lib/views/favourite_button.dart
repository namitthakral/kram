import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/dashboard/favourite_provider.dart';
import '../utils/custom_colors.dart';
import '../utils/custom_images.dart';
import '../utils/images/base_image.dart';
import '../utils/images/image_asset.dart';

class FavouriteButton extends StatelessWidget {
  const FavouriteButton({
    super.key,
    this.color = CustomAppColors.black03,
    this.showRedColorHeart = true,
  });
  final Color? color;
  final bool showRedColorHeart;

  @override
  Widget build(BuildContext context) => Consumer<FavouriteProvider>(
    builder:
        (context, provider, child) => InkWell(
          splashColor: Colors.transparent,
          onTap: () => provider.setFavourite(fav: !provider.isFavourite),
          child: BaseImage(
            asset: LocalAsset(
              url:
                  provider.isFavourite
                      ? CustomImages.iconFavouriteFilled
                      : CustomImages.iconFavourite,
            ),
            color: showRedColorHeart ? CustomAppColors.red01 : color,
            height: 20,
            width: 20,
          ),
        ),
  );
}
