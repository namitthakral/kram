import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../provider/login_signup/login_provider.dart';
import '../../utils/custom_colors.dart';
import '../../utils/custom_images.dart';
import '../../utils/extensions.dart';
import '../../utils/router_service.dart';
import '../../utils/utils.dart';
import 'custom_elevated_button.dart';
import 'custom_text_field.dart';
import 'dash_line.dart';
import 'double_circle.dart';

enum BottomSheetType { register, forgotPassword, passwordUpdate, cartPrice }

class BottomSheetConfig {
  const BottomSheetConfig({
    this.height = 0.70,
    this.canDismiss = false,
    this.padding = const EdgeInsets.all(24.0),
    this.showDragHandle = true,
    this.enableDrag = false,
    this.elevation = 40,
  });
  final double height;
  final bool canDismiss;
  final EdgeInsets padding;
  final bool showDragHandle;
  final bool enableDrag;
  final double elevation;

  static const BottomSheetConfig defaultConfig = BottomSheetConfig();
  static const BottomSheetConfig halfHeight = BottomSheetConfig(height: 0.50);
  static const BottomSheetConfig smallHeight = BottomSheetConfig(height: 0.35);
}

class CustomBottomSheet {
  static void showCustomModalBottomSheet({
    required BuildContext context,
    required Widget child,
    BottomSheetConfig config = BottomSheetConfig.defaultConfig,
  }) {
    showModalBottomSheet(
      context: context,
      showDragHandle: config.showDragHandle,
      isDismissible: config.canDismiss,
      enableDrag: config.enableDrag,
      elevation: config.elevation,
      scrollControlDisabledMaxHeightRatio: config.height,
      builder:
          (context) => SizedBox(
            width: MediaQuery.sizeOf(context).width,
            child: Padding(padding: config.padding, child: child),
          ),
    );
  }

  static void register({required BuildContext context}) {
    showCustomModalBottomSheet(
      context: context,
      config: BottomSheetConfig.halfHeight,
      child: _SuccessContent(
        iconUrl: CustomImages.iconTickCircle,
        title: context.translate('register_success'),
        description: context.translate('register_success_desc'),
        buttonText: context.translate('go_to_homepage'),
        onPressed: () => context.router.goToHome(),
      ),
    );
  }

  static void forgetPassword({required BuildContext context}) {
    final loginProvider = context.read<LoginProvider>();

    final controller = loginProvider.forgetPasswordEmailController;
    if (controller == null) {
      return;
    }

    showCustomModalBottomSheet(
      context: context,
      config: BottomSheetConfig.halfHeight,
      child: _ForgotPasswordContent(
        title: context.translate('forgot_password'),
        description: context.translate('email_or_phone_number_hint'),
        controller: controller,
        hintText: context.translate('email_or_phone_number_hint'),
        buttonText: context.translate('send_code'),
        onPressed: () {
          context.router.goBack();
          forgetPasswordUpdate(context: context);
        },
      ),
    );
  }

  static void forgetPasswordUpdate({required BuildContext context}) {
    final provider = context.read<LoginProvider>();
    final passwordController = provider.changePasswordController;
    final confirmPasswordController = provider.changeConfirmPasswordController;
    if (passwordController == null || confirmPasswordController == null) {
      return;
    }

    showCustomModalBottomSheet(
      context: context,
      config: BottomSheetConfig.halfHeight,
      child: _PasswordUpdateContent(
        title: context.translate('create_new_password'),
        description: context.translate('email_or_phone_number_hint'),
        passwordLabel: context.translate('password'),
        confirmPasswordLabel: context.translate('confirm_password'),
        passwordController: passwordController,
        confirmPasswordController: confirmPasswordController,
        passwordHint: context.translate('password_hint'),
        buttonText: context.translate('profile_change_password'),
        onPressed: provider.changePasswordButton,
      ),
    );
  }

  static void cartPrice({
    required BuildContext context,
    required String subtotal,
    required String shipping,
    required String total,
    VoidCallback? onCheckout,
  }) {
    showCustomModalBottomSheet(
      context: context,
      config: BottomSheetConfig.smallHeight,
      child: _CartPriceContent(
        subtotalLabel: context.translate('subtotal'),
        subtotalValue: subtotal,
        shippingLabel: context.translate('shipping'),
        shippingValue: shipping,
        totalLabel: context.translate('total_amount'),
        totalValue: total,
        checkoutText: context.translate('checkout'),
        onCheckout: onCheckout ?? () => context.router.goBack(),
      ),
    );
  }

  static void showPromoCode({required BuildContext context}) {
    showCustomModalBottomSheet(
      context: context,
      config: BottomSheetConfig.smallHeight,
      child: const _PromoCodeContent(
        // subtotalLabel: context.translate('subtotal'),
        // subtotalValue: subtotal,
        // shippingLabel: context.translate('shipping'),
        // shippingValue: shipping,
        // totalLabel: context.translate('total_amount'),
        // totalValue: total,
        // checkoutText: context.translate('checkout'),
        // onCheckout: onCheckout ?? () => context.router.goBack(),
      ),
    );
  }
}

