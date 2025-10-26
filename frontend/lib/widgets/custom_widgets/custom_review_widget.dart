import 'package:flutter/material.dart';

import '../../utils/custom_colors.dart';
import '../../utils/custom_images.dart';
import '../../utils/extensions.dart';
import '../../utils/images/base_image.dart';
import '../../utils/images/image_asset.dart';
import '../../utils/utils.dart';

class CustomReviewWidget extends StatelessWidget {
  const CustomReviewWidget({
    required this.rating,
    super.key,
    this.showBackground = false,
    this.ratingStyle,
    this.reviewStyle,
  });
  final String rating;
  final bool showBackground;
  final TextStyle? ratingStyle, reviewStyle;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child:
              showBackground
                  ? CircleAvatar(
                    backgroundColor: CustomAppColors.yellow01.withValues(
                      alpha: 0.13,
                    ),
                    radius: 15,
                    child: BaseImage(
                      asset: LocalAsset(url: CustomImages.iconStar),
                      height: 15,
                      color: CustomAppColors.yellow01,
                    ),
                  )
                  : BaseImage(
                    asset: LocalAsset(url: CustomImages.iconStar),
                    height: 15,
                    color: CustomAppColors.yellow01,
                  ),
        ),
        TextSpan(
          text: '  ${Utils.calculateRatingBasedOnReview(rating)}',
          style:
              ratingStyle ??
              context.textTheme.displaySm.copyWith(
                color: CustomAppColors.yellow01,
              ),
        ),
        TextSpan(
          text:
              ' '
              '($rating ${context.translate('reviews')})',
          style:
              reviewStyle ??
              context.textTheme.bodyXs.copyWith(color: CustomAppColors.grey05),
        ),
      ],
    ),
  );
}
