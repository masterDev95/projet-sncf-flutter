extension StringExtension on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String splitCamelCase() {
    return replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim();
  }

  String firstWordInCaps() {
    return "${split(' ')[0].toUpperCase()} ${split(' ').sublist(1).join(' ')}";
  }

  String stylizeCab() {
    return splitCamelCase().firstWordInCaps();
  }
}
