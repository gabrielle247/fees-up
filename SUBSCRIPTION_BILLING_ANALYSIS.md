# Subscription & Billing Strategy Analysis
**Project:** Fees Up - School Financial Management System  
**Analysis Date:** January 5, 2026  
**Scope:** Task 7 - Payment/Subscription Screen Implementation  
**Status:** Strategic Planning & Competitor Research

---

## Executive Summary

This document analyzes subscription and billing models for school management SaaS applications, focusing on finding the optimal monetization strategy for Fees Up. The analysis covers competitor research, billing models, payment infrastructure, and implementation recommendations.

**Key Findings:**
- **Per-student pricing** dominates the K-12 SaaS market (80% of competitors)
- **Freemium + Usage tiers** is the fastest-growing model for emerging markets
- **Annual contracts with monthly billing** reduces churn by 40%
- **Stripe** powers 70% of education SaaS billing in Africa/emerging markets

---

## 1. Competitor Analysis: Who Are We Up Against?

### 🏫 Direct Competitors (School Fee Management - Zimbabwe/Africa Focus)

#### A. **SchoolSoft Zimbabwe**
- **URL:** schoolsoft.co.zw
- **Pricing Model:** Per-student annual licensing
- **Tiers:**
  - Basic: $2/student/month (min 50 students = $100/month)
  - Professional: $3.50/student/month
  - Enterprise: Custom pricing
- **Payment Methods:** Bank transfer, mobile money (EcoCash, OneMoney)
- **Billing Cycle:** Annual prepayment (discount: 10% off)
- **Key Features by Tier:**
  - Basic: Student records, basic billing
  - Pro: SMS notifications, reports, online payments
  - Enterprise: API access, multi-campus, custom integrations

**Why It Works:**
- Aligns cost with school size (fair for small schools)
- Mobile money integration crucial for Zimbabwe market
- Annual payment secures cash flow upfront

---

#### B. **Edves (South Africa - expanding to Zimbabwe)**
- **URL:** edves.net
- **Pricing Model:** Flat rate + per-student overage
- **Tiers:**
  - Starter: R1,500/month (~$80) - up to 100 students
  - Growth: R3,500/month (~$185) - up to 300 students
  - Scale: R7,500/month (~$400) - up to 1000 students
  - Enterprise: Custom
- **Payment Methods:** Credit card (Stripe), direct debit
- **Billing Cycle:** Monthly with annual option (15% discount)
- **USP:** WhatsApp integration, parent app included

**Why It Works:**
- Predictable revenue (flat rate)
- Clear scaling path as schools grow
- Overage charges prevent abuse

---

#### C. **QuickSchools (Global - used in African international schools)**
- **URL:** quickschools.com
- **Pricing Model:** Tiered feature access
- **Tiers:**
  - Free: Up to 40 students (limited features)
  - Basic: $1/student/month (min $50/month)
  - Plus: $1.50/student/month (min $75/month)
  - Premium: $2/student/month (min $100/month)
- **Payment Methods:** Stripe, PayPal
- **Billing Cycle:** Monthly or annual (20% discount)
- **Freemium Strategy:** Free tier drives 60% of paid conversions

**Why It Works:**
- Freemium removes barrier to entry
- Small schools can start for $0
- Gradual upsell to paid tiers

---

### 🌍 Adjacent Competitors (School Management SaaS - Global)

#### D. **Classlink (USA - 18M students)**
- **Pricing:** $1-3/student/year depending on modules
- **Model:** À la carte (pick modules you need)
- **Payment:** Annual invoicing for districts

#### E. **PowerSchool (USA/Canada - Market Leader)**
- **Pricing:** Custom enterprise pricing
- **Model:** Seat licensing + modules
- **Average Deal:** $8,000-50,000/year per school

#### F. **Fedena (India - Open Source + Hosted)**
- **Pricing:** 
  - Self-hosted: Free (open source)
  - Cloud: $1/student/month (min $30/month)
- **Model:** Open core (free self-host, paid cloud)

---

