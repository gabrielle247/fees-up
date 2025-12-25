.PHONY: help run run-verbose clean-run stop analyze format test dev-menu quick-run logs backup-lib commit push force lib save-point fresh-start setup-repo

help:
	@echo "╔════════════════════════════════════════════════════════════════╗"
	@echo "║                       FEES-UP DEVELOPMENT COMMANDS             ║"
	@echo "╚════════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "Quick Start:"
	@echo "  make run              - Run app on Linux (hot reload)"
	@echo "  make setup-repo       - Initialize Git & link GitHub repo"
	@echo ""
	@echo "🛡️ Safety & Git:"
	@echo "  make save-point       - Commit & Push EVERYTHING (Your safety net)"
	@echo "  make fresh-start      - Save current state & switch to new branch"
	@echo "  make commit g='...'   - Standard commit & push"
	@echo "  make force g='...'    - Force push (Be careful)"
	@echo ""
	@echo "Running:"
	@echo "  make run              - Run on Linux"
	@echo "  make run-verbose      - Run with logs"
	@echo "  make quick-run        - Restart app"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean            - Clean build"
	@echo "  make stop             - Kill processes"
	@echo "  make lib              - Map all Dart files"
	@echo ""

# --- 🚀 RUNNING ---
run:
	@if [ -f "assets/keys.env" ]; then \
		export $$(cat assets/keys.env | grep -v '^#' | xargs); \
	fi; \
	flutter run -d linux \
		--dart-define=SUPABASE_URL="$${SUPABASE_URL}" \
		--dart-define=SUPABASE_ANON_KEY="$${SUPABASE_ANON_KEY}" \
		--dart-define=POWERSYNC_ENDPOINT_URL="$${POWERSYNC_ENDPOINT_URL}" \
		--dart-define=POWERSYNC_API_KEY="$${POWERSYNC_API_KEY}" \
		--dart-define=ENVIRONMENT=development

run-verbose:
	@if [ -f "assets/keys.env" ]; then \
		export $$(cat assets/keys.env | grep -v '^#' | xargs); \
	fi; \
	flutter run -d linux \
		--dart-define=SUPABASE_URL="$${SUPABASE_URL}" \
		--dart-define=SUPABASE_ANON_KEY="$${SUPABASE_ANON_KEY}" \
		--dart-define=POWERSYNC_ENDPOINT_URL="$${POWERSYNC_ENDPOINT_URL}" \
		--dart-define=POWERSYNC_API_KEY="$${POWERSYNC_API_KEY}" \
		--dart-define=ENVIRONMENT=development \
		--verbose

quick-run: stop run

stop:
	@echo "🛑 Stopping all Flutter processes..."
	@pkill -f "flutter run" || true
	@pkill -f "flutter.*linux" || true
	@sleep 1
	@echo "✅ Done"

clean:
	@echo "🧹 Cleaning Flutter build..."
	flutter clean

# --- 🛡️ SAFETY COMMANDS ---

# 0. SETUP REPO: Ensures Git is init, branch is main, and remote is linked
setup-repo:
	@echo "🔗 Configuring repository..."
	@git init -q
	@git branch -M main
	@if ! git remote | grep -q "^origin$$"; then \
		echo "🌐 Adding remote origin..."; \
		git remote add origin https://github.com/gabrielle247/fees-up.git; \
	else \
		echo "🔄 Ensuring remote origin URL is correct..."; \
		git remote set-url origin https://github.com/gabrielle247/fees-up.git; \
	fi
	@echo "✅ Repository linked: https://github.com/gabrielle247/fees-up/"

# 1. SAVE POINT: Locks in your current progress
# Dependencies: setup-repo (ensures we have a place to push to)
save-point: setup-repo
	@echo "💾 Creating a SAFETY CHECKPOINT..."
	@git add .
	@git commit -m "SAFE POINT: $$(date +'%Y-%m-%d %H:%M:%S') - Checkpoint" || echo "Nothing to commit."
	@echo "🚀 Pushing to remote..."
	@git push -u origin main
	@echo "✅ Safe Point Established."

# 2. FRESH START: Saves current work, then moves you to a new branch
fresh-start: save-point
	@echo "🌱 Starting fresh workspace..."
	$(eval BRANCH := $(if $(b),$(b),ui-revamp-$(shell date +'%Y%m%d')))
	@git checkout -b $(BRANCH)
	@echo "✅ You are now on branch '$(BRANCH)'."
	@echo "   The 'main' branch is safe and untouched."

# --- 🔧 UTILS ---

commit: setup-repo
	@if [ -z "$(g)" ] && [ -z "$(MSG)" ]; then \
		echo "❌ Error: Commit message is required. Use g='message'"; \
		exit 1; \
	fi
	@echo "📝 Committing..."
	@git add .
	@git commit -m "$(if $(g),$(g),$(MSG))"
	@git push origin main
	@echo "✅ Done!"

force: setup-repo
	@if [ -n "$(g)" ]; then \
		git add . && git commit -m "$(g)"; \
	fi
	@echo "💪 Force pushing..."
	@git push origin main --force
	@echo "✅ Done!"

lib:
	@echo "📁 Mapping lib directory..."
	@find lib -name "*.dart" -exec sh -c 'echo "// {}" ; cat {}' \; > lib_dart_files.txt 2>/dev/null || true
	@echo "✅ Created lib_dart_files.txt"

.DEFAULT_GOAL := help