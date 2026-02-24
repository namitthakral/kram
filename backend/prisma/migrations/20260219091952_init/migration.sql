-- DropIndex
DROP INDEX "idx_academic_records_grade_points";

-- DropIndex
DROP INDEX "idx_academic_records_student_semester";

-- DropIndex
DROP INDEX "idx_assignments_subject_section";

-- DropIndex
DROP INDEX "idx_attendance_section_date";

-- DropIndex
DROP INDEX "idx_attendance_status";

-- DropIndex
DROP INDEX "idx_attendance_student_date";

-- DropIndex
DROP INDEX "idx_attendance_student_section";

-- DropIndex
DROP INDEX "idx_read_receipts_communication";

-- DropIndex
DROP INDEX "idx_read_receipts_lookup";

-- DropIndex
DROP INDEX "idx_read_receipts_read_at";

-- DropIndex
DROP INDEX "idx_read_receipts_user";

-- DropIndex
DROP INDEX "idx_communications_creator";

-- DropIndex
DROP INDEX "idx_communications_institution";

-- DropIndex
DROP INDEX "idx_communications_priority";

-- DropIndex
DROP INDEX "idx_communications_publish_date";

-- DropIndex
DROP INDEX "idx_communications_status";

-- DropIndex
DROP INDEX "idx_communications_target_audience";

-- DropIndex
DROP INDEX "idx_communications_type";

-- DropIndex
DROP INDEX "idx_enrollments_student_semester";

-- DropIndex
DROP INDEX "idx_enrollments_subject_semester";

-- DropIndex
DROP INDEX "idx_exam_results_student";

-- DropIndex
DROP INDEX "idx_examinations_subject_semester";

-- DropIndex
DROP INDEX "idx_fee_structures_academic_year";

-- DropIndex
DROP INDEX "idx_fee_structures_course";

-- DropIndex
DROP INDEX "idx_fee_structures_institution";

-- DropIndex
DROP INDEX "idx_fee_structures_type_status";

-- DropIndex
DROP INDEX "idx_payments_date";

-- DropIndex
DROP INDEX "idx_payments_method";

-- DropIndex
DROP INDEX "idx_payments_mode";

-- DropIndex
DROP INDEX "idx_payments_status";

-- DropIndex
DROP INDEX "idx_payments_student";

-- DropIndex
DROP INDEX "idx_payments_student_status_date";

-- DropIndex
DROP INDEX "idx_rooms_active";

-- DropIndex
DROP INDEX "idx_rooms_institution";

-- DropIndex
DROP INDEX "idx_rooms_type";

-- DropIndex
DROP INDEX "idx_student_fees_due_date";

-- DropIndex
DROP INDEX "idx_student_fees_lookup";

-- DropIndex
DROP INDEX "idx_student_fees_status";

-- DropIndex
DROP INDEX "idx_student_fees_structure";

-- DropIndex
DROP INDEX "idx_student_fees_student";

-- DropIndex
DROP INDEX "idx_student_fees_student_status";

-- DropIndex
DROP INDEX "idx_submissions_student_status";

-- DropIndex
DROP INDEX "idx_time_slots_institution";

-- DropIndex
DROP INDEX "idx_time_slots_sort";

-- DropIndex
DROP INDEX "idx_timetable_academic_year";

-- DropIndex
DROP INDEX "idx_timetable_day";

-- DropIndex
DROP INDEX "idx_timetable_institution";

-- DropIndex
DROP INDEX "idx_timetable_semester";

-- DropIndex
DROP INDEX "idx_timetable_subject";

-- DropIndex
DROP INDEX "idx_timetable_subject_lookup";

-- DropIndex
DROP INDEX "idx_timetable_teacher";

-- DropIndex
DROP INDEX "idx_timetable_teacher_lookup";

-- DropIndex
DROP INDEX "idx_timetable_time_slot";

-- DropEnum
DROP TABLE IF EXISTS "performance_metrics" CASCADE;
DROP TYPE "MetricType";

-- CreateTable
CREATE TABLE "question_papers" (
    "id" SERIAL NOT NULL,
    "examination_id" INTEGER NOT NULL,
    "title" VARCHAR(200) NOT NULL,
    "instructions" TEXT,
    "total_marks" INTEGER NOT NULL,
    "total_questions" INTEGER NOT NULL DEFAULT 0,
    "created_by" INTEGER NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'DRAFT',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "question_papers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "question_paper_sections" (
    "id" SERIAL NOT NULL,
    "question_paper_id" INTEGER NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "sort_order" INTEGER NOT NULL,

    CONSTRAINT "question_paper_sections_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "questions" (
    "id" SERIAL NOT NULL,
    "section_id" INTEGER NOT NULL,
    "text" TEXT NOT NULL,
    "marks" INTEGER NOT NULL,
    "question_type" TEXT NOT NULL,
    "sort_order" INTEGER NOT NULL,

    CONSTRAINT "questions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "question_options" (
    "id" SERIAL NOT NULL,
    "question_id" INTEGER NOT NULL,
    "text" TEXT NOT NULL,
    "is_correct" BOOLEAN NOT NULL DEFAULT false,
    "sort_order" INTEGER NOT NULL,

    CONSTRAINT "question_options_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "question_papers_examination_id_key" ON "question_papers"("examination_id");

-- AddForeignKey
ALTER TABLE "question_papers" ADD CONSTRAINT "question_papers_examination_id_fkey" FOREIGN KEY ("examination_id") REFERENCES "examinations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "question_papers" ADD CONSTRAINT "question_papers_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "teachers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "question_paper_sections" ADD CONSTRAINT "question_paper_sections_question_paper_id_fkey" FOREIGN KEY ("question_paper_id") REFERENCES "question_papers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "questions" ADD CONSTRAINT "questions_section_id_fkey" FOREIGN KEY ("section_id") REFERENCES "question_paper_sections"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "question_options" ADD CONSTRAINT "question_options_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "questions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- RenameIndex
ALTER INDEX "unique_communication_read" RENAME TO "communication_read_receipts_communication_id_user_id_key";
