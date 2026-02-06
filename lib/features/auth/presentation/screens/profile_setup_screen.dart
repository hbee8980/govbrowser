import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../vault/providers/vault_provider.dart';
import '../../../vault/data/models/personal_info.dart';
import '../../../vault/data/models/contact_info.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  final String? email;
  final String? phone;

  const ProfileSetupScreen({super.key, this.email, this.phone});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _acceptedTerms = false;

  // Personal Info Controllers
  final _nameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _dobController = TextEditingController();
  String _selectedGender = 'Male';
  String _selectedCategory = 'General';

  // Address Controller
  final _addressController = TextEditingController();
  final _stateController = TextEditingController();
  final _pinCodeController = TextEditingController();

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _categories = ['General', 'OBC', 'SC', 'ST', 'EWS'];

  @override
  void dispose() {
    _nameController.dispose();
    _fatherNameController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
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

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept Terms & Conditions')),
      );
      return;
    }

    // Parse date string to DateTime
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

    // Save Personal Info
    final personalInfo = PersonalInfo(
      name: _nameController.text,
      fatherName: _fatherNameController.text,
      dob: parsedDob,
      gender: _selectedGender,
      category: _selectedCategory,
    );
    await ref.read(userProfileProvider.notifier).updatePersonal(personalInfo);

    // Save Contact Info (with email and phone from signup)
    final contactInfo = ContactInfo(
      email: widget.email ?? '',
      mobile: widget.phone ?? '',
      addressLine1: _addressController.text,
      state: _stateController.text,
      pinCode: _pinCodeController.text,
    );
    await ref.read(userProfileProvider.notifier).updateContact(contactInfo);

    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Complete Your Profile',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Information',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This info will help auto-fill government job forms',
                      style: GoogleFonts.inter(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),

                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name (as per documents)',
                      icon: PhosphorIcons.user(),
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _fatherNameController,
                      label: "Father's Name",
                      icon: PhosphorIcons.users(),
                    ),
                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: _selectDate,
                      child: AbsorbPointer(
                        child: _buildTextField(
                          controller: _dobController,
                          label: 'Date of Birth',
                          icon: PhosphorIcons.calendar(),
                          hint: 'DD/MM/YYYY',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildDropdown(
                      label: 'Gender',
                      value: _selectedGender,
                      items: _genders,
                      onChanged: (v) => setState(() => _selectedGender = v!),
                    ),
                    const SizedBox(height: 16),

                    _buildDropdown(
                      label: 'Category',
                      value: _selectedCategory,
                      items: _categories,
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),
                    const SizedBox(height: 24),

                    // Address Section
                    Text(
                      'Address (Optional)',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _addressController,
                      label: 'Address',
                      icon: PhosphorIcons.mapPin(),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _stateController,
                            label: 'State',
                            icon: PhosphorIcons.globe(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _pinCodeController,
                            label: 'PIN Code',
                            icon: PhosphorIcons.hash(),
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Terms & Conditions
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _acceptedTerms,
                              onChanged:
                                  (v) => setState(() => _acceptedTerms = v!),
                              activeColor: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap:
                                  () => setState(
                                    () => _acceptedTerms = !_acceptedTerms,
                                  ),
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF64748B),
                                  ),
                                  children: [
                                    const TextSpan(text: 'I agree to the '),
                                    TextSpan(
                                      text: 'Terms & Conditions',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    int? maxLength,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
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

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
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
