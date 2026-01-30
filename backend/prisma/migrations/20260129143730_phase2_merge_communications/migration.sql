-- Phase 2: Merge notices and announcements into unified communications table

-- Step 1: Create new enums for unified communications
CREATE TYPE "CommunicationType" AS ENUM ('GENERAL', 'ACADEMIC', 'EXAMINATION', 'ADMISSION', 'EVENT', 'HOLIDAY', 'EMERGENCY', 'MAINTENANCE', 'ACHIEVEMENT', 'ALERT');
CREATE TYPE "CommunicationPriority" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'URGENT');

-- Step 2: Create the new communications table
CREATE TABLE "communications" (
    "id" SERIAL NOT NULL,
    "institution_id" INTEGER NOT NULL,
    "title" VARCHAR(200) NOT NULL,
    "content" TEXT NOT NULL,
    "communication_type" "CommunicationType" NOT NULL,
    "priority" "CommunicationPriority" NOT NULL DEFAULT 'MEDIUM',
    "targetAudience" TEXT[],
    "department_ids" INTEGER[],
    "program_ids" INTEGER[],
    "class_ids" INTEGER[],
    "is_emergency" BOOLEAN NOT NULL DEFAULT false,
    "is_pinned" BOOLEAN NOT NULL DEFAULT false,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "attachment_url" VARCHAR(500),
    "publish_date" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiry_date" TIMESTAMP(3),
    "created_by" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "communications_pkey" PRIMARY KEY ("id")
);

-- Step 3: Create the new communication_read_receipts table
CREATE TABLE "communication_read_receipts" (
    "id" SERIAL NOT NULL,
    "communication_id" INTEGER NOT NULL,
    "user_id" INTEGER NOT NULL,
    "read_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "communication_read_receipts_pkey" PRIMARY KEY ("id")
);

-- Step 4: Migrate data from notices to communications
INSERT INTO "communications" (
    "institution_id",
    "title",
    "content",
    "communication_type",
    "priority",
    "targetAudience",
    "department_ids",
    "program_ids",
    "class_ids",
    "is_emergency",
    "is_pinned",
    "is_active",
    "attachment_url",
    "publish_date",
    "expiry_date",
    "created_by",
    "created_at",
    "updated_at"
)
SELECT 
    n."institution_id",
    n."title",
    n."content",
    n."notice_type"::"text"::"CommunicationType",  -- Cast from NoticeType to CommunicationType
    n."priority"::"text"::"CommunicationPriority", -- Cast from NoticePriority to CommunicationPriority
    n."targetAudience",
    n."department_ids",
    n."program_ids",
    n."class_ids",
    CASE WHEN n."notice_type" = 'EMERGENCY' THEN true ELSE false END, -- Set is_emergency based on type
    n."is_pinned",
    n."is_active",
    n."attachment_url",
    n."publish_date",
    n."expiry_date",
    n."created_by",
    n."created_at",
    n."updated_at"
FROM "notices" n;

-- Step 5: Store the mapping of old notice IDs to new communication IDs
CREATE TEMP TABLE notice_id_mapping AS
SELECT 
    n.id as old_notice_id,
    c.id as new_communication_id
FROM "notices" n
JOIN "communications" c ON 
    c.title = n.title 
    AND c.created_by = n.created_by 
    AND c.created_at = n.created_at;

-- Step 6: Migrate data from announcements to communications
INSERT INTO "communications" (
    "institution_id",
    "title",
    "content",
    "communication_type",
    "priority",
    "targetAudience",
    "department_ids",
    "program_ids",
    "class_ids",
    "is_emergency",
    "is_pinned",
    "is_active",
    "attachment_url",
    "publish_date",
    "expiry_date",
    "created_by",
    "created_at",
    "updated_at"
)
SELECT 
    a."institution_id",
    a."title",
    a."content",
    a."announcement_type"::"text"::"CommunicationType",  -- Cast from AnnouncementType to CommunicationType
    a."priority"::"text"::"CommunicationPriority",      -- Cast from NoticePriority to CommunicationPriority
    a."targetAudience",
    ARRAY[]::INTEGER[],  -- Empty array for department_ids (not in announcements)
    ARRAY[]::INTEGER[],  -- Empty array for program_ids (not in announcements)
    ARRAY[]::INTEGER[],  -- Empty array for class_ids (not in announcements)
    a."is_emergency",
    false,               -- is_pinned (not in announcements)
    a."is_active",
    a."attachment_url",
    a."publish_date",
    a."expiry_date",
    a."created_by",
    a."created_at",
    a."updated_at"
FROM "announcements" a;

-- Step 7: Migrate notice_read_receipts to communication_read_receipts
INSERT INTO "communication_read_receipts" (
    "communication_id",
    "user_id",
    "read_at"
)
SELECT 
    nim.new_communication_id,
    nrr.user_id,
    nrr.read_at
FROM "notice_read_receipts" nrr
JOIN notice_id_mapping nim ON nrr.notice_id = nim.old_notice_id;

-- Step 8: Add foreign key constraints
ALTER TABLE "communications" ADD CONSTRAINT "communications_institution_id_fkey" FOREIGN KEY ("institution_id") REFERENCES "institutions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "communications" ADD CONSTRAINT "communications_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "communication_read_receipts" ADD CONSTRAINT "communication_read_receipts_communication_id_fkey" FOREIGN KEY ("communication_id") REFERENCES "communications"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "communication_read_receipts" ADD CONSTRAINT "communication_read_receipts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- Step 9: Add unique constraint for read receipts
CREATE UNIQUE INDEX "unique_communication_read" ON "communication_read_receipts"("communication_id", "user_id");

-- Step 10: Drop old tables
DROP TABLE "notice_read_receipts";
DROP TABLE "notices";
DROP TABLE "announcements";

-- Step 11: Drop old enums
DROP TYPE "NoticeType";
DROP TYPE "AnnouncementType";
DROP TYPE "NoticePriority";

