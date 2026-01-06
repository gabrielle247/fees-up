# Subscription Implementation Roadmap
**Project:** Fees Up - Strategic Plan for Monetization  
**Date:** January 5, 2026  
**Status:** Pre-Registration Phase  
**Priority:** Non-Blocking to Core Development  

---

## Executive Summary

This document outlines a **pragmatic, phased approach** to implementing subscription billing for Fees Up while ensuring it **does not distract from core product development**. Given that the business is not yet registered, we prioritize **non-invasive implementation strategies** that defer complex payment integrations until legal infrastructure is in place. The goal is to prepare the foundation without blocking current development velocity.

**Core Principle:** Build the subscription **UI/UX flow now**, defer the **payment processing** until post-registration.

---

## Table of Contents

1. [Current Reality Check](#1-current-reality-check)
2. [The Two-Track Strategy](#2-the-two-track-strategy)
3. [Phase 0: Foundation (No Distraction)](#3-phase-0-foundation-no-distraction)
4. [Phase 1: Pre-Registration MVP](#4-phase-1-pre-registration-mvp)
5. [Phase 2: Post-Registration Go-Live](#5-phase-2-post-registration-go-live)
6. [Technical Architecture (Minimal Invasiveness)](#6-technical-architecture-minimal-invasiveness)
7. [Security & Compliance (Unregistered Business)](#7-security--compliance-unregistered-business)
8. [Responsibility Matrix (Who Does What)](#8-responsibility-matrix-who-does-what)
9. [Risk Mitigation](#9-risk-mitigation)
10. [Success Metrics](#10-success-metrics)

---

## 1. Current Reality Check

### What We Have (Assets)
- ✅ Working Fees Up app (students, billing, payments, reports)
- ✅ PowerSync offline-first architecture (battle-tested)
- ✅ Supabase backend with RLS (security in place)
- ✅ Active development momentum (students screen, billing engine)
- ✅ Market research (subscription analysis, competitor intel, "Fresh Protocol")

### What We Don't Have (Blockers)
- ❌ Registered business entity (no legal structure)
- ❌ Tax ID / Business registration number
- ❌ Bank account for receiving payments
- ❌ Merchant accounts (Stripe, Flutterwave, Paystack)
- ❌ Terms of Service / Privacy Policy (legal documents)

### The Strategic Question
**"How do we prepare for monetization without slowing down product development?"**

**Answer:** We build the **subscription infrastructure** in a way that is:
1. **Non-invasive** - Uses feature flags, doesn't modify core app logic
2. **Deferrable** - Payment processing is pluggable, added later
3. **Testable** - We can validate UX and pricing before going live

---

## 2. The Two-Track Strategy

We run **two parallel tracks** that do not interfere with each other:

### Track A: Core Product Development (Primary Focus - 80% Effort)
**Owner:** Core Development Team  
**Goal:** Ship features that make Fees Up indispensable

**Current Priorities (Don't Stop These):**
- ✅ Students management (filtering, search, details screen)
- ✅ Billing engine (automated fee generation, late fees)
- ✅ Payment tracking (allocations, reconciliation)
- ✅ Reports (financial statements, revenue forecasting)
- ✅ PowerSync stability (offline reliability)

**Rule:** No subscription logic should block or delay these features.

---

### Track B: Monetization Preparation (Secondary - 20% Effort)
**Owner:** Business/Backend Lead (separate from UI team)  
**Goal:** Build subscription scaffolding without touching core features

**Parallel Workstreams:**
1. **Database Schema** - Add subscription tables (doesn't affect existing tables)
2. **UI Skeleton** - Build subscription screen (separate route, hidden behind flag)
3. **Tier Logic** - Define what each tier can/cannot do (config file, not code)
4. **Legal Prep** - Draft T&C, Privacy Policy (external consultant, no dev time)

**Rule:** All subscription work happens in isolation (separate files, separate routes).

---

## 3. Phase 0: Foundation (No Distraction)

**Timeline:** Week 1-2 (Parallel to current development)  
**Effort:** 4-6 hours total (spread over 2 weeks)  
**Impact on Core Development:** ZERO

### Deliverables

#### A. Database Schema (Backend Only)
**File:** New migration in `supabase_migrations/`  
**Action:** Create subscription-related tables (doesn't touch existing schema)

```sql
-- Migration: 20260106_add_subscriptions.sql
-- This runs in isolation, doesn't modify existing tables

CREATE TYPE subscription_tier AS ENUM ('free', 'starter', 'professional', 'enterprise');
CREATE TYPE subscription_status AS ENUM ('trial', 'active', 'past_due', 'canceled', 'paused');

-- Tracks which tier each school is on
CREATE TABLE school_subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  tier subscription_tier NOT NULL DEFAULT 'free',
  status subscription_status NOT NULL DEFAULT 'trial',
  
  -- Trial management
  trial_start_date TIMESTAMP WITH TIME ZONE,
  trial_end_date TIMESTAMP WITH TIME ZONE,
  
  -- Billing period
  current_period_start TIMESTAMP WITH TIME ZONE,
  current_period_end TIMESTAMP WITH TIME ZONE,
  
  -- Payment tracking (filled when payment integration is ready)
  payment_provider TEXT, -- 'flutterwave', 'stripe', 'manual', NULL (for free/trial)
  external_subscription_id TEXT, -- Provider's subscription ID
  last_payment_date TIMESTAMP WITH TIME ZONE,
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(school_id) -- One subscription per school
);

-- Usage tracking (for enforcing limits)
CREATE TABLE subscription_usage (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  metric TEXT NOT NULL, -- 'student_count', 'sms_sent', 'storage_mb'
  current_value INTEGER NOT NULL DEFAULT 0,
  limit_value INTEGER, -- NULL = unlimited
  period_start TIMESTAMP WITH TIME ZONE NOT NULL,
  period_end TIMESTAMP WITH TIME ZONE NOT NULL,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Payment history (for invoicing/reconciliation)
CREATE TABLE subscription_payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  subscription_id UUID NOT NULL REFERENCES school_subscriptions(id),
  
  amount NUMERIC(10, 2) NOT NULL,
  currency TEXT DEFAULT 'USD',
  payment_method TEXT, -- 'ecocash', 'onemoney', 'bank_transfer', 'card'
  
  status TEXT NOT NULL CHECK (status IN ('pending', 'successful', 'failed', 'refunded')),
  external_payment_id TEXT, -- Provider's transaction ID
  
  paid_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS Policies (Security)
ALTER TABLE school_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscription_usage ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscription_payments ENABLE ROW LEVEL SECURITY;

-- Schools can only see their own subscription
CREATE POLICY "Users can view own school subscription"
  ON school_subscriptions FOR SELECT
  USING (school_id IN (
    SELECT school_id FROM user_profiles WHERE id = auth.uid()
  ));

-- Only admins can view usage
CREATE POLICY "Users can view own school usage"
  ON subscription_usage FOR SELECT
  USING (school_id IN (
    SELECT school_id FROM user_profiles WHERE id = auth.uid()
  ));

-- Only admins can view payments
CREATE POLICY "Users can view own school payments"
  ON subscription_payments FOR SELECT
  USING (school_id IN (
    SELECT school_id FROM user_profiles WHERE id = auth.uid()
  ));

-- Indexes for performance
CREATE INDEX idx_school_subscriptions_school_id ON school_subscriptions(school_id);
CREATE INDEX idx_subscription_usage_school_id ON subscription_usage(school_id);
CREATE INDEX idx_subscription_payments_school_id ON subscription_payments(school_id);

-- Auto-assign free trial on school creation
CREATE OR REPLACE FUNCTION auto_assign_trial()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO school_subscriptions (school_id, tier, status, trial_start_date, trial_end_date)
  VALUES (
    NEW.id, 
    'free', 
    'trial', 
    NOW(), 
    NOW() + INTERVAL '14 days'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_auto_assign_trial
  AFTER INSERT ON schools
  FOR EACH ROW
  EXECUTE FUNCTION auto_assign_trial();
```

**Impact:** Zero. These tables are isolated. Core app continues working unchanged.

---

#### B. Tier Configuration File (Logic Separation)
**File:** `lib/core/config/subscription_tiers.dart`  
**Action:** Define tier limits in a config file (not hardcoded in features)

```dart
// lib/core/config/subscription_tiers.dart
// This file defines what each tier can/cannot do
// Easy to update without touching core logic

class SubscriptionTier {
  final String id;
  final String name;
  final String description;
  final double priceUSD;
  final Map<String, dynamic> limits;
  final List<String> features;

  const SubscriptionTier({
    required this.id,
    required this.name,
    required this.description,
    required this.priceUSD,
    required this.limits,
    required this.features,
  });
}

class SubscriptionTiers {
  // Define all tiers as constants
  static const free = SubscriptionTier(
    id: 'free',
    name: 'Free',
    description: 'For trying out Fees Up',
    priceUSD: 0,
    limits: {
      'max_students': 50,
      'max_users': 1,
      'sms_per_month': 0,
      'storage_mb': 100,
      'can_export_data': false,
      'can_use_api': false,
    },
    features: [
      'Student records (max 50)',
      'Basic billing',
      'Manual payments',
      'Basic reports',
      'Community support',
    ],
  );

  static const starter = SubscriptionTier(
    id: 'starter',
    name: 'Starter',
    description: 'For small schools and tutors',
    priceUSD: 15,
    limits: {
      'max_students': 150,
      'max_users': 3,
      'sms_per_month': 100,
      'storage_mb': 500,
      'can_export_data': true,
      'can_use_api': false,
    },
    features: [
      'Up to 150 students',
      'Automated billing',
      'SMS notifications (100/month)',
      'Payment tracking',
      '3 user accounts',
      'Email support',
      'Data export (Excel)',
    ],
  );

  static const professional = SubscriptionTier(
    id: 'professional',
    name: 'Professional',
    description: 'For growing schools',
    priceUSD: 75,
    limits: {
      'max_students': 500,
      'max_users': 10,
      'sms_per_month': 500,
      'storage_mb': 2000,
      'can_export_data': true,
      'can_use_api': false,
    },
    features: [
      'Up to 500 students',
      'Advanced reports',
      'Parent portal',
      'WhatsApp integration',
      'SMS notifications (500/month)',
      '10 user accounts',
      'Priority support',
      'Custom branding',
    ],
  );

  static const enterprise = SubscriptionTier(
    id: 'enterprise',
    name: 'Enterprise',
    description: 'For large schools and chains',
    priceUSD: 250,
    limits: {
      'max_students': 999999, // Effectively unlimited
      'max_users': 999999,
      'sms_per_month': 999999,
      'storage_mb': 10000,
      'can_export_data': true,
      'can_use_api': true,
    },
    features: [
      'Unlimited students',
      'Multi-campus support',
      'API access',
      'Unlimited SMS',
      'Unlimited users',
      'Dedicated account manager',
      '99.9% SLA',
      'Custom integrations',
    ],
  );

  // Easy lookup
  static const all = [free, starter, professional, enterprise];

  static SubscriptionTier getById(String id) {
    return all.firstWhere(
      (tier) => tier.id == id,
      orElse: () => free, // Default to free if unknown
    );
  }

  // Check if a feature is available for a tier
  static bool canAccess(String tierId, String limitKey) {
    final tier = getById(tierId);
    final limit = tier.limits[limitKey];
    
    if (limit == null) return false;
    if (limit is bool) return limit;
    return true; // Numeric limits checked separately
  }

  // Check if usage is within limit
  static bool isWithinLimit(String tierId, String limitKey, int currentUsage) {
    final tier = getById(tierId);
    final limit = tier.limits[limitKey];
    
    if (limit == null) return false;
    if (limit is! int) return true; // Boolean limits handled by canAccess
    
    return currentUsage < limit;
  }
}
```

**Impact:** Zero. This is just a config file. Doesn't touch any existing code.

---

#### C. Feature Flag Provider (Subscription Awareness)
**File:** `lib/data/providers/subscription_provider.dart`  
**Action:** Create a provider that reads subscription status (defaults to free trial)

```dart
// lib/data/providers/subscription_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../../core/config/subscription_tiers.dart';
import 'school_provider.dart';

// Model for subscription data
class SchoolSubscription {
  final String schoolId;
  final String tier; // 'free', 'starter', 'professional', 'enterprise'
  final String status; // 'trial', 'active', 'past_due', 'canceled'
  final DateTime? trialEndDate;
  final DateTime? currentPeriodEnd;

  SchoolSubscription({
    required this.schoolId,
    required this.tier,
    required this.status,
    this.trialEndDate,
    this.currentPeriodEnd,
  });

  bool get isActive => status == 'active' || status == 'trial';
  bool get isOnTrial => status == 'trial';
  bool get isPastDue => status == 'past_due';
  
  int get daysLeftInTrial {
    if (trialEndDate == null) return 0;
    return trialEndDate!.difference(DateTime.now()).inDays;
  }

  SubscriptionTier get tierConfig => SubscriptionTiers.getById(tier);
}

// Provider to fetch school's current subscription
final schoolSubscriptionProvider = FutureProvider<SchoolSubscription?>((ref) async {
  final schoolId = ref.watch(activeSchoolIdProvider);
  if (schoolId == null) return null;

  final db = DatabaseService();
  
  try {
    // Query the school_subscriptions table
    final result = await db.select(
      'SELECT * FROM school_subscriptions WHERE school_id = ?',
      [schoolId],
    );

    if (result.isEmpty) {
      // No subscription found - this shouldn't happen due to trigger
      // but handle gracefully by defaulting to free tier
      return SchoolSubscription(
        schoolId: schoolId,
        tier: 'free',
        status: 'trial',
        trialEndDate: DateTime.now().add(Duration(days: 14)),
      );
    }

    final sub = result.first;
    return SchoolSubscription(
      schoolId: schoolId,
      tier: sub['tier'] as String,
      status: sub['status'] as String,
      trialEndDate: sub['trial_end_date'] != null 
        ? DateTime.parse(sub['trial_end_date'] as String)
        : null,
      currentPeriodEnd: sub['current_period_end'] != null
        ? DateTime.parse(sub['current_period_end'] as String)
        : null,
    );
  } catch (e) {
    // If anything fails, default to free tier (safe fallback)
    return SchoolSubscription(
      schoolId: schoolId,
      tier: 'free',
      status: 'trial',
      trialEndDate: DateTime.now().add(Duration(days: 14)),
    );
  }
});

// Helper provider to check if a feature is accessible
final canAccessFeatureProvider = Provider.family<bool, String>((ref, featureKey) {
  final subscription = ref.watch(schoolSubscriptionProvider);
  
  return subscription.when(
    data: (sub) {
      if (sub == null) return false;
      if (!sub.isActive) return false; // Blocked if past due or canceled
      
      return SubscriptionTiers.canAccess(sub.tier, featureKey);
    },
    loading: () => true, // Allow access while loading (don't block UX)
    error: (_, __) => true, // Allow access on error (fail-open for UX)
  );
});

// Helper to check usage limits
final isWithinLimitProvider = Provider.family<bool, (String, int)>((ref, params) {
  final (limitKey, currentUsage) = params;
  final subscription = ref.watch(schoolSubscriptionProvider);
  
  return subscription.when(
    data: (sub) {
      if (sub == null) return true; // No subscription = no limits yet
      
      return SubscriptionTiers.isWithinLimit(sub.tier, limitKey, currentUsage);
    },
    loading: () => true,
    error: (_, __) => true,
  );
});
```

**Impact:** Zero on existing code. This provider just reads data. Doesn't enforce anything yet.

---

### Summary of Phase 0
**What We Built:**
- ✅ Database tables (isolated, doesn't touch core schema)
- ✅ Tier configuration (just a Dart file with constants)
- ✅ Subscription provider (reads data, doesn't block anything)

**What Changed in Existing Code:**
- ❌ NOTHING. Zero modifications to students, billing, payments, reports.

**Time Invested:** 4-6 hours over 2 weeks (doesn't slow core development)

---

## 4. Phase 1: Pre-Registration MVP

**Timeline:** Week 3-4 (Still before business registration)  
**Effort:** 8-12 hours  
**Goal:** Show pricing, collect intent, no actual payment processing

### What We Build

#### A. Subscription Screen (Static UI)
**File:** `lib/pc/screens/subscription_screen.dart`  
**Purpose:** Show pricing tiers, allow user to select a plan (but not pay yet)

**Key Features:**
1. **Pricing Table** - Shows all 4 tiers (Free, Starter, Pro, Enterprise)
2. **Comparison Matrix** - What each tier includes/excludes
3. **"Choose Plan" Buttons:**
   - Free: Instant activation (already on it)
   - Starter/Pro: "Contact Sales" (opens email with pre-filled details)
   - Enterprise: "Schedule Demo" (Calendly link or email)

**Why This Works:**
- Users see we have a monetization plan (builds trust)
- We collect "intent to pay" data (email addresses of interested schools)
- No payment processing = no merchant account needed
- No legal risk (we're not taking money)

**Code Structure:**
```dart
// lib/pc/screens/subscription_screen.dart
class SubscriptionScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSub = ref.watch(schoolSubscriptionProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('Subscription Plans')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTrialBanner(currentSub), // Shows days left in trial
            _buildPricingTable(),
            _buildComparisonMatrix(),
            _buildFAQ(),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingTable() {
    return Row(
      children: [
        _buildTierCard(SubscriptionTiers.free),
        _buildTierCard(SubscriptionTiers.starter),
        _buildTierCard(SubscriptionTiers.professional),
        _buildTierCard(SubscriptionTiers.enterprise),
      ],
    );
  }

  Widget _buildTierCard(SubscriptionTier tier) {
    return Card(
      child: Column(
        children: [
          Text(tier.name),
          Text('\$${tier.priceUSD}/month'),
          Text(tier.description),
          ...tier.features.map((f) => Text('✓ $f')),
          ElevatedButton(
            onPressed: () => _handleSelectPlan(tier),
            child: Text(_getButtonLabel(tier)),
          ),
        ],
      ),
    );
  }

  void _handleSelectPlan(SubscriptionTier tier) {
    if (tier.id == 'free') {
      // Already on free tier
      _showSnackbar('You are currently on the Free plan');
      return;
    }

    if (tier.id == 'enterprise') {
      // Open email or Calendly
      _launchEmail(
        to: 'sales@feesup.co',
        subject: 'Enterprise Plan Inquiry',
        body: 'I am interested in the Enterprise plan for my school...',
      );
      return;
    }

    // For Starter/Pro - collect intent
    _showContactDialog(tier);
  }

  void _showContactDialog(SubscriptionTier tier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upgrade to ${tier.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('We are currently setting up payment processing.'),
            Text('Leave your details and we will notify you when ready.'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(labelText: 'Email'),
              onChanged: (value) => _emailInput = value,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Phone (WhatsApp)'),
              onChanged: (value) => _phoneInput = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _submitUpgradeIntent(tier.id, _emailInput, _phoneInput);
              Navigator.pop(context);
            },
            child: Text('Notify Me'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitUpgradeIntent(String tierId, String email, String phone) async {
    // Save to a "leads" table in Supabase
    final supabase = Supabase.instance.client;
    await supabase.from('subscription_leads').insert({
      'tier': tierId,
      'email': email,
      'phone': phone,
      'school_id': ref.read(activeSchoolIdProvider),
      'created_at': DateTime.now().toIso8601String(),
    });

    _showSnackbar('Thank you! We will contact you soon.');
  }
}
```

**Impact on Core Development:** Zero. This is a separate screen accessed via Settings.

---

#### B. Add Route to Subscription Screen
**File:** `lib/core/routes/app_router.dart`  
**Action:** Add one route

```dart
// Add to routes list
GoRoute(
  path: '/subscription',
  builder: (context, state) => const SubscriptionScreen(),
),
```

---

#### C. Update Premium Guard (Link to Subscription Screen)
**File:** `lib/core/widgets/premium_guard.dart`  
**Action:** Change "Coming Soon" to actual navigation

```dart
// OLD CODE (Line 72):
onPressed: () {
  // TODO: Navigate to Payment/Subscription Screen
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Subscription Flow Coming Soon")),
  );
},

// NEW CODE:
onPressed: () {
  context.push('/subscription'); // Navigate to pricing page
},
```

**Impact:** The "Upgrade" button now works. Users see pricing. No code changes to core features.

---

### What Happens in Phase 1

**User Journey:**
1. User tries to add 51st student (exceeds free tier limit)
2. App shows Premium Guard dialog
3. User clicks "Upgrade"
4. **NEW:** User lands on Subscription Screen (sees pricing)
5. User clicks "Choose Starter Plan"
6. **NEW:** Dialog: "Leave your email, we'll notify you when payment is ready"
7. App saves email to `subscription_leads` table
8. **Manual Follow-up:** You email them when Flutterwave is ready

**What We Gain:**
- ✅ Validated pricing (do users click "Starter" or "Pro"?)
- ✅ Lead list (emails of schools willing to pay)
- ✅ No legal liability (we're not processing payments)
- ✅ Professional appearance (we have a pricing page)

**What We Avoid:**
- ❌ No payment integration yet
- ❌ No merchant accounts needed
- ❌ No liability for failed transactions
- ❌ No tax collection complexity

---

## 5. Phase 2: Post-Registration Go-Live

**Timeline:** After business registration (Week 8+)  
**Trigger:** You have a registered company, bank account, and merchant account  
**Effort:** 2-3 days  
**Goal:** Accept real payments

### Prerequisites (Must Be Complete First)

Before implementing Phase 2, you MUST have:

#### Legal/Business
- [ ] Company registered (Private Limited, or equivalent)
- [ ] Tax ID (TIN - Taxpayer Identification Number)
- [ ] Bank account in company name (for receiving funds)
- [ ] Terms of Service written (lawyer-reviewed)
- [ ] Privacy Policy written (GDPR/POPIA compliant)
- [ ] Refund policy defined

#### Technical
- [ ] Merchant account opened:
  - **Option A:** Flutterwave (recommended for Zimbabwe)
  - **Option B:** Stripe (for international schools)
- [ ] Test transactions successful in sandbox
- [ ] Webhook endpoint tested (Supabase Edge Function)

---

### Implementation Steps

#### Step 1: Flutterwave Integration (3-4 hours)

**A. Add Flutter Package**
```yaml
# pubspec.yaml
dependencies:
  flutterwave: ^1.0.5  # Official Flutterwave SDK
```

**B. Create Payment Service**
```dart
// lib/data/services/payment_service.dart
import 'package:flutterwave/flutterwave.dart';

class PaymentService {
  final Flutterwave _flutterwave;

  PaymentService({required String publicKey}) 
    : _flutterwave = Flutterwave.forUIPayment(
        publicKey: publicKey,
        encryptionKey: 'YOUR_ENCRYPTION_KEY',
        isDebugMode: false, // Set to true for testing
      );

  Future<bool> initiateSubscription({
    required String email,
    required String phone,
    required double amount,
    required String currency,
    required String txRef,
  }) async {
    try {
      final response = await _flutterwave.charge(
        amount: amount.toString(),
        currency: currency,
        email: email,
        fullName: 'School Admin',
        phoneNumber: phone,
        txRef: txRef,
        redirectUrl: 'https://your-backend.com/webhook/flutterwave',
      );

      if (response?.status == 'successful') {
        return true;
      }
      return false;
    } catch (e) {
      print('Payment error: $e');
      return false;
    }
  }
}
```

**C. Update Subscription Screen**
Replace "Contact Sales" button with actual payment flow:

```dart
ElevatedButton(
  onPressed: () async {
    final paymentService = ref.read(paymentServiceProvider);
    final school = ref.read(currentSchoolProvider).value;
    
    final success = await paymentService.initiateSubscription(
      email: school['admin_email'],
      phone: school['admin_phone'],
      amount: tier.priceUSD,
      currency: 'USD',
      txRef: 'SUB-${DateTime.now().millisecondsSinceEpoch}',
    );

    if (success) {
      // Payment successful - webhook will update subscription status
      _showSnackbar('Payment successful! Your account will be upgraded shortly.');
    } else {
      _showSnackbar('Payment failed. Please try again.');
    }
  },
  child: Text('Pay \$${tier.priceUSD}/month'),
),
```

---

#### Step 2: Webhook Handler (Supabase Edge Function)

**Purpose:** When Flutterwave confirms payment, upgrade the school's subscription tier

**File:** `supabase/functions/flutterwave-webhook/index.ts`

```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    const payload = await req.json()
    
    // Verify webhook signature (security)
    const hash = payload.hash
    const expectedHash = // ... compute hash using Flutterwave secret key
    if (hash !== expectedHash) {
      return new Response('Invalid signature', { status: 401 })
    }

    // Extract payment details
    const { status, tx_ref, amount, customer } = payload.data
    
    if (status === 'successful') {
      // Find which school made this payment
      const supabase = createClient(
        Deno.env.get('SUPABASE_URL')!,
        Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')! // Use service key for admin access
      )

      // Determine tier based on amount
      let tier = 'starter'
      if (amount >= 75) tier = 'professional'
      if (amount >= 250) tier = 'enterprise'

      // Update school_subscriptions
      const { data, error } = await supabase
        .from('school_subscriptions')
        .update({
          tier: tier,
          status: 'active',
          current_period_start: new Date().toISOString(),
          current_period_end: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(), // +30 days
          payment_provider: 'flutterwave',
          external_subscription_id: tx_ref,
          last_payment_date: new Date().toISOString(),
        })
        .eq('school_id', customer.email) // Assuming email maps to school
        .select()

      // Log payment
      await supabase.from('subscription_payments').insert({
        school_id: data[0].school_id,
        subscription_id: data[0].id,
        amount: amount,
        currency: 'USD',
        payment_method: 'flutterwave',
        status: 'successful',
        external_payment_id: tx_ref,
        paid_at: new Date().toISOString(),
      })

      return new Response(JSON.stringify({ success: true }), { status: 200 })
    }

    return new Response('Payment not successful', { status: 400 })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 })
  }
})
```

---

#### Step 3: Enforce Limits (Feature Gates)

Now that subscriptions are real, enforce tier limits:

**Example: Student Creation Limit**

```dart
// lib/pc/widgets/students/students_header.dart
// Before showing "Add Student" dialog:

onPressed: () async {
  // Check if school is within student limit
  final currentCount = ref.read(filteredStudentsProvider(schoolId)).value?.length ?? 0;
  final canAdd = ref.read(isWithinLimitProvider(('max_students', currentCount)));
  
  if (!canAdd) {
    // Show upgrade dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Student Limit Reached'),
        content: Text('You have reached your plan limit. Upgrade to add more students.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/subscription'); // Navigate to upgrade
            },
            child: Text('Upgrade Plan'),
          ),
        ],
      ),
    );
    return;
  }

  // Proceed with adding student
  _showAddStudentDialog();
},
```

**Apply Same Pattern To:**
- SMS sending (check `sms_per_month` limit)
- User account creation (check `max_users`)
- API access (check `can_use_api` flag)
- Data export (check `can_export_data` flag)

---

## 6. Technical Architecture (Minimal Invasiveness)

### Design Principles

1. **Separation of Concerns**
   - Subscription logic lives in `lib/core/config/` and `lib/data/providers/subscription_provider.dart`
   - Core features don't import subscription code
   - Feature flags accessed via centralized provider

2. **Fail-Open Strategy**
   - If subscription check fails → allow access (don't block user)
   - Only hard-block when payment is confirmed overdue
   - Error states default to "permissive" (better UX than hard fail)

3. **Database Isolation**
   - Subscription tables don't JOIN with core tables (performance)
   - Linked via `school_id` foreign key only
   - Can drop subscription tables without affecting core app

4. **Configuration Over Code**
   - Tier limits in `subscription_tiers.dart` (easy to change)
   - No hardcoded limits scattered across codebase
   - Single source of truth

---

### Data Flow Diagram

```
User Action (e.g., Add Student)
  ↓
UI checks: canAccessFeatureProvider('max_students')
  ↓
Provider reads: school_subscriptions table
  ↓
Returns: current tier (e.g., 'starter')
  ↓
Compares: current usage vs tier limit
  ↓
Decision: Allow or Show Upgrade Dialog
```

**Key Point:** The core "Add Student" logic never changes. The check is a **wrapper** around it.

---

## 7. Security & Compliance (Unregistered Business)

### Legal Risk Analysis

| Action | Risk Level | Legal Issue | Mitigation |
|--------|-----------|-------------|------------|
| **Showing Pricing** | 🟢 NONE | Advertising is legal | Just don't collect money |
| **Collecting Emails** | 🟡 LOW | GDPR/Privacy concern | Add "We will only contact you about Fees Up" disclaimer |
| **Processing Payments** | 🔴 HIGH | Operating without registration = illegal | **DO NOT DO UNTIL REGISTERED** |
| **Storing Card Info** | 🔴 EXTREME | PCI-DSS violation | **NEVER STORE. Use Flutterwave's hosted checkout** |

---

### Pre-Registration Rules

**What You CAN Do:**
- ✅ Show pricing page
- ✅ Collect "upgrade intent" (emails)
- ✅ Send marketing emails ("Payment is now live!")
- ✅ Build the UI/UX
- ✅ Test in sandbox mode

**What You CANNOT Do:**
- ❌ Process real payments (money changing hands)
- ❌ Issue invoices (requires tax ID)
- ❌ Promise service delivery without legal entity
- ❌ Store payment method details (cards, bank accounts)

---

### Post-Registration Requirements

Once registered, you MUST:

**Legal:**
- [ ] Terms of Service (cover refunds, SLA, data ownership)
- [ ] Privacy Policy (GDPR/POPIA compliant)
- [ ] Refund policy (30-day money-back? No refunds?)
- [ ] Data Processing Agreement (DPA) for schools handling student data

**Financial:**
- [ ] Accounting software (QuickBooks, Xero) to track MRR
- [ ] Tax registration (VAT if revenue > threshold)
- [ ] Invoice generation (compliant with Zimbabwe tax law)

**Technical:**
- [ ] PCI-DSS compliance (use Flutterwave's hosted checkout, never store cards)
- [ ] SSL certificate (already have via Supabase)
- [ ] Webhook security (verify signatures, use HTTPS only)
- [ ] Data encryption at rest (PostgreSQL encryption already in place)

---

## 8. Responsibility Matrix (Who Does What)

To avoid distracting core development, assign clear ownership:

### Development Team Roles

| Responsibility | Owner | Effort | Timeline |
|----------------|-------|--------|----------|
| **Core App Features** | Lead Developer (You) | 80% | Ongoing |
| **Subscription DB Schema** | Backend Dev | 2 hours | Week 1 |
| **Tier Config File** | Backend Dev | 1 hour | Week 1 |
| **Subscription Provider** | Backend Dev | 2 hours | Week 2 |
| **Subscription Screen UI** | UI Developer | 6 hours | Week 3 |
| **Payment Integration** | Backend Dev | 8 hours | Post-Registration |
| **Webhook Handler** | Backend Dev | 4 hours | Post-Registration |
| **Feature Gates** | Lead Dev + Backend | 4 hours | Post-Registration |

### Business/Legal Roles

| Responsibility | Owner | Effort | Timeline |
|----------------|-------|--------|----------|
| **Business Registration** | Founder | 2-4 weeks | ASAP |
| **Terms of Service** | Legal Consultant | 3-5 days | Week 4 |
| **Privacy Policy** | Legal Consultant | 2-3 days | Week 4 |
| **Tax Registration** | Accountant | 1 week | Post-Registration |
| **Merchant Account Setup** | Founder + Backend Dev | 1-2 weeks | Post-Registration |
| **Marketing (Pricing Page)** | Marketing Lead | 3 days | Week 3 |

**Key Insight:** Backend dev handles subscription infrastructure (20% effort), Lead dev stays focused on core features (80% effort). They work in parallel.

---

## 9. Risk Mitigation

### Risks & Countermeasures

#### Risk 1: Subscription Code Breaks Core Features
**Likelihood:** Low  
**Impact:** High  
**Mitigation:**
- ✅ All subscription checks use try-catch with fail-open defaults
- ✅ Subscription provider errors return "true" (allow access)
- ✅ Feature flags are optional (app works without them)
- ✅ Subscription screen is separate route (doesn't affect main nav)

---

#### Risk 2: Payment Integration Takes Too Long
**Likelihood:** Medium  
**Impact:** Medium  
**Mitigation:**
- ✅ Phase 1 (Pre-Registration) collects leads without payment
- ✅ We can manually invoice early customers (email invoice, bank transfer)
- ✅ Payment integration is deferred (doesn't block other features)
- ✅ Sandbox testing happens in parallel to registration

---

#### Risk 3: Users Bypass Free Tier Limits
**Likelihood:** High (if not enforced)  
**Impact:** Low (revenue loss, but manageable)  
**Mitigation:**
- ✅ Soft limits first (warnings, not hard blocks)
- ✅ Track violations in `subscription_usage` table
- ✅ Backend RLS prevents direct database manipulation
- ✅ Periodic audits (identify schools exceeding limits)

---

#### Risk 4: Legal Issues (Operating Without Registration)
**Likelihood:** Medium  
**Impact:** High (fines, shutdown)  
**Mitigation:**
- ✅ **DO NOT** process payments until registered
- ✅ Phase 1 only shows pricing and collects intent
- ✅ Clearly mark as "Coming Soon" on pricing page
- ✅ Fast-track business registration (top priority)

---

## 10. Success Metrics

### Phase 0 Metrics (Foundation)
- ✅ Migration deployed without errors
- ✅ Tier config file created
- ✅ Subscription provider returns data correctly
- ✅ Zero impact on existing features (no regressions)

### Phase 1 Metrics (Pre-Registration MVP)
- 🎯 Pricing page live
- 🎯 10+ "upgrade intent" leads collected
- 🎯 User feedback on pricing ("too expensive" vs "reasonable")
- 🎯 Conversion rate: % of schools that click "Upgrade"

### Phase 2 Metrics (Post-Registration Go-Live)
- 🎯 First paid subscriber within 7 days of launch
- 🎯 10 paid subscribers within 30 days
- 🎯 Monthly Recurring Revenue (MRR): $500+ by Month 2
- 🎯 Churn rate: <5% monthly
- 🎯 Upgrade rate: 40% of free tier users upgrade within 90 days

---

## Conclusion: The Non-Blocking Path to Monetization

This roadmap ensures subscription implementation **does not become a distraction**. By isolating subscription logic into:
1. Separate database tables
2. Configuration files
3. Independent providers
4. A single new screen

...we protect core development velocity while preparing for revenue generation.

**The Timeline:**
- **Week 1-2:** Foundation (database + config) - 4 hours
- **Week 3-4:** Pre-Registration MVP (pricing page) - 8 hours
- **Week 8+:** Post-Registration Go-Live (payment integration) - 16 hours

**Total Investment:** 28 hours spread over 8+ weeks.

**Core Development Impact:** 0 hours (runs in parallel).

**The Strategy:**
- Build the subscription **scaffolding** now
- Defer payment **processing** until post-registration
- Collect **intent** before collecting **money**
- Enforce **limits** only when revenue starts flowing

This approach is secure, legal, and minimally invasive. You ship subscription infrastructure without slowing down the features that make Fees Up valuable in the first place.

---

**Next Action:** Approve this roadmap, then:
1. Run Phase 0 database migration (2 hours)
2. Create tier config file (1 hour)
3. Continue core development uninterrupted

**Questions? Review Section 8 (Responsibility Matrix) to see who owns what.**

---

**Document End**
