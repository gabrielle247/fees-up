import 'package:fees_up/data/models/finance_models.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fees_up/data/constants/app_colors.dart';
import 'package:fees_up/data/constants/app_strings.dart';



// =============================================================================
// 3. SCREEN IMPLEMENTATION
// =============================================================================
class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  final PageController _pageController = PageController(
    viewportFraction: 0.85,
    initialPage: 1, // Start on PRO
  );

  int _currentIndex = 1; 
  bool _isLoading = false;

  // Strongly typed list
  final List<PlanModel> _plans = [
    const PlanModel(
      id: AppStrings.idBasic,
      title: AppStrings.titleBasic,
      price: AppStrings.priceBasic,
      description: AppStrings.descBasic,
      features: AppStrings.featuresBasic,
      isPopular: false,
    ),
    const PlanModel(
      id: AppStrings.idPro,
      title: AppStrings.titlePro,
      price: AppStrings.pricePro,
      description: AppStrings.descPro,
      features: AppStrings.featuresPro,
      isPopular: true,
    ),
    const PlanModel(
      id: AppStrings.idEnt,
      title: AppStrings.titleEnt,
      price: AppStrings.priceEnt,
      description: AppStrings.descEnt,
      features: AppStrings.featuresEnt,
      isPopular: false,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handlePlanSelection(String planId) async {
    setState(() => _isLoading = true);
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isLoading = false);
      context.go(AppStrings.routeBilling);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.pageTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Text(
                    AppStrings.header,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.subHeader,
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _plans.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  final plan = _plans[index];
                  final isFocused = _currentIndex == index;
                  
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    margin: EdgeInsets.symmetric(
                      horizontal: 8, 
                      vertical: isFocused ? 0 : 24 
                    ),
                    child: _buildPricingCard(context, plan),
                  );
                },
              ),
            ),

            // Dot Indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_plans.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index 
                          ? AppColors.primaryBlue 
                          : theme.dividerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard(BuildContext context, PlanModel plan) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final isPopular = plan.isPopular;

    // Logic for styling
    final borderColor = isPopular 
        ? AppColors.primaryBlue 
        : (isDark ? AppColors.surfaceLightGrey : AppColors.lightBorder);
    
    final borderWidth = isPopular ? 2.0 : 1.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: isPopular ? [
              BoxShadow(
                color: AppColors.primaryBlue.withAlpha(40),
                blurRadius: 16,
                offset: const Offset(0, 8),
              )
            ] : [],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                plan.title,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                plan.description,
                style: textTheme.bodySmall,
              ),
              
              const SizedBox(height: 24),
              
              // Price Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppStrings.currency,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isPopular ? AppColors.primaryBlue : null,
                    ),
                  ),
                  Text(
                    plan.price,
                    style: textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0, left: 2.0),
                    child: Text(
                      AppStrings.period,
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              Divider(color: theme.dividerColor.withAlpha(50)),
              const SizedBox(height: 24),

              // Features List
              Expanded(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: plan.features.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (ctx, idx) {
                    final feature = plan.features[idx];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 20,
                          color: isPopular ? AppColors.successGreen : theme.disabledColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature,
                            style: textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading 
                      ? null 
                      : () => _handlePlanSelection(plan.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPopular 
                        ? AppColors.primaryBlue 
                        : theme.scaffoldBackgroundColor,
                    foregroundColor: isPopular 
                        ? Colors.white 
                        : (isDark ? Colors.white : Colors.black),
                    side: isPopular 
                        ? BorderSide.none 
                        : BorderSide(color: borderColor),
                    elevation: isPopular ? 4 : 0,
                  ),
                  child: Text(
                    "${AppStrings.btnChoose} ${plan.title}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),

        if (isPopular)
          Positioned(
            top: -12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  AppStrings.lblMostPopular,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}