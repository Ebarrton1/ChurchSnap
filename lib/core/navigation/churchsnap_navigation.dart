import 'package:flutter/material.dart';

class ChurchSnapNavigation {
  const ChurchSnapNavigation._();

  /// Closes the current route and then dismisses any remaining dialogs,
  /// popup menus, or modal bottom sheets stacked above the underlying page.
  ///
  /// The underlying ChurchSnap page remains open. A result can still be
  /// returned to the code that opened the current dialog or sheet.
  static void closeAllWindows<T>(BuildContext context, {T? result}) {
    final navigator = Navigator.of(context);

    if (!navigator.canPop()) {
      return;
    }

    navigator.pop<T>(result);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!navigator.mounted) {
        return;
      }

      navigator.popUntil((route) => route is! PopupRoute<dynamic>);
    });
  }
}
