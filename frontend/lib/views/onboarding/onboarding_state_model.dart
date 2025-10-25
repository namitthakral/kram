class OnboardingStateModel {
  const OnboardingStateModel({
    required this.index,
    required this.title,
    required this.subtitle,
  });
  final int index;
  final String title, subtitle;

  @override
  String toString() =>
      'OnboardingStateModel(index: $index, title: $title, subtitle: $subtitle)';
}
