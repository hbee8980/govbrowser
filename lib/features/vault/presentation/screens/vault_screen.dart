import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../providers/vault_provider.dart';
import '../../data/models/personal_info.dart';
import '../../data/models/contact_info.dart';

/// Vault screen - Profile viewer and editor
class VaultScreen extends ConsumerWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vault'),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.signOut()),
            tooltip: 'Logout',
            onPressed: () {
              GoRouter.of(context).go('/login');
            },
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          final completion = profile.completionPercentage;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Completion card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            PhosphorIcons.userCircle(PhosphorIconsStyle.fill),
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.personal?.name ?? 'Add Your Name',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  profile.contact?.email ?? 'Add Email',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: completion / 100,
                              backgroundColor: Colors.grey[200],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$completion%',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Profile Completion',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Section: Personal Info
              _PersonalInfoSection(
                personal: profile.personal,
                onEdit:
                    () =>
                        _showPersonalEditDialog(context, ref, profile.personal),
              ),

              // Section: Contact Info
              _ContactInfoSection(
                contact: profile.contact,
                onEdit:
                    () => _showContactEditDialog(context, ref, profile.contact),
              ),

              // Section: Documents
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            PhosphorIcons.images(),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Documents & Assets',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          IconButton(
                            icon: Icon(PhosphorIcons.pencilSimple(), size: 20),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Document upload coming soon!'),
                                ),
                              );
                            },
                            tooltip: 'Edit Documents',
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildAssetChip(
                            context,
                            'Photo',
                            profile.assets?.photoPath != null,
                          ),
                          _buildAssetChip(
                            context,
                            'Signature',
                            profile.assets?.signaturePath != null,
                          ),
                          _buildAssetChip(
                            context,
                            'Aadhaar',
                            profile.personal?.aadhaarNo != null &&
                                profile.personal!.aadhaarNo!.isNotEmpty,
                          ),
                          _buildAssetChip(
                            context,
                            'Caste Cert',
                            profile.assets?.casteCertificatePath != null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAssetChip(BuildContext context, String label, bool hasAsset) {
    return Chip(
      avatar: Icon(
        hasAsset ? PhosphorIcons.checkCircle() : PhosphorIcons.circle(),
        size: 18,
        color: hasAsset ? Colors.green : Colors.grey,
      ),
      label: Text(label),
      backgroundColor:
          hasAsset
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
    );
  }

  void _showPersonalEditDialog(
    BuildContext context,
    WidgetRef ref,
    PersonalInfo? current,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PersonalEditSheet(current: current),
    );
  }

  void _showContactEditDialog(
    BuildContext context,
    WidgetRef ref,
    ContactInfo? current,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ContactEditSheet(current: current),
    );
  }
}

// Personal Info Section Widget
class _PersonalInfoSection extends StatelessWidget {
  final PersonalInfo? personal;
  final VoidCallback onEdit;

