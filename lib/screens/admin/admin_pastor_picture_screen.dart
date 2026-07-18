import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:churchsnap/core/navigation/churchsnap_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/home/providers/pastor_appearance_provider.dart';

class AdminPastorPictureScreen extends ConsumerStatefulWidget {
  const AdminPastorPictureScreen({super.key, required this.churchId});

  final String churchId;

  @override
  ConsumerState<AdminPastorPictureScreen> createState() =>
      _AdminPastorPictureScreenState();
}

class _AdminPastorPictureScreenState
    extends ConsumerState<AdminPastorPictureScreen> {
  static const int _maximumImageBytes = 5 * 1024 * 1024;

  final ImagePicker _picker = ImagePicker();

  Uint8List? _selectedBytes;
  String _selectedExtension = 'jpg';
  String _selectedContentType = 'image/jpeg';
  bool _busy = false;

  DocumentReference<Map<String, dynamic>> get _settingsReference =>
      FirebaseFirestore.instance
          .collection('churches')
          .doc(widget.churchId)
          .collection('settings')
          .doc('pastorAppearance');

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recoverLostImage();
    });
  }

  Future<void> _recoverLostImage() async {
    final response = await _picker.retrieveLostData();

    if (response.isEmpty || !mounted) {
      return;
    }

    final files = response.files;

    if (files == null || files.isEmpty) {
      return;
    }

    await _loadSelectedFile(files.first);
  }

  Future<void> _pickImage() async {
    if (_busy) {
      return;
    }

    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
      maxWidth: 1800,
    );

    if (file == null || !mounted) {
      return;
    }

    await _loadSelectedFile(file);
  }

  Future<void> _loadSelectedFile(XFile file) async {
    final bytes = await file.readAsBytes();

    if (!mounted) {
      return;
    }

    if (bytes.length > _maximumImageBytes) {
      _showMessage('Choose an image smaller than 5 MB.');
      return;
    }

    final format = _formatForName(file.name);

    if (format == null) {
      _showMessage('Use a JPG, JPEG, PNG, WEBP, or HEIC image.');
      return;
    }

    setState(() {
      _selectedBytes = bytes;
      _selectedExtension = format.extension;
      _selectedContentType = format.contentType;
    });
  }

  Future<void> _uploadImage(PastorAppearanceSettings currentSettings) async {
    final bytes = _selectedBytes;

    if (_busy || bytes == null) {
      return;
    }

    setState(() {
      _busy = true;
    });

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storagePath =
        'churches/${widget.churchId}/home/'
        'pastor_service_$timestamp.$_selectedExtension';

    try {
      final storageReference = FirebaseStorage.instance.ref().child(
        storagePath,
      );

      await storageReference.putData(
        bytes,
        SettableMetadata(contentType: _selectedContentType),
      );

      final imageUrl = await storageReference.getDownloadURL();

      await _settingsReference.set({
        'imageUrl': imageUrl,
        'storagePath': storagePath,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final oldStoragePath = currentSettings.storagePath.trim();

      if (oldStoragePath.isNotEmpty && oldStoragePath != storagePath) {
        try {
          await FirebaseStorage.instance.ref(oldStoragePath).delete();
        } on FirebaseException catch (_) {
          // The new picture is already published; stale-file cleanup is best effort.
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedBytes = null;
      });

      _showMessage('The pastor picture was published.');
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage('Unable to publish the pastor picture: $error');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _restoreDefault(PastorAppearanceSettings settings) async {
    if (_busy) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Restore default pastor picture?'),
          content: const Text(
            'The bundled ChurchSnap pastor picture will be displayed again.',
          ),
          actions: [
            TextButton(
              onPressed: () => ChurchSnapNavigation.closeAllWindows(
                dialogContext,
                result: false,
              ),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => ChurchSnapNavigation.closeAllWindows(
                dialogContext,
                result: true,
              ),
              child: const Text('Restore'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      await _settingsReference.delete();

      final storagePath = settings.storagePath.trim();

      if (storagePath.isNotEmpty) {
        try {
          await FirebaseStorage.instance.ref(storagePath).delete();
        } on FirebaseException catch (_) {
          // Firestore already points the app back to the bundled fallback.
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedBytes = null;
      });

      _showMessage('The default pastor picture was restored.');
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage('Unable to restore the default pastor picture: $error');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _defaultImage() {
    return Image.asset(
      'assets/home/home_service_pastor.jpg',
      fit: BoxFit.cover,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
    );
  }

  Widget _buildPreview(PastorAppearanceSettings settings) {
    final selectedBytes = _selectedBytes;

    if (selectedBytes != null) {
      return Image.memory(
        selectedBytes,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
      );
    }

    final imageUrl = settings.imageUrl.trim();

    if (imageUrl.isEmpty) {
      return _defaultImage();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }

        return _defaultImage();
      },
      errorBuilder: (_, _, _) => _defaultImage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(pastorAppearanceProvider(widget.churchId));

    final settings = settingsAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const PastorAppearanceSettings(),
    );

    return ChurchSnapScreen(
      title: 'Pastor Picture',
      subtitle: 'Customize the picture shown in Today\u2019s Service.',
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildPreview(settings),
                const Positioned(
                  left: 14,
                  bottom: 14,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xA6000000),
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      child: Text(
                        'TODAY\u2019S SERVICE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_busy)
                  const ColoredBox(
                    color: Color(0x66000000),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          _selectedBytes != null
              ? 'New pastor picture selected. Publish it to update the home screen.'
              : settings.usesDefaultImage
              ? 'The bundled ChurchSnap pastor picture is currently active.'
              : 'A custom pastor picture is currently active.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: _busy ? null : _pickImage,
          icon: const Icon(Icons.photo_library_rounded),
          label: Text(
            settings.usesDefaultImage
                ? 'Choose Pastor Picture'
                : 'Choose Replacement Picture',
          ),
        ),
        if (_selectedBytes != null) ...[
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _busy ? null : () => _uploadImage(settings),
            icon: const Icon(Icons.cloud_upload_rounded),
            label: const Text('Upload and Publish'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _busy
                ? null
                : () {
                    setState(() {
                      _selectedBytes = null;
                    });
                  },
            icon: const Icon(Icons.close_rounded),
            label: const Text('Cancel Selected Picture'),
          ),
        ],
        if (!settings.usesDefaultImage) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _busy ? null : () => _restoreDefault(settings),
            icon: const Icon(Icons.restore_rounded),
            label: const Text('Restore Default Picture'),
          ),
        ],
        const SizedBox(height: 18),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Use a clear portrait or preaching picture. ChurchSnap '
                    'crops the image to fill the right half of Today\u2019s Service. '
                    'The maximum upload size is 5 MB.',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _ImageFormat? _formatForName(String name) {
    final normalized = name.toLowerCase();

    if (normalized.endsWith('.jpg') || normalized.endsWith('.jpeg')) {
      return const _ImageFormat('jpg', 'image/jpeg');
    }

    if (normalized.endsWith('.png')) {
      return const _ImageFormat('png', 'image/png');
    }

    if (normalized.endsWith('.webp')) {
      return const _ImageFormat('webp', 'image/webp');
    }

    if (normalized.endsWith('.heic') || normalized.endsWith('.heif')) {
      return const _ImageFormat('heic', 'image/heic');
    }

    return null;
  }
}

class _ImageFormat {
  const _ImageFormat(this.extension, this.contentType);

  final String extension;
  final String contentType;
}
