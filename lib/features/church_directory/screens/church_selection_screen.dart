import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../auth/state/auth_controller.dart';
import '../models/church_directory_entry.dart';
import '../repositories/church_directory_repository.dart';

class ChurchSelectionScreen extends StatefulWidget {
  const ChurchSelectionScreen({
    super.key,
    required this.authController,
    this.selectionOnly = false,
  });

  final AuthController authController;
  final bool selectionOnly;

  @override
  State<ChurchSelectionScreen> createState() => _ChurchSelectionScreenState();
}

class _ChurchSelectionScreenState extends State<ChurchSelectionScreen> {
  final ChurchDirectoryRepository _repository = ChurchDirectoryRepository();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  bool _resolving = false;

  @override
  void dispose() {
    _searchController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.selectionOnly
        ? 'Choose Your Church'
        : 'Visit a Church';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Search by church name or location',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          TextField(
                            controller: _codeController,
                            textCapitalization: TextCapitalization.characters,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _connectWithCode(),
                            decoration: InputDecoration(
                              labelText: 'Church connection code',
                              prefixIcon: const Icon(Icons.key_rounded),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: _resolving
                                      ? null
                                      : _connectWithCode,
                                  icon: const Icon(Icons.link_rounded),
                                  label: const Text('Connect'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _resolving ? null : _scanCode,
                                  icon: const Icon(
                                    Icons.qr_code_scanner_rounded,
                                  ),
                                  label: const Text('Scan QR'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<ChurchDirectoryEntry>>(
                stream: _repository.watchPublicChurches(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _MessageState(
                      icon: Icons.cloud_off_rounded,
                      title: 'Unable to load churches',
                      message: '${snapshot.error}',
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final query = _searchController.text.trim().toLowerCase();

                  final churches = snapshot.data!
                      .where(
                        (church) =>
                            query.isEmpty ||
                            church.searchableText.contains(query),
                      )
                      .toList();

                  if (churches.isEmpty) {
                    return const _MessageState(
                      icon: Icons.church_outlined,
                      title: 'No matching churches',
                      message:
                          'Try another search, enter the church connection '
                          'code, or scan its ChurchSnap QR code.',
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                    itemCount: churches.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final church = churches[index];

                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: _ChurchLogo(church: church),
                          title: Text(
                            church.name,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          subtitle: Text(
                            church.displayAddress.isEmpty
                                ? 'ChurchSnap church'
                                : church.displayAddress,
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: _resolving
                              ? null
                              : () => _finishSelection(church),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _connectWithCode() async {
    await _resolveConnection(_codeController.text);
  }

  Future<void> _scanCode() async {
    final value = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const _ChurchConnectionScannerScreen()),
    );

    if (!mounted || value == null || value.trim().isEmpty) {
      return;
    }

    await _resolveConnection(value);
  }

  Future<void> _resolveConnection(String value) async {
    if (value.trim().isEmpty || _resolving) {
      _showMessage('Enter a church code or scan a ChurchSnap QR code.');
      return;
    }

    setState(() {
      _resolving = true;
    });

    try {
      final church = await _repository.resolveConnection(value);

      if (!mounted) {
        return;
      }

      if (church == null) {
        _showMessage('No active ChurchSnap church matched that code.');
        return;
      }

      await _finishSelection(church);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage('Unable to connect to that church: $error');
    } finally {
      if (mounted) {
        setState(() {
          _resolving = false;
        });
      }
    }
  }

  Future<void> _finishSelection(ChurchDirectoryEntry church) async {
    if (widget.selectionOnly) {
      Navigator.of(context).pop(church);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.church_rounded, size: 42),
          title: Text(church.name),
          content: Text(
            church.displayAddress.isEmpty
                ? 'Connect to this church as a visitor?'
                : '${church.displayAddress}\n\n'
                      'Connect to this church as a visitor?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Connect'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _resolving = true;
    });

    final connected = await widget.authController.continueAsVisitor(
      churchId: church.id,
    );

    if (!mounted) {
      return;
    }

    if (!connected) {
      setState(() {
        _resolving = false;
      });

      _showMessage(
        widget.authController.errorMessage ?? 'Unable to start visitor access.',
      );
      return;
    }

    Navigator.of(context).pop();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ChurchLogo extends StatelessWidget {
  const _ChurchLogo({required this.church});

  final ChurchDirectoryEntry church;

  @override
  Widget build(BuildContext context) {
    final logoUrl = church.logoUrl.trim();

    return CircleAvatar(
      radius: 25,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      foregroundImage: logoUrl.isEmpty ? null : NetworkImage(logoUrl),
      child: logoUrl.isEmpty ? const Icon(Icons.church_rounded) : null,
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChurchConnectionScannerScreen extends StatefulWidget {
  const _ChurchConnectionScannerScreen();

  @override
  State<_ChurchConnectionScannerScreen> createState() =>
      _ChurchConnectionScannerScreenState();
}

class _ChurchConnectionScannerScreenState
    extends State<_ChurchConnectionScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );

  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled) {
      return;
    }

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue?.trim() ?? '';

      if (rawValue.isEmpty) {
        continue;
      }

      _handled = true;
      await _controller.stop();

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(rawValue);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Church QR Code'),
        actions: [
          IconButton(
            tooltip: 'Toggle flashlight',
            onPressed: () {
              _controller.toggleTorch();
            },
            icon: const Icon(Icons.flashlight_on_rounded),
          ),
          IconButton(
            tooltip: 'Switch camera',
            onPressed: () {
              _controller.switchCamera();
            },
            icon: const Icon(Icons.cameraswitch_rounded),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 4),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          const Positioned(
            left: 24,
            right: 24,
            bottom: 42,
            child: Text(
              'Point the camera at the ChurchSnap connection QR code.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