  const _PersonalInfoSection({required this.personal, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  PhosphorIcons.user(),
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Personal Information',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: Icon(PhosphorIcons.pencilSimple(), size: 20),
                  onPressed: onEdit,
                  tooltip: 'Edit Personal Info',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(),
            _buildField(context, 'Name', personal?.name),
            _buildField(context, "Father's Name", personal?.fatherName),
            _buildField(context, 'Date of Birth', personal?.formattedDob),
            _buildField(context, 'Gender', personal?.gender),
            _buildField(context, 'Category', personal?.category),
            _buildField(context, 'Aadhaar No.', personal?.aadhaarNo),
          ],
        ),
      ),
    );
  }

  Widget _buildField(BuildContext context, String label, String? value) {
    final isEmpty = value == null || value.isEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(
              isEmpty ? 'Not Added' : value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isEmpty ? Colors.grey : null,
                fontStyle: isEmpty ? FontStyle.italic : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Contact Info Section Widget
class _ContactInfoSection extends StatelessWidget {
  final ContactInfo? contact;
  final VoidCallback onEdit;

  const _ContactInfoSection({required this.contact, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  PhosphorIcons.phone(),
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Contact Information',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: Icon(PhosphorIcons.pencilSimple(), size: 20),
                  onPressed: onEdit,
                  tooltip: 'Edit Contact Info',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(),
            _buildField(context, 'Email', contact?.email),
            _buildField(context, 'Mobile', contact?.mobile),
            _buildField(context, 'Address', contact?.addressLine1),
            _buildField(context, 'State', contact?.state),
            _buildField(context, 'PIN Code', contact?.pinCode),
          ],
        ),
      ),
    );
  }

  Widget _buildField(BuildContext context, String label, String? value) {
    final isEmpty = value == null || value.isEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(
              isEmpty ? 'Not Added' : value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isEmpty ? Colors.grey : null,
                fontStyle: isEmpty ? FontStyle.italic : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Personal Info Edit Sheet
class _PersonalEditSheet extends ConsumerStatefulWidget {
  final PersonalInfo? current;

  const _PersonalEditSheet({this.current});

  @override
  ConsumerState<_PersonalEditSheet> createState() => _PersonalEditSheetState();
}

class _PersonalEditSheetState extends ConsumerState<_PersonalEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _fatherNameController;
  late final TextEditingController _dobController;
  late final TextEditingController _aadhaarController;
  late String _selectedGender;
  late String _selectedCategory;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _categories = ['General', 'OBC', 'SC', 'ST', 'EWS'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.current?.name ?? '');
    _fatherNameController = TextEditingController(
      text: widget.current?.fatherName ?? '',
    );
    _dobController = TextEditingController(
      text: widget.current?.formattedDob ?? '',
    );
    _aadhaarController = TextEditingController(
      text: widget.current?.aadhaarNo ?? '',
    );
    _selectedGender = widget.current?.gender ?? 'Male';
    _selectedCategory = widget.current?.category ?? 'General';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fatherNameController.dispose();
    _dobController.dispose();
    _aadhaarController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.current?.dob ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    DateTime? parsedDob;
    if (_dobController.text.isNotEmpty) {
      final parts = _dobController.text.split('/');
      if (parts.length == 3) {
        parsedDob = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    }

    final personalInfo = PersonalInfo(
      name: _nameController.text,
      fatherName: _fatherNameController.text,
      dob: parsedDob,
      gender: _selectedGender,
      category: _selectedCategory,
      aadhaarNo: _aadhaarController.text,
    );

    await ref.read(userProfileProvider.notifier).updatePersonal(personalInfo);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Edit Personal Info',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                _nameController,
                'Full Name',
                PhosphorIcons.user(),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                _fatherNameController,
                "Father's Name",
                PhosphorIcons.users(),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: _buildTextField(
                    _dobController,
                    'Date of Birth',
                    PhosphorIcons.calendar(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                'Gender',
                _selectedGender,
                _genders,
                (v) => setState(() => _selectedGender = v!),
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                'Category',
                _selectedCategory,
                _categories,
                (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                _aadhaarController,
                'Aadhaar Number',
                PhosphorIcons.identificationCard(),
                keyboardType: TextInputType.number,
                maxLength: 12,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        counterText: '',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }
}

// Contact Info Edit Sheet
class _ContactEditSheet extends ConsumerStatefulWidget {
  final ContactInfo? current;

  const _ContactEditSheet({this.current});

  @override
  ConsumerState<_ContactEditSheet> createState() => _ContactEditSheetState();
}

class _ContactEditSheetState extends ConsumerState<_ContactEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _mobileController;
  late final TextEditingController _addressController;
  late final TextEditingController _stateController;
  late final TextEditingController _pinCodeController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.current?.email ?? '');
    _mobileController = TextEditingController(
      text: widget.current?.mobile ?? '',
    );
    _addressController = TextEditingController(
      text: widget.current?.addressLine1 ?? '',
    );
    _stateController = TextEditingController(text: widget.current?.state ?? '');
    _pinCodeController = TextEditingController(
      text: widget.current?.pinCode ?? '',
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final contactInfo = ContactInfo(
      email: _emailController.text,
      mobile: _mobileController.text,
      addressLine1: _addressController.text,
      state: _stateController.text,
      pinCode: _pinCodeController.text,
    );

    await ref.read(userProfileProvider.notifier).updateContact(contactInfo);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Edit Contact Info',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                _emailController,
                'Email',
                PhosphorIcons.envelopeSimple(),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                _mobileController,
                'Mobile',
                PhosphorIcons.phone(),
                keyboardType: TextInputType.phone,
                maxLength: 10,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                _addressController,
                'Address',
                PhosphorIcons.mapPin(),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              _buildTextField(_stateController, 'State', PhosphorIcons.globe()),
              const SizedBox(height: 12),
              _buildTextField(
                _pinCodeController,
                'PIN Code',
                PhosphorIcons.hash(),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    int? maxLength,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        counterText: '',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }
}
