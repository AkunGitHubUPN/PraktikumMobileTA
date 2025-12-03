#!/bin/bash

# Script untuk update nama bucket dari journal-photos ke journal-photos-v2

echo "🔄 Updating bucket name from 'journal-photos' to 'journal-photos-v2'..."

# Update di supabase_helper.dart
sed -i "s/from('journal-photos')/from('journal-photos-v2')/g" lib/helpers/supabase_helper.dart

echo "✅ Done! Bucket name updated."
echo ""
echo "📝 Updated files:"
echo "  - lib/helpers/supabase_helper.dart"
echo ""
echo "🎯 Next steps:"
echo "1. Delete old bucket 'journal-photos' in Supabase Dashboard"
echo "2. Create new bucket 'journal-photos-v2' with 'Public bucket' ENABLED"
echo "3. Hot restart Flutter app"
echo "4. Test upload!"
