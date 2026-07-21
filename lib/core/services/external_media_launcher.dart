import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ExternalMediaLauncher {
  const ExternalMediaLauncher._();

  static Future<void> open(
    BuildContext context, {
    required String rawUrl,
    required String contentLabel,
  }) async {
    final uri = _normalizeUrl(rawUrl);

    if (uri == null) {
      _showMessage(
        context,
        'A valid web address is required for $contentLabel.',
      );
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
        webOnlyWindowName: '_blank',
      );

      if (!launched && context.mounted) {
        _showMessage(context, 'Unable to open $contentLabel.');
      }
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      _showMessage(context, 'Unable to open $contentLabel: $error');
    }
  }

  static Uri? _normalizeUrl(String rawUrl) {
    final value = rawUrl.trim();

    if (value.isEmpty) {
      return null;
    }

    final candidate = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://').hasMatch(value)
        ? value
        : 'https://$value';
    final uri = Uri.tryParse(candidate);

    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return null;
    }

    return uri;
  }

  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
