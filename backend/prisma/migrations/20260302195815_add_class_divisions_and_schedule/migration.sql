-- CreateEnum
CREATE TYPE "ClassDivisionStatus" AS ENUM ('ACTIVE', 'INACTIVE');

-- AlterTable
ALTER TABLE "students" ADD COLUMN     "class_division_id" INTEGER;

-- CreateTable
CREATE TABLE "class_divisions" (
    "id" SERIAL NOT NULL,
    "course_id" INTEGER NOT NULL,
    "section_name" VARCHAR(10) NOT NULL,
    "teacher_id" INTEGER,
    "max_capacity" INTEGER NOT NULL DEFAULT 50,
    "room_number" VARCHAR(50),
    "schedule" VARCHAR(200),
    "status" "ClassDivisionStatus" NOT NULL DEFAULT 'ACTIVE',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "class_divisions_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "class_divisions_course_id_section_name_key" ON "class_divisions"("course_id", "section_name");

-- AddForeignKey
ALTER TABLE "students" ADD CONSTRAINT "students_class_division_id_fkey" FOREIGN KEY ("class_division_id") REFERENCES "class_divisions"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "class_divisions" ADD CONSTRAINT "class_divisions_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "courses"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "class_divisions" ADD CONSTRAINT "class_divisions_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "teachers"("id") ON DELETE SET NULL ON UPDATE CASCADE;
