import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:churchsnap/core/navigation/churchsnap_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/widgets/churchsnap_screen.dart';
import '../../features/home/providers/home_appearance_provider.dart';

class AdminHomeAppearanceScreen extends ConsumerStatefulWidget {
  const AdminHomeAppearanceScreen({super.key, required this.churchId});

  final String churchId;

  @override
  ConsumerState<AdminHomeAppearanceScreen> createState() =>
      _AdminHomeAppearanceScreenState();
}

class _AdminHomeAppearanceScreenState
    extends ConsumerState<AdminHomeAppearanceScreen> {
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
          .doc('homeAppearance');

  Future<void> _pickImage() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 88,
        maxWidth: 2400,
      );

      if (file == null) {
        return;
      }

      final bytes = await file.readAsBytes();

      if (bytes.length > _maximumImageBytes) {
        if (!mounted) {
          return;
        }

        _showMessage(
          'The selected picture is larger than 5 MB. '
          'Choose a smaller picture.',
        );
        return;
      }

      final format = _resolveImageFormat(file);

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedBytes = bytes;
        _selectedExtension = format.extension;
        _selectedContentType = format.contentType;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage('Unable to select the picture: $error');
    }
  }

  _ImageFormat _resolveImageFormat(XFile file) {
    final mimeType = (file.mimeType ?? '').toLowerCase();
    final fileName = file.name.toLowerCase();

    if (mimeType.contains('png') || fileName.endsWith('.png')) {
      return const _ImageFormat('png', 'image/png');
    }

    if (mimeType.contains('webp') || fileName.endsWith('.webp')) {
      return const _ImageFormat('webp', 'image/webp');
    }

    if (mimeType.contains('heic') || fileName.endsWith('.heic')) {
      return const _ImageFormat('heic', 'image/heic');
    }

    if (mimeType.contains('heif') || fileName.endsWith('.heif')) {
      return const _ImageFormat('heif', 'image/heif');
    }

    return const _ImageFormat('jpg', 'image/jpeg');
  }

  Future<void> _uploadImage() async {
    final bytes = _selectedBytes;

    if (bytes == null || _busy) {
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      final currentSnapshot = await _settingsReference.get();
      final oldStoragePath =
          (currentSnapshot.data()?['storagePath'] as String? ?? '').trim();

      final storageReference = FirebaseStorage.instance.ref(
        'churches/${widget.churchId}/home/'
        'welcome_background.$_selectedExtension',
      );

      await storageReference.putData(
        bytes,
        SettableMetadata(
          contentType: _selectedContentType,
          cacheControl: 'public,max-age=3600',
        ),
      );

      final downloadUrl = await storageReference.getDownloadURL();

      await _settingsReference.set(<String, dynamic>{
        'backgroundImageUrl': downloadUrl,
        'storagePath': storageReference.fullPath,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (oldStoragePath.isNotEmpty &&
          oldStoragePath != storageReference.fullPath) {
        try {
          await FirebaseStorage.instance.ref(oldStoragePath).delete();
        } on FirebaseException catch (_) {
          // The new image is already active. A missing old file is harmless.
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedBytes = null;
      });

      _showMessage('Home welcome picture updated successfully.');
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage('Unable to update the home welcome picture: $error');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _restoreDefault(HomeAppearanceSettings settings) async {
    if (_busy) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Restore default picture?'),
          content: const Text(
            'The bundled ChurchSnap welcome picture will be shown again.',
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

      if (settings.storagePath.trim().isNotEmpty) {
        try {
          await FirebaseStorage.instance.ref(settings.storagePath).delete();
        } on FirebaseException catch (_) {
          // The Firestore setting is gone, so the bundled fallback still works.
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedBytes = null;
      });

      _showMessage('The default ChurchSnap welcome picture was restored.');
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage('Unable to restore the default picture: $error');
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
      'assets/home/home_hero_church.jpg',
      fit: BoxFit.cover,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
    );
  }

  Widget _buildPreview(HomeAppearanceSettings settings) {
    final selectedBytes = _selectedBytes;

    if (selectedBytes != null) {
      return Image.memory(
        selectedBytes,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
      );
    }

    final imageUrl = settings.backgroundImageUrl.trim();

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
    final settingsAsync = ref.watch(homeAppearanceProvider(widget.churchId));

    final settings = settingsAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const HomeAppearanceSettings(),
    );

    return ChurchSnapScreen(
      title: 'Home Welcome Picture',
      subtitle: 'Customize the picture displayed in the home welcome card.',
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildPreview(settings),

                const Positioned(
                  left: 18,
                  bottom: 18,
                  child: Text(
                    'WELCOME',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
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
              ? 'New picture selected. Upload it to publish the change.'
              : settings.usesDefaultImage
              ? 'The bundled ChurchSnap picture is currently active.'
              : 'A custom church picture is currently active.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: _busy ? null : _pickImage,
          icon: const Icon(Icons.photo_library_rounded),
          label: Text(
            settings.usesDefaultImage
                ? 'Choose Welcome Picture'
                : 'Choose Replacement Picture',
          ),
        ),
        if (_selectedBytes != null) ...[
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _busy ? null : _uploadImage,
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
                    'Use a wide landscape picture. ChurchSnap keeps a dark '
                    'overlay over the left side so the welcome text remains '
                    'readable. The maximum upload size is 5 MB.',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageFormat {
  const _ImageFormat(this.extension, this.contentType);

  final String extension;
  final String contentType;
}