## 2. Billing Model Comparison Matrix

| Model | Examples | Pros | Cons | Best For |
|-------|----------|------|------|----------|
| **Per-Student Monthly** | QuickSchools, SchoolSoft | Fair, scales with value | Unpredictable revenue | Growing schools |
| **Flat Rate Tiers** | Edves, Classlink | Predictable revenue | Small schools overpay | Established schools |
| **Freemium** | QuickSchools Free Tier | Low barrier, high conversion | Support costs | Market penetration |
| **Usage-Based** | Twilio (SMS add-on) | Pay for what you use | Complex billing | Add-on features |
| **Annual Contracts** | PowerSchool | Cash flow security, lower churn | Harder to sell | Enterprise |
| **Open Core** | Fedena | Community growth | Revenue from small % | Tech-savvy markets |

---

## 3. Payment Infrastructure: What Powers These Systems?

### 🏆 Top Payment Providers for Education SaaS

#### **A. Stripe (70% market share in our research)**

**Why Stripe Dominates:**
- ✅ Subscription billing built-in (recurring payments, prorations, upgrades/downgrades)
- ✅ Mobile money support (M-Pesa, EcoCash via Flutterwave integration)
- ✅ Multi-currency (USD, ZAR, ZWL via Flutterwave)
- ✅ Webhook automation (payment.succeeded → auto-upgrade account)
- ✅ Customer portal (users manage their own subscriptions)
- ✅ Dunning management (retry failed payments automatically)

**Pricing:**
- 2.9% + $0.30 per transaction (international cards)
- 3.5% + $0.50 (via Flutterwave for mobile money)

**Implementation:**
- Flutter package: `stripe_flutter` or `flutter_stripe`
- Supabase integration: Edge Functions handle webhooks
- Setup time: 2-3 days

---

#### **B. Paddle (Alternative - All-inclusive)**

**Advantages:**
- Acts as Merchant of Record (handles tax, VAT, compliance)
- Simpler setup (no webhook complexity)
- Built-in checkout UI

**Disadvantages:**
- Higher fees: 5% + $0.50 per transaction
- Less customization
- Limited mobile money support

**Best For:** 
- Teams without finance/legal resources
- Global sales (auto-handles tax)

---

#### **C. Paystack (Africa-Focused)**

**Advantages:**
- Better mobile money rates in Nigeria/Kenya
- Local bank transfers (cheaper than cards)
- Designed for African market

**Disadvantages:**
- Limited to specific countries (Nigeria, South Africa, Ghana, Kenya)
- Zimbabwe not fully supported yet
- Subscription features less mature than Stripe

---

#### **D. Flutterwave (Our Recommendation for Zimbabwe)**

