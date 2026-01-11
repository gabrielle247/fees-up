import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fees_up/data/constants/app_colors.dart';
import 'package:fees_up/data/constants/app_strings.dart';

// =============================================================================
// MISSING STRINGS (Merge these into your main AppStrings file later)
// =============================================================================
// Step Indicator
// static const String stepTitle = "Step 3 of 3";
// static const String stepProgress = "66% Complete";
// Headline & Subtitle
// static const String headline = "Almost There!";
// static const String subtitle = "Set up your school's financial and academic settings.";
// Section Titles 
// =============================================================================
// SCREEN IMPLEMENTATION
// =============================================================================
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // --- Configuration State ---
  String _selectedCurrency = AppStrings.valUsdCode; 
  String _academicSystem = AppStrings.id3Terms; 
  
  final TextEditingController _yearController = TextEditingController(
    text: DateTime.now().year.toString(),
  );

  // --- Data Models (Constructed strictly from Constants) ---
  final List<Map<String, String>> _currencies = [
    {
      AppStrings.kCode: AppStrings.valUsdCode, 
      AppStrings.kName: AppStrings.valUsdName 
    },
    {
      AppStrings.kCode: AppStrings.valZwgCode, 
      AppStrings.kName: AppStrings.valZwgName
    },
    {
      AppStrings.kCode: AppStrings.valZarCode, 
      AppStrings.kName: AppStrings.valZarName
    },
    {
      AppStrings.kCode: AppStrings.valGbpCode, 
      AppStrings.kName: AppStrings.valGbpName
    },
  ];

  final List<Map<String, String>> _systems = [
    {
      AppStrings.kId: AppStrings.id3Terms, 
      AppStrings.kName: AppStrings.name3Terms, 
      AppStrings.kDesc: AppStrings.desc3Terms
    },
    {
      AppStrings.kId: AppStrings.id2Semesters, 
      AppStrings.kName: AppStrings.name2Semesters, 
      AppStrings.kDesc: AppStrings.desc2Semesters
    },
    {
      AppStrings.kId: AppStrings.id4Quarters, 
      AppStrings.kName: AppStrings.name4Quarters, 
      AppStrings.kDesc: AppStrings.desc4Quarters
    },
  ];

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    setState(() => _isLoading = true);
    
    // Simulate API save
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isLoading = false);
      context.go(AppStrings.routePlans);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Helper to check if dark mode is active for border colors
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.surfaceLightGrey : AppColors.lightBorder;

    return Scaffold(
      appBar: AppBar(
        title:  Text(AppStrings.schoolSetup),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
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
                      Text(
                        AppStrings.stepTitle,
                        style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(AppStrings.stepProgress, style: textTheme.labelMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: 0.66,
                    backgroundColor: theme.dividerTheme.color?.withAlpha(50),
                    color: AppColors.primaryBlue,
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
                        AppStrings.headline,
                        style: textTheme.displaySmall?.copyWith(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.subtitle,
                        style: textTheme.bodyMedium,
                      ),

                      const SizedBox(height: 32),

                      // ================= SECTION 1: FINANCE =================
                      _buildSectionHeader(context, AppStrings.financeTitle),
                      
                      _buildLabel(context, AppStrings.labelBaseCurrency),
                      Container(
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Column(
                            children: _currencies.map((currency) {
                              final code = currency[AppStrings.kCode]!;
                              final name = currency[AppStrings.kName]!;
                              final isSelected = _selectedCurrency == code;
                              final isLast = currency == _currencies.last;
                              
                              return Column(
                                children: [
                                  RadioListTile<String>(
                                    value: code,
                                    groupValue: _selectedCurrency,
                                    onChanged: (val) => setState(() => _selectedCurrency = val!),
                                    activeColor: AppColors.primaryBlue,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                    title: Text(
                                      name,
                                      style: textTheme.bodyLarge?.copyWith(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? AppColors.primaryBlue : textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                    secondary: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isSelected 
                                            ? AppColors.primaryBlue.withAlpha(30) 
                                            : theme.dividerTheme.color?.withAlpha(20),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        code,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected 
                                              ? AppColors.primaryBlue 
                                              : textTheme.bodySmall?.color,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (!isLast)
                                    Divider(height: 1, color: borderColor.withAlpha(50)),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),

                      // ================= SECTION 2: ACADEMIC =================
                      _buildSectionHeader(context, AppStrings.academicYears),

                      _buildLabel(context, AppStrings.createAcademicYear),
                      TextFormField(
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        style: textTheme.bodyLarge,
                        decoration: const InputDecoration(
                          hintText: AppStrings.hintYear,
                          suffixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                      ),

                      const SizedBox(height: 24),

                      _buildLabel(context, AppStrings.labelTermSystem),
                      Container(
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Column(
                            children: _systems.map((sys) {
                              final id = sys[AppStrings.kId]!;
                              final name = sys[AppStrings.kName]!;
                              final desc = sys[AppStrings.kDesc]!;
                              
                              final isSelected = _academicSystem == id;
                              final isLast = sys == _systems.last;

                              return Column(
                                children: [
                                  RadioListTile<String>(
                                    value: id,
                                    groupValue: _academicSystem,
                                    onChanged: (val) => setState(() => _academicSystem = val!),
                                    activeColor: AppColors.primaryBlue,
                                    isThreeLine: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    title: Text(
                                      name,
                                      style: textTheme.bodyLarge?.copyWith(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected ? AppColors.primaryBlue : textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        desc,
                                        style: textTheme.bodySmall,
                                      ),
                                    ),
                                  ),
                                  if (!isLast)
                                    Divider(height: 1, color: borderColor.withAlpha(50)),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // --- Next Button ---
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleNext,
                          child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(AppStrings.nextBtnLabel),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward),
                                ],
                              ),
                        ),
                      ),
                      const SizedBox(height: 24),
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
              color: AppColors.primaryBlue,
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