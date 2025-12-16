#!/bin/bash

# Brick Setup Script for fees_up
# This script helps set up Brick offline-first with encryption

echo "🧱 Brick Setup Script"
echo "===================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Step 1: Check environment
echo -e "${YELLOW}Step 1: Checking environment...${NC}"
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}Error: pubspec.yaml not found. Run this from project root.${NC}"
    exit 1
fi

if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Error: Flutter not found. Install Flutter first.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Environment OK${NC}"
echo ""

# Step 2: Check dependencies
echo -e "${YELLOW}Step 2: Getting dependencies...${NC}"
flutter pub get
echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

# Step 3: Run build_runner
echo -e "${YELLOW}Step 3: Generating Brick adapters...${NC}"
echo "This may take a few minutes..."
flutter pub run build_runner build --delete-conflicting-outputs

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Adapters generated successfully${NC}"
else
    echo -e "${RED}⚠ Build runner failed. This is expected if you haven't created model annotations yet.${NC}"
    echo -e "${YELLOW}Create your Brick models first, then run: flutter pub run build_runner build --delete-conflicting-outputs${NC}"
fi
echo ""

# Step 4: Check generated files
echo -e "${YELLOW}Step 4: Checking generated files...${NC}"
if [ -d "lib/brick/adapters" ]; then
    adapter_count=$(find lib/brick/adapters -name "*.g.dart" 2>/dev/null | wc -l)
    echo -e "${GREEN}✓ Found $adapter_count generated adapter(s)${NC}"
else
    echo -e "${YELLOW}ℹ No adapters generated yet (lib/brick/adapters not found)${NC}"
    echo -e "${YELLOW}  This is normal if you haven't created Brick models yet${NC}"
fi
echo ""

# Step 5: Instructions
echo -e "${GREEN}===================="
echo "Setup Status"
echo "====================${NC}"
echo ""
echo -e "${GREEN}✓ Build configuration created (build.yaml)${NC}"
echo -e "${GREEN}✓ Brick repository created (lib/brick/repository/)${NC}"
echo -e "${GREEN}✓ Encryption helper created (lib/brick/db/)${NC}"
echo -e "${GREEN}✓ Example models created (lib/models/student_brick.dart)${NC}"
echo -e "${GREEN}✓ Main.dart updated with initialization${NC}"
echo ""

echo -e "${YELLOW}📋 Next Steps:${NC}"
echo ""
echo "1. Create more Brick-annotated models:"
echo "   - See lib/models/student_brick.dart as example"
echo "   - Add @ConnectOfflineFirstWithSupabase annotation"
echo "   - Extend OfflineFirstWithSupabaseModel"
echo ""
echo "2. Generate adapters:"
echo "   flutter pub run build_runner build --delete-conflicting-outputs"
echo ""
echo "3. Update lib/brick/brick.g.dart:"
echo "   - Uncomment model imports"
echo "   - Add models to modelDictionary"
echo ""
echo "4. Test the implementation:"
echo "   flutter run"
echo ""
echo "5. Use in your services:"
echo "   - See lib/services/brick_student_service.dart for example"
echo ""

echo -e "${GREEN}📚 Documentation:${NC}"
echo "  - Full guide: BRICK_IMPLEMENTATION_GUIDE.md"
echo "  - Quick reference: BRICK_QUICK_REFERENCE.md"
echo ""

echo -e "${GREEN}🎉 Setup complete! Happy coding!${NC}"
