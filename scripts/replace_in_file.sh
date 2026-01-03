#!/bin/bash
# replace_in_file.sh - Safe string replacement with verification
# Usage: ./replace_in_file.sh <file_path> <search_string> <replace_string>

set -euo pipefail

# Validate arguments
if [ $# -ne 3 ]; then
    echo "❌ Usage: $0 <file_path> <search_string> <replace_string>"
    echo "   Example: ./replace_in_file.sh lib/main.dart \"print(\" \"debugPrint(\""
    exit 1
fi

file_path="$1"
search_str="$2"
replace_str="$3"

# Verify file exists
if [ ! -f "$file_path" ]; then
    echo "❌ File not found: $file_path"
    exit 1
fi

# Escape special characters for Perl
escaped_search=$(printf '%s' "$search_str" | perl -pe 's/([\\\$])/\\$1/g')
escaped_replace=$(printf '%s' "$replace_str" | perl -pe 's/([\\\$@])/\\$1/g')

# Count occurrences BEFORE replacement
count=$(perl -nle '
    BEGIN { $search = quotemeta($ENV{"search_str"}); }
    $count += () = /\Q$search\E/g;
    END { print $count }
' < "$file_path")

# Perform replacement
perl -i -pe '
    BEGIN {
        $search = quotemeta($ENV{"search_str"});
        $replace = $ENV{"replace_str"};
    }
    s/\Q$search\E/$replace/g;
' "$file_path"

# Verify replacement count
new_count=$(perl -nle '
    BEGIN { $search = quotemeta($ENV{"replace_str"}); }
    $count += () = /\Q$search\E/g;
    END { print $count }
' < "$file_path")

# Output results
echo -e "\n✅ SUCCESS: $file_path"
echo "🔍 Found: $count occurrences of '$search_str'"
echo "✏️  Replaced with: '$replace_str'"
echo "📊 Verification: $new_count matches found post-replacement"