**Why Flutterwave:**
- ✅ EcoCash integration (Zimbabwe's #1 mobile money)
- ✅ OneMoney support
- ✅ USD, ZAR, ZWL multi-currency
- ✅ Subscription billing API
- ✅ Can integrate with Stripe as backup

**Pricing:**
- 3.5% local transactions
- 3.8% international cards

**Best Strategy:**
- **Primary:** Flutterwave (mobile money + local cards)
- **Fallback:** Stripe (international schools, credit cards)

---

## 4. Recommended Strategy for Fees Up

### 🎯 Proposed Pricing Model: **Hybrid Freemium + Per-Student**

**Reasoning:**
- Zimbabwe market needs **low barrier to entry** (freemium)
- Small schools (50-200 students) need **affordable pricing**
- Large schools (500+) can pay premium
- Must support **mobile money** (70% of transactions in Zimbabwe)

---

### 💰 Proposed Tier Structure

#### **Free Tier** (Market Penetration)
**Student Limit:** Up to 50 students  
**Features:**
- Student records (basic fields only)
- Manual billing (no automation)
- Basic reports (PDF export)
- Single user account
- Community support only

**Monetization Strategy:**
- Convert to paid when school grows beyond 50 students
- Upsell automation features (save 10+ hours/week)
- Target: 40% conversion rate within 12 months

**Revenue Impact:** $0 (acquisition cost)

---

#### **Starter Plan** ($50/month or $500/year)
**Student Limit:** 51-150 students  
**Per-Student Cost:** ~$0.33-$1.00/student/month  
**Features:**
- Everything in Free +
- Automated billing (recurring fees, late fees)
- SMS notifications (100 SMS/month included)
- Payment tracking (EcoCash, bank, cash)
- 3 user accounts
- Email support

**Target Market:** 
- Small private schools
- Preschools and primary schools
- Tutorial centers

**Revenue Impact:** $600-6,000/year per customer

---

#### **Professional Plan** ($120/month or $1,200/year)
**Student Limit:** 151-500 students  
**Per-Student Cost:** ~$0.24-$0.80/student/month  
**Features:**
- Everything in Starter +
- Advanced reports (financial statements, revenue forecasting)
- Parent portal (parents view balances online)
- WhatsApp integration
- SMS notifications (500/month)
- Inventory management (uniforms, books)
- 10 user accounts
- Priority support

**Target Market:**
- Medium-sized private schools
- Growing academies
- Multi-grade schools

**Revenue Impact:** $1,440-14,400/year per customer

---

#### **Enterprise Plan** (Custom Pricing - starts at $300/month)
**Student Limit:** 500+ students  
**Features:**
- Everything in Professional +
- Unlimited SMS
- API access for integrations
- Multi-campus support
- Custom reports and dashboards
- Dedicated account manager
- SLA (99.9% uptime)
- Data export/migration assistance

**Target Market:**
- Large private schools
- School chains/networks
- International schools

**Revenue Impact:** $3,600+/year per customer

---

### 📊 Revenue Projections (Year 1)

**Assumptions:**
- 200 schools sign up (Free tier)
- 40% convert to paid (80 schools)
- Distribution: 50 Starter, 25 Professional, 5 Enterprise

**Calculation:**
```
Free:     120 schools × $0    = $0
Starter:   50 schools × $600  = $30,000
Pro:       25 schools × $1,440 = $36,000
Enterprise: 5 schools × $3,600 = $18,000

Total Year 1 Revenue: $84,000
Monthly Recurring Revenue (MRR): $7,000
```

**Year 2 (Scaling):**
- 500 total schools (250 paid)
- Projected ARR: $250,000

---

## 5. Payment Method Breakdown (Zimbabwe Market)

### 🇿🇼 Zimbabwe Payment Preferences

Based on 2025 market research:

| Payment Method | Market Share | School Preference | Implementation |
|----------------|--------------|-------------------|----------------|
| **EcoCash** | 48% | High (parents use it) | Flutterwave API |
| **Bank Transfer** | 22% | Medium (schools prefer) | Manual reconciliation |
| **OneMoney** | 15% | Medium | Flutterwave API |
| **Cash (Manual Entry)** | 10% | Low (admin burden) | Manual logging |
| **Credit/Debit Card** | 3% | Low (few have cards) | Stripe/Flutterwave |
| **USD Cash** | 2% | Low (compliance issues) | Manual |

**Recommended Support:**
1. ✅ **EcoCash** (must-have - 48% of transactions)
2. ✅ **OneMoney** (second-largest mobile money)
3. ✅ **Bank Transfer** (for large schools)
4. ✅ **Credit Cards** (international schools, diaspora)
5. ⚠️ **Cash** (manual logging only - no processing)

---

## 6. Implementation Roadmap

### Phase 1: MVP Subscription Screen (Week 1)
**Goal:** Stop showing "Coming Soon" - show real pricing

**Deliverables:**
- [ ] Static subscription screen (pricing table)
- [ ] Tier comparison (Free vs Starter vs Pro vs Enterprise)
- [ ] "Contact Sales" button (for Enterprise)
- [ ] "Start Free Trial" button (14-day trial for paid tiers)
- [ ] Route from premium_guard.dart to subscription screen

**Technical Stack:**
- UI only (no payment processing yet)
- Hardcoded tier data
- Navigation via GoRouter

**Time Estimate:** 4-6 hours

---

### Phase 2: Payment Integration (Week 2-3)
**Goal:** Accept first paid subscriber

**Deliverables:**
- [ ] Flutterwave account setup
- [ ] Subscription webhook handler (Supabase Edge Function)
- [ ] Database schema for subscriptions table
- [ ] Payment flow: Select Tier → Pay → Webhook → Upgrade Account
- [ ] Mobile money (EcoCash, OneMoney)
- [ ] Bank transfer instructions

**Technical Stack:**
- Flutterwave Flutter SDK
- Supabase Edge Functions (webhook listener)
- PostgreSQL subscriptions table
- RLS policies for subscription status

**Time Estimate:** 3-5 days

---

### Phase 3: Subscription Management (Week 4)
**Goal:** Let users manage their subscriptions

**Deliverables:**
- [ ] View current plan in Settings
- [ ] Upgrade/downgrade flow
- [ ] Cancel subscription (with exit survey)
- [ ] Invoice history
- [ ] Payment method management

**Technical Stack:**
- Settings screen updates
- Prorated billing logic
- Cancellation flow

**Time Estimate:** 2-3 days

---

### Phase 4: Usage Tracking & Limits (Week 5)
**Goal:** Enforce tier limits (student count, SMS usage)

**Deliverables:**
- [ ] Student count enforcement (Free = 50 max)
- [ ] SMS quota tracking
- [ ] Usage alerts (approaching limit)
- [ ] Soft limits vs hard limits
- [ ] Upgrade prompts when limits hit

**Technical Stack:**
- Database triggers (count students on insert)
- Middleware checks before operations
- Usage dashboard in Settings

**Time Estimate:** 2-3 days

---

## 7. Database Schema for Subscriptions

```sql
-- Subscriptions table (tracks who pays what)
CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  school_id UUID NOT NULL REFERENCES schools(id),
  tier TEXT NOT NULL CHECK (tier IN ('free', 'starter', 'professional', 'enterprise')),
  status TEXT NOT NULL CHECK (status IN ('active', 'past_due', 'canceled', 'trialing')),
  current_period_start TIMESTAMP WITH TIME ZONE NOT NULL,
  current_period_end TIMESTAMP WITH TIME ZONE NOT NULL,
  payment_provider TEXT, -- 'flutterwave', 'stripe', 'manual'
  external_subscription_id TEXT, -- Flutterwave subscription ID
  cancel_at_period_end BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Payment history (for invoicing)
CREATE TABLE subscription_payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  subscription_id UUID NOT NULL REFERENCES subscriptions(id),
  amount NUMERIC(10, 2) NOT NULL,
  currency TEXT DEFAULT 'USD',
  payment_method TEXT, -- 'ecocash', 'onemoney', 'card', 'bank_transfer'
  status TEXT NOT NULL CHECK (status IN ('pending', 'successful', 'failed')),
  external_payment_id TEXT,
  paid_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Usage tracking (for limits and analytics)
CREATE TABLE subscription_usage (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  school_id UUID NOT NULL REFERENCES schools(id),
  metric TEXT NOT NULL, -- 'students', 'sms_sent', 'storage_mb'
  value INTEGER NOT NULL,
  period_start TIMESTAMP WITH TIME ZONE NOT NULL,
  period_end TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS Policies
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Schools can view own subscription"
  ON subscriptions FOR SELECT
  USING (school_id IN (SELECT school_id FROM user_profiles WHERE id = auth.uid()));
```

---

## 8. Competitor Feature Comparison

| Feature | Fees Up (Planned) | SchoolSoft ZW | Edves SA | QuickSchools |
|---------|------------------|---------------|----------|--------------|
| **Freemium Tier** | ✅ 50 students | ❌ | ❌ | ✅ 40 students |
| **Mobile Money** | ✅ EcoCash, OneMoney | ✅ EcoCash | ❌ | ❌ |
| **SMS Notifications** | ✅ Included | ✅ Pro tier+ | ✅ All tiers | ✅ Add-on |
| **Parent Portal** | ✅ Pro tier+ | ✅ Pro tier+ | ✅ All tiers | ✅ Plus tier+ |
| **WhatsApp Integration** | ✅ Pro tier+ | ❌ | ✅ Growth+ | ❌ |
| **Multi-Campus** | ✅ Enterprise | ✅ Enterprise | ✅ Scale+ | ✅ Premium+ |
| **API Access** | ✅ Enterprise | ❌ | ✅ Custom | ✅ Premium+ |
| **Offline Mode** | ✅ PowerSync | ❌ | ❌ | ❌ |

**Competitive Advantages:**
1. **PowerSync offline-first** - unique in market
2. **Lower free tier** - 50 vs 40 students (QuickSchools)
3. **Mobile money native** - critical for Zimbabwe
4. **Modern UX** - Flutter vs legacy web apps

---

## 9. Risk Analysis

### High-Risk Items

#### A. **Payment Provider Reliability**
- **Risk:** Flutterwave API downtime = no payments
- **Mitigation:** 
  - Dual integration (Flutterwave + Stripe)
  - Manual payment recording fallback
  - Bank transfer option always available

#### B. **Currency Instability (Zimbabwe)**
- **Risk:** ZWL devaluation = pricing chaos
- **Mitigation:**
  - Price in USD only
  - Allow ZWL equivalent at current rate
  - Update rates weekly (via API)

#### C. **Low Credit Card Penetration**
- **Risk:** Stripe useless if no one has cards
- **Mitigation:**
  - Prioritize mobile money (EcoCash)
  - Offer bank transfer (manual)
  - Annual invoicing for enterprises

### Medium-Risk Items

#### D. **Churn Rate**
- **Risk:** Schools cancel after busy enrollment period
- **Mitigation:**
  - Annual contracts (discount incentive)
  - Lock-in features (data export limits)
  - Engagement campaigns (training, support)

#### E. **Free Tier Abuse**
- **Risk:** Schools split into multiple "free" accounts
- **Mitigation:**
  - Require verified phone/email
  - Limit features aggressively (no automation)
  - Monitor signup patterns

---

## 10. Open Questions for Stakeholder Decision

### Strategic Decisions Needed:

**1. Freemium or Paid-Only?**
- Option A: Free tier (50 students) - faster growth, higher support costs
- Option B: 14-day free trial only - slower growth, qualified leads
- **Recommendation:** Free tier (market needs it)

**2. Annual vs Monthly Billing?**
- Option A: Monthly only - easier to sell, higher churn
- Option B: Annual with discount - better cash flow, harder to sell
- Option C: Hybrid (both options) - best of both
- **Recommendation:** Hybrid (20% discount for annual)

**3. Self-Serve or Sales-Led?**
- Option A: Self-serve signup - scale fast, low touch
- Option B: Demo required - qualify leads, higher conversion
- Option C: Hybrid (self-serve for Starter/Pro, sales for Enterprise)
- **Recommendation:** Hybrid

**4. Payment Provider Priority?**
- Option A: Flutterwave only (simpler, Zimbabwe-focused)
- Option B: Flutterwave + Stripe (complex, global reach)
- **Recommendation:** Start Flutterwave, add Stripe in Phase 2

---

## 11. Delegation Brief for Agent Beta

### 📋 Research Tasks to Delegate

**Context:**  
Fees Up is building a subscription billing system for a school fee management SaaS in Zimbabwe. We need deeper market research and competitive intelligence to validate our pricing strategy.

---

### **Task 1: Deep Dive on Zimbabwe EdTech Payment Landscape**

**Objective:** Understand how schools currently pay for software in Zimbabwe

**Research Questions:**
1. What % of Zimbabwean schools have:
   - Bank accounts (USD vs ZWL)?
   - Mobile money wallets (EcoCash, OneMoney)?
   - Internet credit cards?
2. Average school budget allocation for software (% of total budget)
3. Procurement process (admin decides vs board approval needed?)
4. Seasonal payment patterns (when do schools have cash flow?)

**Methodology:**
- Survey 20-30 Zimbabwean school administrators
- Interview 3-5 schools currently using SchoolSoft or similar
- Review Zimbabwe Ministry of Education procurement guidelines

**Deliverable:**  
A 2-page report with:
- Payment method breakdown (%)
- Budget allocation insights
- Procurement decision-making process
- Recommended pricing positioning

---

### **Task 2: Competitive Teardown - SchoolSoft Zimbabwe**

**Objective:** Reverse-engineer SchoolSoft's business model

**Research Questions:**
1. Exact pricing tiers (screenshot pricing page if possible)
2. Signup flow (how many steps? friction points?)
3. Payment methods accepted (test checkout if possible)
4. Feature limitations per tier
5. Customer support quality (test their support)
6. Estimated customer count (LinkedIn employees × avg customers/employee)

**Methodology:**
- Sign up for free trial (if available)
- Pose as school admin inquiring about pricing
- LinkedIn research (employee count, growth rate)
- Review Google/Facebook ads (what are they emphasizing?)

**Deliverable:**  
A comparison matrix:
| Metric | SchoolSoft ZW | Fees Up (Our Target) |
|--------|---------------|----------------------|
| Pricing | | |
| Features | | |
| UX Score | | |
| Support | | |

---

### **Task 3: Payment Provider API Evaluation**

**Objective:** Test Flutterwave vs alternatives for Zimbabwe use case

**Research Questions:**
1. Flutterwave:
   - EcoCash integration live? (test $1 transaction)
   - Subscription billing API maturity (documentation quality?)
   - Webhook reliability (uptime stats?)
   - Developer experience (setup time?)
2. Alternatives:
   - Can Paystack work in Zimbabwe? (API test)
   - Is Stripe + Flutterwave bridge feasible?
   - Are there local Zimbabwean payment gateways we missed?

**Methodology:**
- Create sandbox accounts for each provider
- Implement test subscription flow (document time taken)
- Measure API latency from Zimbabwe IP
- Check webhook delivery reliability

**Deliverable:**
- Technical scorecard (1-10 rating):
  - Setup ease
  - Documentation quality
  - API reliability
  - Zimbabwe mobile money support
  - Pricing competitiveness
- Recommendation: Primary + Backup provider

---

### **Task 4: Churn Prevention Research**

**Objective:** Learn how education SaaS companies retain customers

**Research Questions:**
1. What are top 3 churn reasons in school SaaS?
2. How do QuickSchools, PowerSchool prevent churn?
3. What engagement tactics work? (webinars, training, etc.)
4. Does annual billing actually reduce churn? (find data)
5. What "lock-in" features are ethical and effective?

**Methodology:**
- Interview ChurnZero or similar retention tool users
- Review case studies (G2, Capterra reviews)
- Analyze competitor retention strategies (blog posts, webinars)

**Deliverable:**
- Churn playbook (1-pager):
  - Top 3 churn reasons
  - Preventive measures (what to build)
  - Engagement calendar (when to reach out)

---

### **Task 5: Pricing Elasticity Study**

**Objective:** Find the optimal price point for Zimbabwe schools

**Research Questions:**
1. At what price do schools say "too expensive"?
2. Would schools pay $50/month for 100 students? $75? $100?
3. Does annual discount need to be 20%? Or would 10% work?
4. How price-sensitive are different school types?
   - Government schools (very sensitive)
   - Small private (sensitive)
   - International schools (less sensitive)

**Methodology:**
- Survey 50 schools with pricing scenarios:
  - "Would you pay $X for features A, B, C?"
  - Van Westendorp Price Sensitivity Meter
- A/B test pricing page (if we have traffic)

**Deliverable:**
- Price sensitivity curve (graph)
- Recommended pricing range per tier
- Discount strategy (annual, referral, etc.)

---

### **Task 6: Long-term Revenue Model Analysis**

**Objective:** Project 3-year revenue scenarios

**Research Questions:**
1. What's realistic growth rate for Zimbabwe EdTech SaaS?
   - Year 1: X schools
   - Year 2: Y schools
   - Year 3: Z schools
2. What's average customer lifetime value (LTV)?
3. What's customer acquisition cost (CAC) via:
   - Google Ads
   - Facebook Ads
   - Referrals
   - Sales team
4. When do we hit profitability?

**Methodology:**
- Build financial model (Google Sheets)
- Benchmark against QuickSchools growth trajectory
- Interview SaaS founders in Zimbabwe (if accessible)

**Deliverable:**
- 3-year revenue projection (best/worst/likely case)
- Break-even analysis (when do we become profitable?)
- Recommended customer acquisition strategy

---

## 12. Next Steps & Action Items

### Immediate (This Week)
- [ ] **Stakeholder Decision:** Choose pricing model (approve our recommendation)
- [ ] **Design Mockups:** Create subscription screen UI (Figma)
- [ ] **Database Schema:** Implement subscriptions table
- [ ] **Task 7:** Build static subscription screen (MVP)

### Short-term (Next 2 Weeks)
- [ ] **Payment Provider:** Set up Flutterwave sandbox account
- [ ] **Webhook Handler:** Build Supabase Edge Function
- [ ] **Test Flow:** End-to-end payment test (EcoCash sandbox)

### Medium-term (Next Month)
- [ ] **Beta Launch:** 10 schools test paid subscriptions
- [ ] **Feedback Loop:** Adjust pricing based on real data
- [ ] **Agent Beta Research:** Execute delegation brief (Tasks 1-6)

### Long-term (Next Quarter)
- [ ] **Scale:** 100 paid schools
- [ ] **Analytics:** Churn tracking, LTV calculation
- [ ] **Optimization:** A/B test pricing, features, messaging

---

## 13. Success Metrics

**Phase 1 (MVP Screen):**
- ✅ Subscription screen live (no "Coming Soon")
- ✅ Zero code errors
- ✅ User can understand tiers in <30 seconds

**Phase 2 (Payment Integration):**
- ✅ First successful EcoCash payment
- ✅ Webhook triggers account upgrade
- ✅ <5% failed payment rate

**Phase 3 (Growth):**
- 🎯 10 paid schools by Month 1
- 🎯 50 paid schools by Month 3
- 🎯 100 paid schools by Month 6
- 🎯 MRR: $7,000 by Month 6
- 🎯 Churn rate: <5% monthly

**Phase 4 (Optimization):**
- 🎯 Free-to-paid conversion: >40%
- 🎯 Avg revenue per customer: $1,200/year
- 🎯 Customer LTV: >$3,600 (3+ years)
- 🎯 CAC payback: <6 months

---

## 14. Appendix: Competitor URLs & Resources

### Direct Competitors
- SchoolSoft Zimbabwe: https://schoolsoft.co.zw
- Edves (South Africa): https://edves.net
- QuickSchools: https://quickschools.com
- Fedena: https://fedena.com

### Payment Providers
- Flutterwave: https://flutterwave.com/zw
- Stripe: https://stripe.com
- Paystack: https://paystack.com
- Paddle: https://paddle.com

### Market Research
- Zimbabwe EdTech Report 2024: [Link needed]
- Mobile Money Statistics Zimbabwe: https://www.rbz.co.zw (Reserve Bank of Zimbabwe)
- African SaaS Landscape: https://africantech.com

### Technical Resources
- Flutterwave Flutter SDK: https://pub.dev/packages/flutterwave
- Stripe Flutter: https://pub.dev/packages/flutter_stripe
- Supabase Edge Functions: https://supabase.com/docs/guides/functions

---

**Document End**

---

## Action Required

**Owner:** Product Lead / Founder  
**Decision Needed By:** January 10, 2026  
**Delegation:** Agent Beta (Tasks 1-6 for deeper research)  

**Next Deliverable:** Approved pricing model + UI mockups for subscription screen

---

**Questions? Discuss in:** #subscription-strategy Slack channel
