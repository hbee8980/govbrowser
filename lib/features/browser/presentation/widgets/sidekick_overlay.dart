import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:file_picker/file_picker.dart';
import '../../../vault/providers/vault_provider.dart';
import '../../../../core/utils/clipboard_utils.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../subscription/providers/subscription_provider.dart';

/// The Antigravity Sidekick Overlay
/// A draggable FAB that expands into a helpful panel
class SidekickOverlay extends ConsumerStatefulWidget {
  const SidekickOverlay({super.key});

  @override
  ConsumerState<SidekickOverlay> createState() => _SidekickOverlayState();
}

class _SidekickOverlayState extends ConsumerState<SidekickOverlay>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  Offset _fabPosition = const Offset(20, 100);
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Expanded Panel (bottom sheet style)
        if (_isExpanded)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ScaleTransition(
              scale: _scaleAnimation,
              alignment: Alignment.bottomCenter,
              child: _SidekickPanel(onClose: _toggleExpanded),
            ),
          ),

        // Draggable FAB
        if (!_isExpanded)
          Positioned(
            left: _fabPosition.dx,
            top: _fabPosition.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _fabPosition = Offset(
                    (_fabPosition.dx + details.delta.dx).clamp(
                      0,
                      screenSize.width - 56,
                    ),
                    (_fabPosition.dy + details.delta.dy).clamp(
                      0,
                      screenSize.height - 200,
                    ),
                  );
                });
              },
              child: _SidekickFab(onTap: _toggleExpanded),
            ),
          ),
      ],
    );
  }
}

/// The floating action button for the sidekick
class _SidekickFab extends StatelessWidget {
  final VoidCallback onTap;

  const _SidekickFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(28),
      color: AppTheme.overlayFab,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.overlayFab,
                AppTheme.overlayFab.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Icon(
            PhosphorIcons.rocketLaunch(PhosphorIconsStyle.fill),
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}

/// The expanded panel with tabs
class _SidekickPanel extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const _SidekickPanel({required this.onClose});

  @override
  ConsumerState<_SidekickPanel> createState() => _SidekickPanelState();
}

class _SidekickPanelState extends ConsumerState<_SidekickPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.45,
      decoration: BoxDecoration(
        color: AppTheme.overlayBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar and close button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Handle bar
                Expanded(
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white38,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                // Close button
                IconButton(
                  icon: Icon(PhosphorIcons.x(), color: Colors.white70),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),

          // Tab bar
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(icon: Icon(PhosphorIcons.textT(), size: 20), text: 'Text'),
              Tab(icon: Icon(PhosphorIcons.images(), size: 20), text: 'Assets'),
              Tab(
                icon: Icon(PhosphorIcons.magicWand(), size: 20),
                text: 'Tools',
              ),
            ],
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _TextFieldsTab(
                  searchQuery: _searchQuery,
                  onSearchChanged: (q) => setState(() => _searchQuery = q),
                ),
                const _AssetsTab(),
                const _ToolsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab 1: Text fields for copy-paste
class _TextFieldsTab extends ConsumerWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  const _TextFieldsTab({
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fields = ref.watch(searchableFieldsProvider(searchQuery));

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: onSearchChanged,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search fields...',
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: Icon(
                PhosphorIcons.magnifyingGlass(),
                color: Colors.white54,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),

        // Fields list
        Expanded(
          child:
              fields.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          PhosphorIcons.userCirclePlus(),
                          size: 48,
                          color: Colors.white38,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No profile data yet',
                          style: TextStyle(color: Colors.white54),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Add your details in the Vault',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: fields.length,
                    itemBuilder: (context, index) {
                      final entry = fields.entries.elementAt(index);
                      return _FieldTile(label: entry.key, value: entry.value);
                    },
                  ),
        ),
      ],
    );
  }
}

/// Single field tile for copying
class _FieldTile extends StatelessWidget {
  final String label;
  final String value;

  const _FieldTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withValues(alpha: 0.1),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(PhosphorIcons.copy(), color: Colors.white54, size: 20),
        onTap: () {
          ClipboardUtils.copyWithToast(value, label: label);
        },
      ),
    );
  }
}

/// Tab 2: Asset thumbnails
class _AssetsTab extends ConsumerWidget {
  const _AssetsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assets = ref.watch(availableAssetsProvider);

    if (assets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIcons.imageBroken(), size: 48, color: Colors.white38),
            const SizedBox(height: 12),
            const Text(
              'No assets added',
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 4),
            const Text(
              'Add Photo, Signature, etc. in the Vault',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final entry = assets.entries.elementAt(index);
        return _AssetTile(label: entry.key, path: entry.value);
      },
    );
  }
}

