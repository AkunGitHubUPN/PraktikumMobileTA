#!/usr/bin/env bash

# Script untuk update nama bucket di semua file

# CARA PAKAI:
# 1. Edit BUCKET_NAME_BARU di bawah ini sesuai nama bucket Anda
# 2. Jalankan: bash update_bucket_name.sh

# ====== EDIT INI ======
BUCKET_NAME_BARU="journal-photos"
# ======================

echo "🔄 Updating bucket name to: $BUCKET_NAME_BARU"

# Update di supabase_helper.dart
sed -i "s/from('journal-photos')/from('$BUCKET_NAME_BARU')/g" lib/helpers/supabase_helper.dart

echo "✅ Done! Bucket name updated to: $BUCKET_NAME_BARU"
echo "📝 Files updated:"
echo "  - lib/helpers/supabase_helper.dart"
