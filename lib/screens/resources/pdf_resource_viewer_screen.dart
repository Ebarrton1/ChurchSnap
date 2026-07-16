import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/resources/models/church_resource.dart';

class PdfResourceViewerScreen extends StatelessWidget {
  const PdfResourceViewerScreen({super.key, required this.resource});

  final ChurchResource resource;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(resource.openUrl);

    if (uri == null) {
      return Scaffold(
        appBar: AppBar(title: Text(resource.title)),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'This PDF does not have a valid address.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(resource.title, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Open externally',
            onPressed: () => _openExternally(context, uri),
            icon: const Icon(Icons.open_in_new_rounded),
          ),
        ],
      ),
      body: PdfViewer.uri(uri),
    );
  }

  Future<void> _openExternally(BuildContext context, Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No external app was available to open this PDF.'),
        ),
      );
    }
  }
}