/// Single asset tile
class _AssetTile extends StatelessWidget {
  final String label;
  final String path;

  const _AssetTile({required this.label, required this.path});

  @override
  Widget build(BuildContext context) {
    final bool exists = !kIsWeb && File(path).existsSync();

    return Card(
      color: Colors.white.withValues(alpha: 0.1),
      child: InkWell(
        onTap: () => _showAssetOptions(context),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                child:
                    exists && !kIsWeb
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(path),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholderIcon(),
                          ),
                        )
                        : _placeholderIcon(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 11),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderIcon() {
    return Center(
      child: Icon(PhosphorIcons.image(), color: Colors.white38, size: 32),
    );
  }

  void _showAssetOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.overlayBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(PhosphorIcons.copy(), color: Colors.white),
                  title: const Text(
                    'Copy Path',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    ClipboardUtils.copyWithToast(path, label: '$label path');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(
                    PhosphorIcons.folderOpen(),
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Open Location',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    // TODO: Open file location
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }
}

/// Tab 3: Tools (Image Resizer)
class _ToolsTab extends ConsumerStatefulWidget {
  const _ToolsTab();

  @override
  ConsumerState<_ToolsTab> createState() => _ToolsTabState();
}

class _ToolsTabState extends ConsumerState<_ToolsTab> {
  File? _selectedFile;
  String? _selectedFileName;
  int? _selectedFileSize;
  int _targetKB = 50;
  bool _isCompressing = false;
  File? _compressedFile;
  String? _error;

  // ... (keeping existing methods _pickImage, _compressImage) ...
  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _selectedFileName = file.name;
          _selectedFileSize = file.size;
          if (!kIsWeb && file.path != null) {
            _selectedFile = File(file.path!);
          }
          _compressedFile = null;
          _error = null;
        });
      }
    } catch (e) {
      setState(() => _error = 'Failed to pick file');
    }
  }

  Future<void> _compressImage() async {
    if (_selectedFile == null && kIsWeb) {
      setState(() => _error = 'Image compression not available on web');
      return;
    }

    if (_selectedFile == null) return;

    setState(() {
      _isCompressing = true;
      _error = null;
      _compressedFile = null;
    });

    try {
      final result = await ImageUtils.compressToTargetSize(
        _selectedFile!,
        targetKB: _targetKB,
      );

      setState(() {
        _compressedFile = result;
        _isCompressing = false;
        if (result == null) {
          _error = 'Could not compress to target size';
        }
      });
    } catch (e) {
      setState(() {
        _isCompressing = false;
        _error = 'Compression failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(subscriptionProvider);

    // Lock for Free Users
    if (!subscription.isPro) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.lockKey(),
                size: 32,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pro Feature Locked',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Resize images to specific KBs for\ngovernment forms instantly.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Mock Upgrade
                ref.read(subscriptionProvider.notifier).upgradeToPro();
              },
              icon: Icon(PhosphorIcons.crown()),
              label: const Text('Upgrade for ₹29/mo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Row(
            children: [
              Icon(PhosphorIcons.fileImage(), color: Colors.white, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Image Resizer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Select image button
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: Icon(PhosphorIcons.uploadSimple()),
            label: const Text('Select Image'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 12),

          // Selected file info
          if (_selectedFileName != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIcons.file(), color: Colors.white54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedFileName!,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_selectedFileSize != null)
                          Text(
                            'Size: ${ImageUtils.formatFileSize(_selectedFileSize!)}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Target size slider
            Text(
              'Target Size: $_targetKB KB',
              style: const TextStyle(color: Colors.white70),
            ),
            Slider(
              value: _targetKB.toDouble(),
              min: 10,
              max: 200,
              divisions: 19,
              activeColor: AppTheme.overlayFab,
              inactiveColor: Colors.white24,
              label: '$_targetKB KB',
              onChanged: (value) {
                setState(() => _targetKB = value.round());
              },
            ),
            const SizedBox(height: 12),

            // Compress button
            ElevatedButton.icon(
              onPressed: _isCompressing ? null : _compressImage,
              icon:
                  _isCompressing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : Icon(PhosphorIcons.magicWand()),
              label: Text(_isCompressing ? 'Compressing...' : 'Compress'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],

          // Error message
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.urgentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIcons.warning(), color: AppTheme.urgentColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Success result
          if (_compressedFile != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.checkCircle(),
                        color: AppTheme.successColor,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Compression Complete!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'New size: ${ImageUtils.formatFileSize(_compressedFile!.lengthSync())}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ClipboardUtils.copyWithToast(
                              _compressedFile!.path,
                              label: 'File path',
                            );
                          },
                          icon: Icon(PhosphorIcons.copy(), size: 16),
                          label: const Text('Copy Path'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white38),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