class _SuccessContent extends StatelessWidget {
  const _SuccessContent({
    required this.iconUrl,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
  });
  final String iconUrl;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      DoubleCircle(url: iconUrl),
      const SizedBox(height: 28),
      Text(title, style: context.textTheme.titleXl),
      Text(
        description,
        style: context.textTheme.bodySm.copyWith(color: CustomAppColors.grey01),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24),
      CustomElevatedButton(text: buttonText, onPressed: onPressed),
    ],
  );
}

class _ForgotPasswordContent extends StatelessWidget {
  const _ForgotPasswordContent({
    required this.title,
    required this.description,
    required this.controller,
    required this.hintText,
    required this.buttonText,
    required this.onPressed,
  });
  final String title;
  final String description;
  final TextEditingController controller;
  final String hintText;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: context.textTheme.titleXl),
      Text(
        description,
        style: context.textTheme.bodySm.copyWith(color: CustomAppColors.grey01),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24),
      CustomTextField(
        controller: controller,
        prefixButtonIcon: ButtonIcon(icon: CustomImages.iconSms),
        hintText: hintText,
      ),
      const SizedBox(height: 32),
      CustomElevatedButton(text: buttonText, onPressed: onPressed),
    ],
  );
}

class _PasswordUpdateContent extends StatelessWidget {
  const _PasswordUpdateContent({
    required this.title,
    required this.description,
    required this.passwordLabel,
    required this.confirmPasswordLabel,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.passwordHint,
    required this.buttonText,
    required this.onPressed,
  });
  final String title;
  final String description;
  final String passwordLabel;
  final String confirmPasswordLabel;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final String passwordHint;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: context.textTheme.titleXl),
      Text(
        description,
        style: context.textTheme.bodySm.copyWith(color: CustomAppColors.grey01),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 20),
      Text(passwordLabel, style: context.textTheme.labelBase),
      const SizedBox(height: 4),
      CustomTextField(
        controller: passwordController,
        prefixButtonIcon: ButtonIcon(icon: CustomImages.iconSms),
        hintText: passwordHint,
      ),
      const SizedBox(height: 16),
      Text(confirmPasswordLabel, style: context.textTheme.labelBase),
      const SizedBox(height: 4),
      CustomTextField(
        controller: confirmPasswordController,
        prefixButtonIcon: ButtonIcon(icon: CustomImages.iconSms),
        hintText: passwordHint,
      ),
      const SizedBox(height: 32),
      CustomElevatedButton(text: buttonText, onPressed: onPressed),
    ],
  );
}

class _CartPriceContent extends StatelessWidget {
  const _CartPriceContent({
    required this.subtotalLabel,
    required this.subtotalValue,
    required this.shippingLabel,
    required this.shippingValue,
    required this.totalLabel,
    required this.totalValue,
    required this.checkoutText,
    required this.onCheckout,
  });
  final String subtotalLabel;
  final String subtotalValue;
  final String shippingLabel;
  final String shippingValue;
  final String totalLabel;
  final String totalValue;
  final String checkoutText;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _PriceTile(title: subtotalLabel, value: subtotalValue),
      const SizedBox(height: 8),
      _PriceTile(title: shippingLabel, value: shippingValue),
      const SizedBox(height: 8),
      const DashLine(),
      const SizedBox(height: 8),
      _PriceTile(title: totalLabel, value: totalValue),
      const SizedBox(height: 32),
      CustomElevatedButton(text: checkoutText, onPressed: onCheckout),
    ],
  );
}

class _PriceTile extends StatelessWidget {
  const _PriceTile({required this.title, required this.value});
  final String title, value;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: context.textTheme.labelSm.copyWith(
          color: CustomAppColors.black03,
        ),
      ),
      Text(Utils.rupeesSymbolString(value), style: context.textTheme.titleBase),
    ],
  );
}

class _PromoCodeContent extends StatelessWidget {
  const _PromoCodeContent();

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return ListView.builder(
      itemCount: 3,
      itemBuilder:
          (context, index) => ListTile(
            leading: SvgPicture.asset(
              CustomImages.iconDiscount,
              colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
            ),
            trailing: SvgPicture.asset(
              CustomImages.iconTick,
              colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
            ),
            title: Text(
              context.translate(
                'checkout_promo_cashback',
                params: {'percentage': '35'},
              ),
              style: context.textTheme.titleSm,
            ),
            subtitle: Text(
              context.translate(
                'checkout_promo_expired_in',
                params: {'days': '2'},
              ),
              style: context.textTheme.bodyXs.copyWith(
                color: CustomAppColors.grey01,
              ),
            ),
          ),
    );
  }
}
