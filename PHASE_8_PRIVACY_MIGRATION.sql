-- ============================================
-- PHASE 8: FRIEND PROFILE & PRIVACY SYSTEM
-- Simple 2-Level Privacy (public/private)
-- ============================================

-- 1. Add privacy column to journals table
-- Default: 'public' (friends can see)
-- Options: 'public' or 'private' (only owner can see)
ALTER TABLE journals 
ADD COLUMN IF NOT EXISTS privacy VARCHAR(20) DEFAULT 'public' 
CHECK (privacy IN ('public', 'private'));

-- 2. Create indexes for performance
-- Index on privacy column for faster filtering
CREATE INDEX IF NOT EXISTS idx_journals_privacy ON journals(privacy);

-- Composite index for user_id + privacy (optimal for queries)
CREATE INDEX IF NOT EXISTS idx_journals_user_privacy ON journals(user_id, privacy);

-- 3. Set all existing journals to 'public' (backward compatibility)
UPDATE journals 
SET privacy = 'public' 
WHERE privacy IS NULL;

-- 4. Verify the changes
DO $$ 
DECLARE
  total_journals INTEGER;
  public_journals INTEGER;
  private_journals INTEGER;
BEGIN 
  -- Count journals
  SELECT COUNT(*) INTO total_journals FROM journals;
  SELECT COUNT(*) INTO public_journals FROM journals WHERE privacy = 'public';
  SELECT COUNT(*) INTO private_journals FROM journals WHERE privacy = 'private';
  
  -- Display results
  RAISE NOTICE '============================================';
  RAISE NOTICE '✅ Phase 8: Privacy System Migration Complete!';
  RAISE NOTICE '============================================';
  RAISE NOTICE '';
  RAISE NOTICE '📊 Statistics:';
  RAISE NOTICE '   Total Journals: %', total_journals;
  RAISE NOTICE '   Public Journals: %', public_journals;
  RAISE NOTICE '   Private Journals: %', private_journals;
  RAISE NOTICE '';
  RAISE NOTICE '🔧 Schema Changes:';
  RAISE NOTICE '   ✓ privacy column added (VARCHAR(20))';
  RAISE NOTICE '   ✓ Default value: public';
  RAISE NOTICE '   ✓ Check constraint: (public, private)';
  RAISE NOTICE '';
  RAISE NOTICE '⚡ Performance:';
  RAISE NOTICE '   ✓ idx_journals_privacy created';
  RAISE NOTICE '   ✓ idx_journals_user_privacy created';
  RAISE NOTICE '';
  RAISE NOTICE '🎉 Ready to use!';
  RAISE NOTICE '============================================';
END $$;

-- ============================================
-- VERIFICATION QUERIES (Optional - for testing)
-- ============================================

-- Check if privacy column exists
-- SELECT column_name, data_type, column_default 
-- FROM information_schema.columns 
-- WHERE table_name = 'journals' AND column_name = 'privacy';

-- Check privacy distribution
-- SELECT privacy, COUNT(*) as count 
-- FROM journals 
-- GROUP BY privacy;

-- Check indexes
-- SELECT indexname, indexdef 
-- FROM pg_indexes 
-- WHERE tablename = 'journals' 
-- AND indexname LIKE '%privacy%';
