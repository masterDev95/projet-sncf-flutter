import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.tabController,
    required this.currentPageIndex,
    required this.onUpdateCurrentPageIndex,
    required this.tabCount,
    required this.tabTitles,
  });

  final TabController tabController;
  final int currentPageIndex;
  final Function(int) onUpdateCurrentPageIndex;
  final int tabCount;
  final List<String> tabTitles;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          tabTitles[currentPageIndex],
          style: Theme.of(context).textTheme.labelLarge,
        ),
        Row(
          children: [
            IconButton(
              splashRadius: 16.0,
              padding: EdgeInsets.zero,
              onPressed: () {
                if (currentPageIndex == 0) {
                  return;
                }
                onUpdateCurrentPageIndex(currentPageIndex - 1);
              },
              icon: const Icon(
                Icons.arrow_left_rounded,
                size: 32.0,
              ),
            ),
            TabPageSelector(
              controller: tabController,
              color: colorScheme.surface,
              selectedColor: colorScheme.primary,
            ),
            IconButton(
              splashRadius: 16.0,
              padding: EdgeInsets.zero,
              onPressed: () {
                if (currentPageIndex == tabCount - 1) {
                  return;
                }
                onUpdateCurrentPageIndex(currentPageIndex + 1);
              },
              icon: const Icon(
                Icons.arrow_right_rounded,
                size: 32.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
