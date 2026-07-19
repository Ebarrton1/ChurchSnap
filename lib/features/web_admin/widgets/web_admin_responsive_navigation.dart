import 'package:flutter/material.dart';

class WebAdminResponsiveNavigation extends StatelessWidget {
  const WebAdminResponsiveNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.compactBreakpoint = 760,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<Widget> destinations;
  final double compactBreakpoint;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= compactBreakpoint) {
      return NavigationBar(
        key: const ValueKey('standard-dashboard-navigation'),
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations,
      );
    }

    final destination = _destinationAt(selectedIndex);
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Material(
        key: const ValueKey('compact-dashboard-navigation'),
        elevation: 8,
        color: colorScheme.surfaceContainer,
        child: SizedBox(
          height: 72,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  child: IconTheme(
                    data: IconThemeData(color: colorScheme.onPrimaryContainer),
                    child: destination.selectedIcon ?? destination.icon,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    destination.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<int>(
                  tooltip: 'Choose dashboard section',
                  onSelected: onDestinationSelected,
                  itemBuilder: (context) {
                    return List<PopupMenuEntry<int>>.generate(
                      destinations.length,
                      (index) {
                        final item = _destinationAt(index);
                        final selected = index == selectedIndex;
                        final icon = selected
                            ? item.selectedIcon ?? item.icon
                            : item.icon;

                        return PopupMenuItem<int>(
                          value: index,
                          child: Row(
                            children: [
                              IconTheme(
                                data: IconThemeData(
                                  color: selected
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                ),
                                child: icon,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.label,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (selected) ...[
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.check_rounded,
                                  color: colorScheme.primary,
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.menu_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  NavigationDestination _destinationAt(int index) {
    final widget = destinations[index];

    if (widget is! NavigationDestination) {
      throw StateError(
        'WebAdminResponsiveNavigation requires NavigationDestination widgets.',
      );
    }

    return widget;
  }
}
