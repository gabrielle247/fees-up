#!/bin/bash

echo "🎨 Starting Opacity Fixer..."

# 1. Fix the Unused Variable in dashboard_provider.dart if it exists
if [ -f "lib/data/providers/dashboard_provider.dart" ]; then
    sed -i "s/final stream = DatabaseService().db.watch('SELECT 1');/\/\/ Stream removed to fix lint/" "lib/data/providers/dashboard_provider.dart"
    echo "   - Fixed dashboard_provider.dart lint"
fi

# 2. Replace .withOpacity(x) with .withAlpha(x * 255) across ALL files in lib/
# We use perl to find the decimal, multiply by 255, and round to an integer.
find lib -name "*.dart" -type f -exec perl -i -pe 's/\.withOpacity\(\s*([\d\.]+)\s*\)/".withAlpha(" . int($1 * 255) . ")"/ge' {} +

echo "✅ Fixes applied: Unused stream removed & withOpacity converted to withAlpha across lib/."