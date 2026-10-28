import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/profile.dart';
import '../providers/profile_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({this.embedded = false, this.onSaved, super.key});

  /// True when shown as a tab: no back button, and saving calls [onSaved].
  final bool embedded;

  /// Called after the profile is saved while shown as a tab.
  final VoidCallback? onSaved;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  String? _photoBase64;
  bool _filledFromSaved = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _mobileController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The saved profile loads asynchronously, and this screen can be built
    // before it arrives, so fill the form once it is ready (only once, so
    // later edits are never overwritten).
    final provider = context.watch<ProfileProvider>();
    if (_filledFromSaved || !provider.isLoaded) return;
    _filledFromSaved = true;
    final profile = provider.profile;
    _nameController.text = profile.name;
    _mobileController.text = profile.mobile;
    _emailController.text = profile.email;
    _photoBase64 = profile.photoBase64;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            if (_photoBase64 != null)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: const Text('Remove photo'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _setPhoto(null);
                },
              ),
          ],
        ),
      ),
    );
    if (source == null) return;

    try {
      // Downscaled so the stored picture stays small.
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      await _setPhoto(base64Encode(bytes));
    } catch (error, stack) {
      debugPrint('Photo pick failed: $error\n$stack');
      if (!mounted) return;
      final isCamera = source == ImageSource.camera;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCamera
                ? 'Could not open the camera. Check the camera permission.'
                : 'Could not load that photo. Please try another one.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Shows the photo and saves it to the profile straight away, so it is kept
  /// even if the form itself is never saved.
  Future<void> _setPhoto(String? photoBase64) async {
    setState(() => _photoBase64 = photoBase64);
    final provider = context.read<ProfileProvider>();
    final saved = provider.profile;
    await provider.update(
      Profile(
        name: saved.name,
        mobile: saved.mobile,
        email: saved.email,
        photoBase64: photoBase64,
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<ProfileProvider>().update(
      Profile(
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
        email: _emailController.text.trim(),
        photoBase64: _photoBase64,
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    if (widget.embedded) {
      widget.onSaved?.call();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final photo = _photoBase64 == null ? null : base64Decode(_photoBase64!);
    final name = _nameController.text.trim();
    return Scaffold(
      backgroundColor: context.colors.card,
      appBar: AppBar(
        backgroundColor: context.colors.card,
        automaticallyImplyLeading: false,
        leading: widget.embedded
            ? null
            : IconButton(
                onPressed: () => Navigator.pop(context),
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back_rounded),
              ),
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: _PhotoPicker(
                    photo: photo,
                    initial: name.isEmpty ? '?' : name[0].toUpperCase(),
                    onTap: _pickPhoto,
                  ),
                ),
                const SizedBox(height: 28),
                const _Label('User Name', required: true),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  maxLength: 40,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(hintText: 'Your name'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter your name'
                      : null,
                ),
                const SizedBox(height: 16),
                const _Label('Mobile number'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: '+94 77 123 4567',
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return null;
                    final digits = text.replaceAll(RegExp(r'[\s\-()]'), '');
                    return RegExp(r'^\+?\d{7,15}$').hasMatch(digits)
                        ? null
                        : 'Enter a valid mobile number';
                  },
                ),
                const SizedBox(height: 24),
                const _Label('Email'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: 'name@example.com',
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return null;
                    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)
                        ? null
                        : 'Enter a valid email address';
                  },
                ),
                const SizedBox(height: 16),
                const _Label('Appearance'),
                const SizedBox(height: 8),
                const _AppearancePicker(),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: context.colors.accent,
                      foregroundColor: context.colors.onAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Profile',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
    required this.photo,
    required this.initial,
    required this.onTap,
  });

  final Uint8List? photo;
  final String initial;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Change profile picture',
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 56,
              backgroundColor: context.colors.accent,
              backgroundImage: photo == null ? null : MemoryImage(photo!),
              child: photo == null
                  ? Text(
                      initial,
                      style: TextStyle(
                        color: context.colors.onAccent,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colors.card, width: 3),
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: context.colors.onAccent,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.label, {this.required = false});

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.colors.text,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (required)
          Text(
            ' *',
            style: TextStyle(
              color: context.colors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

/// Lets the user follow the device theme or force light or dark.
class _AppearancePicker extends StatelessWidget {
  const _AppearancePicker();

  static const _options = [
    (ThemeMode.system, 'System', Icons.brightness_auto_rounded),
    (ThemeMode.light, 'Light', Icons.light_mode_outlined),
    (ThemeMode.dark, 'Dark', Icons.dark_mode_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.border,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          for (final (mode, label, icon) in _options)
            Expanded(
              child: Semantics(
                button: true,
                selected: provider.mode == mode,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => provider.setMode(mode),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 44,
                    decoration: BoxDecoration(
                      color: provider.mode == mode
                          ? colors.accent
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 18,
                          color: provider.mode == mode
                              ? colors.onAccent
                              : colors.muted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: TextStyle(
                            color: provider.mode == mode
                                ? colors.onAccent
                                : colors.muted,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
