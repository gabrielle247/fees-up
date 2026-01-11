import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class CreateSchoolScreen extends StatefulWidget {
  const CreateSchoolScreen({super.key});

  @override
  State<CreateSchoolScreen> createState() => _CreateSchoolScreenState();
}

class _CreateSchoolScreenState extends State<CreateSchoolScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- Controllers ---
  // Identity
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _subdomainController = TextEditingController();
  
  // Contact
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  // Location
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  // Legal
  final TextEditingController _taxIdController = TextEditingController();
  
  // State
  bool _isLoading = false;
  // ignore: unused_field
  String? _logoPath; 

  @override
  void dispose() {
    _nameController.dispose();
    _subdomainController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _taxIdController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // -----------------------------------------------------------------------
      // PLACEBO: Constructing the full object to simulate the "Save"
      // -----------------------------------------------------------------------
      /*
      final newSchool = School(
        id: Uuid().v4(), // Backend generated
        ownerId: authService.currentUser.id, // Backend generated
        createdAt: DateTime.now(),
        
        // User Inputs
        name: _nameController.text.trim(),
        subdomain: _subdomainController.text.trim().toLowerCase(),
        logoUrl: _logoPath,
        emailAddress: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        website: _websiteController.text.trim(),
        addressLine1: _addressController.text.trim(),
        city: _cityController.text.trim(),
        country: _countryController.text.trim(),
        taxId: _taxIdController.text.trim(),
        
        // Defaults until Plan Selection
        subscriptionStatus: 'trial', 
        currentPlanId: null, 
        validUntil: DateTime.now().add(const Duration(days: 14)),
      );
      */
      
      await Future.delayed(const Duration(seconds: 2)); // Simulate Network

      if (mounted) {
        // Proceed to Onboarding (or Plans)
        context.go('/onboarding');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error creating school: ${e.toString()}"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _pickImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Placebo: Image Picker")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("School Setup"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- Progress Header ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Step 1: School Profile", style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                      Text("1 of 3", style: textTheme.labelMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: 0.33,
                    backgroundColor: theme.dividerColor.withAlpha(50),
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 6,
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Create Your School",
                        style: textTheme.displaySmall?.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Fill in the details to configure your institution.",
                        style: textTheme.bodyMedium,
                      ),

                      const SizedBox(height: 32),

                      // --- Logo Uploader ---
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Column(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: theme.cardTheme.color,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: theme.dividerTheme.color ?? Colors.grey),
                                ),
                                child: Icon(Icons.camera_alt_outlined, size: 40, color: textTheme.bodySmall?.color),
                              ),
                              const SizedBox(height: 8),
                              Text("Upload Logo", style: textTheme.labelMedium),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ================= SECTION 1: IDENTITY =================
                      _buildSectionHeader(context, "Identity"),
                      
                      _buildLabel(context, "School Name"),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(hintText: "e.g. Springfield Elementary"),
                        validator: (v) => v!.isEmpty ? 'Name required' : null,
                        onChanged: (val) {
                          // Auto-fill subdomain suggestion if empty
                          if (_subdomainController.text.isEmpty) {
                            _subdomainController.text = val.replaceAll(' ', '').toLowerCase();
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildLabel(context, "Subdomain (Unique ID)"),
                      TextFormField(
                        controller: _subdomainController,
                        decoration: const InputDecoration(
                          hintText: "springfield", 
                          prefixText: "feesup.app/school/",
                        ),
                        validator: (v) => v!.isEmpty ? 'Subdomain required' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      _buildLabel(context, "Tax ID / Reg Number"),
                      TextFormField(
                        controller: _taxIdController,
                        decoration: const InputDecoration(hintText: "e.g. 123-456-789"),
                      ),

                      const SizedBox(height: 32),

                      // ================= SECTION 2: LOCATION =================
                      _buildSectionHeader(context, "Location"),

                      _buildLabel(context, "Address Line 1"),
                      TextFormField(
                        controller: _addressController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: "Street address, P.O. Box",
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        validator: (v) => v!.isEmpty ? 'Address required' : null,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(context, "City"),
                                TextFormField(
                                  controller: _cityController,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(hintText: "Harare"),
                                  validator: (v) => v!.isEmpty ? 'City required' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(context, "Country"),
                                TextFormField(
                                  controller: _countryController,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(hintText: "Zimbabwe"),
                                  validator: (v) => v!.isEmpty ? 'Country required' : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // ================= SECTION 3: CONTACT =================
                      _buildSectionHeader(context, "Contact Info"),

                      _buildLabel(context, "Official Email"),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: "admin@school.com",
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) => !v!.contains('@') ? 'Invalid email' : null,
                      ),
                      const SizedBox(height: 16),

                      _buildLabel(context, "Phone Number"),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: "+263 77 123 4567",
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (v) => v!.isEmpty ? 'Phone required' : null,
                      ),
                      const SizedBox(height: 16),

                      _buildLabel(context, "Website (Optional)"),
                      TextFormField(
                        controller: _websiteController,
                        keyboardType: TextInputType.url,
                        decoration: const InputDecoration(
                          hintText: "https://www.school.com",
                          prefixIcon: Icon(Icons.language_outlined),
                        ),
                      ),
                      
                      const SizedBox(height: 40),

                      // --- Submit ---
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleContinue,
                          child: _isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: colorScheme.onPrimary, strokeWidth: 2),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Save & Continue"),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward),
                                ],
                              ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          const Divider(),
        ],
      ),
    );
  }
}