import { PrismaClient } from '@prisma/client'
import * as bcrypt from 'bcryptjs'
import { generateEdVerseId } from '../src/utils/edverse-id.util'

const prisma = new PrismaClient()

async function main() {
  console.log('🌱 Starting comprehensive database seeding...')

  // Create roles
  console.log('Creating roles...')
  const roles = await createRoles()
  console.log(`✅ Created ${roles.length} roles`)

  // Create sample institution
  console.log('Creating sample institution...')
  const institution = await createInstitution()
  console.log(`✅ Created institution: ${institution.name}`)

  // Create academic year and semesters
  console.log('Creating academic year and semesters...')
  const { academicYear, semesters } = await createAcademicStructure(
    institution.id
  )
  console.log(
    `✅ Created academic year: ${academicYear.yearName} with ${semesters.length} semesters`
  )

  // Create course (degree/stream) and subjects
  console.log('Creating course and subjects...')
  const { course, subjects } = await createCourseAndSubjects(institution.id)
  console.log(
    `✅ Created course: ${course.name} with ${subjects.length} subjects`
  )

  // Create users (admin, teacher, students, parents, staff)
  console.log('Creating users...')
  const { superAdmin, teacher, students, parents, librarian } =
    await createUsers(roles, institution.id, course.id)
  console.log(
    `✅ Created users: 1 admin, 1 teacher, ${students.length} students, ${parents.length} parents, 2 staff`
  )

  // Create class sections and enrollments
  console.log('Creating class sections and enrollments...')
  const classSections = await createClassSections(
    subjects,
    semesters[0],
    teacher
  )
  await createEnrollments(students, subjects, semesters[0])
  console.log(
    `✅ Created ${classSections.length} class sections and enrollments`
  )

  // Create communications (unified notices and announcements)
  console.log('Creating communications...')
  const communications = await createCommunications(
    institution.id,
    superAdmin.id,
    librarian.id
  )
  console.log(`✅ Created ${communications.length} communications`)

  // Create library data
  console.log('Creating library data...')
  const books = await createLibraryData(institution.id, librarian.id)
  console.log(`✅ Created library with ${books.length} books`)

  // Create fee structures
  console.log('Creating fee structures...')
  const feeStructures = await createFeeStructures(
    institution.id,
    course.id,
    academicYear.id
  )
  await createStudentFees(students, feeStructures, semesters[0])
  console.log(`✅ Created ${feeStructures.length} fee structures`)

  // Create assignments and examinations
  console.log('Creating assignments and examinations...')
  const assignments = await createAssignments(subjects, classSections, teacher)
  const examinations = await createExaminations(subjects, semesters[0], teacher)
  console.log(
    `✅ Created ${assignments.length} assignments and ${examinations.length} examinations`
  )

  // Create timetable data
  console.log('Creating timetable data...')
  const { timeSlots, rooms, timetables } = await createTimetableData(
    institution.id,
    academicYear.id,
    semesters[0],
    course.id,
    subjects,
    teacher
  )
  console.log(
    `✅ Created ${timeSlots.length} time slots, ${rooms.length} rooms, ${timetables.length} timetable entries`
  )

  // Create teacher dashboard test data
  console.log('Creating teacher dashboard test data...')
  await createTeacherDashboardData(
    teacher,
    students,
    subjects,
    classSections,
    semesters[0],
    academicYear
  )
  console.log('✅ Created comprehensive teacher dashboard test data')

  // Create student dashboard data
  await createStudentDashboardData()
  console.log('✅ Created comprehensive student dashboard test data')

  // Create Phase 1 test data
  await createPhase1TestData()

  // Create comprehensive data for Student 1 (for full dashboard demo)
  console.log('Creating comprehensive data for Student 1...')
  await createStudent1ComprehensiveData(
    students,
    subjects,
    semesters,
    classSections,
    academicYear
  )
  console.log('✅ Created comprehensive data for Student 1')

  console.log('🎉 Comprehensive database seeding completed successfully!')
  printSummary(students.length, parents.length)
}

/**
 * Creates roles with fixed IDs (1-7)
 * IMPORTANT: NEVER CHANGE THIS ORDER OR IDs
 * 1 = super_admin
 * 2 = admin
 * 3 = student
 * 4 = parent
 * 5 = teacher
 * 6 = librarian
 * 7 = staff
 */
async function createRoles() {
  // Create roles sequentially to ensure correct IDs
  const roles = []

  // ID 1: Super Admin
  roles.push(
    await prisma.role.upsert({
      where: { id: 1 },
      update: {
        roleName: 'super_admin',
        description: 'System Super Administrator',
        permissions: [
          'canManageUsers',
          'canManageInstitutions',
          'canManageAllData',
          'canAccessReports',
          'canManageSystemSettings',
        ],
      },
      create: {
        id: 1,
        roleName: 'super_admin',
        description: 'System Super Administrator',
        permissions: [
          'canManageUsers',
          'canManageInstitutions',
          'canManageAllData',
          'canAccessReports',
          'canManageSystemSettings',
        ],
      },
    })
  )

  // ID 2: Admin
  roles.push(
    await prisma.role.upsert({
      where: { id: 2 },
      update: {
        roleName: 'admin',
        description: 'Institution Administrator',
        permissions: [
          'canManageUsers',
          'canManageStudents',
          'canManageTeachers',
          'canManageCourses',
          'canAccessReports',
          'canManageFees',
          'canManageLibrary',
        ],
      },
      create: {
        id: 2,
        roleName: 'admin',
        description: 'Institution Administrator',
        permissions: [
          'canManageUsers',
          'canManageStudents',
          'canManageTeachers',
          'canManageCourses',
          'canAccessReports',
          'canManageFees',
          'canManageLibrary',
        ],
      },
    })
  )

  // ID 3: Student
  roles.push(
    await prisma.role.upsert({
      where: { id: 3 },
      update: {
        roleName: 'student',
        description: 'Student',
        permissions: [
          'canViewOwnData',
          'canSubmitAssignments',
          'canViewGrades',
          'canViewTimetable',
          'canViewNotices',
          'canRequestGatePass',
        ],
      },
      create: {
        id: 3,
        roleName: 'student',
        description: 'Student',
        permissions: [
          'canViewOwnData',
          'canSubmitAssignments',
          'canViewGrades',
          'canViewTimetable',
          'canViewNotices',
          'canRequestGatePass',
        ],
      },
    })
  )

  // ID 4: Parent
  roles.push(
    await prisma.role.upsert({
      where: { id: 4 },
      update: {
        roleName: 'parent',
        description: 'Parent/Guardian',
        permissions: [
          'canViewChildData',
          'canViewChildGrades',
          'canViewChildAttendance',
          'canViewNotices',
          'canApproveGatePass',
          'canViewFees',
        ],
      },
      create: {
        id: 4,
        roleName: 'parent',
        description: 'Parent/Guardian',
        permissions: [
          'canViewChildData',
          'canViewChildGrades',
          'canViewChildAttendance',
          'canViewNotices',
          'canApproveGatePass',
          'canViewFees',
        ],
      },
    })
  )

  // ID 5: Teacher
  roles.push(
    await prisma.role.upsert({
      where: { id: 5 },
      update: {
        roleName: 'teacher',
        description: 'Teaching Faculty',
        permissions: [
          'canViewStudents',
          'canManageCourses',
          'canMarkAttendance',
          'canGradeAssignments',
          'canCreateAssignments',
          'canViewTimetable',
        ],
      },
      create: {
        id: 5,
        roleName: 'teacher',
        description: 'Teaching Faculty',
        permissions: [
          'canViewStudents',
          'canManageCourses',
          'canMarkAttendance',
          'canGradeAssignments',
          'canCreateAssignments',
          'canViewTimetable',
        ],
      },
    })
  )

  // ID 6: Librarian
  roles.push(
    await prisma.role.upsert({
      where: { id: 6 },
      update: {
        roleName: 'librarian',
        description: 'Library Staff',
        permissions: [
          'canManageBooks',
          'canManageBookIssues',
          'canViewLibraryReports',
          'canManageLibrarySettings',
        ],
      },
      create: {
        id: 6,
        roleName: 'librarian',
        description: 'Library Staff',
        permissions: [
          'canManageBooks',
          'canManageBookIssues',
          'canViewLibraryReports',
          'canManageLibrarySettings',
        ],
      },
    })
  )

  // ID 7: Staff
  roles.push(
    await prisma.role.upsert({
      where: { id: 7 },
      update: {
        roleName: 'staff',
        description: 'Support Staff',
        permissions: ['canViewOwnData', 'canMarkAttendance', 'canViewNotices'],
      },
      create: {
        id: 7,
        roleName: 'staff',
        description: 'Support Staff',
        permissions: ['canViewOwnData', 'canMarkAttendance', 'canViewNotices'],
      },
    })
  )

  return roles
}

async function createInstitution() {
  return await prisma.institution.upsert({
    where: { id: 1 },
    update: {},
    create: {
      code: 'EDU', // Institution code for Ed-verse University
      name: 'Ed-verse University',
      type: 'UNIVERSITY',
      address: '123 Education Street, Learning City, LC 12345',
      city: 'Learning City',
      state: 'Education State',
      country: 'United States',
      postalCode: '12345',
      phone: '+1-555-0123',
      email: 'info@edverse.edu',
      website: 'https://edverse.edu',
      establishedYear: 2024,
      accreditation: 'Regional Education Board',
    },
  })
}

async function createAcademicStructure(institutionId: number) {
  const academicYear = await prisma.academicYear.upsert({
    where: { id: 1 },
    update: {},
    create: {
      institutionId,
      yearName: '2024-2025',
      startDate: new Date('2024-08-01'),
      endDate: new Date('2025-07-31'),
      status: 'CURRENT',
    },
  })

  const semesters = await Promise.all([
    prisma.semester.upsert({
      where: { id: 1 },
      update: {},
      create: {
        academicYearId: academicYear.id,
        semesterName: 'Fall 2024',
        semesterNumber: 1,
        startDate: new Date('2024-08-15'),
        endDate: new Date('2024-12-15'),
        registrationStart: new Date('2024-07-01'),
        registrationEnd: new Date('2024-08-10'),
        status: 'ACTIVE',
      },
    }),
    prisma.semester.upsert({
      where: { id: 2 },
      update: {},
      create: {
        academicYearId: academicYear.id,
        semesterName: 'Spring 2025',
        semesterNumber: 2,
        startDate: new Date('2025-01-15'),
        endDate: new Date('2025-05-15'),
        registrationStart: new Date('2024-12-01'),
        registrationEnd: new Date('2025-01-10'),
        status: 'UPCOMING',
      },
    }),
  ])

  return { academicYear, semesters }
}

/**
 * Create Course and Subjects
 *
 * INDIAN EDUCATION TERMINOLOGY (Updated Schema):
 * - Course (DB) = Degree/Stream in Indian context (e.g., B.Sc. Computer Science, Science-Medical)
 * - Subject (DB) = Individual Subject/Paper in Indian context (e.g., Data Structures, Physics)
 *
 * This function creates:
 * 1. A course/degree program (e.g., B.Sc. CS) - called "Course" in India
 * 2. Subjects within that course (e.g., CS101, CS102) - called "Subjects" in India
 */
async function createCourseAndSubjects(institutionId: number) {
  // Create a Course (Degree/Stream in Indian context)
  // Example: "B.Sc. Computer Science" is a "Course" in Indian terminology
  const course = await prisma.course.upsert({
    where: { id: 1 },
    update: {},
    create: {
      institutionId,
      name: 'Bachelor of Science in Computer Science',
      code: 'BSCS',
      degreeType: 'BACHELORS',
      durationYears: 4.0,
      totalCredits: 120,
      description:
        'Comprehensive computer science program covering programming, algorithms, and software engineering',
      eligibilityCriteria:
        'High school diploma with mathematics and science subjects',
    },
  })

  // Create Subjects (Individual papers/subjects in Indian context)
  // These are individual subjects students study within the course
  // Examples: "Data Structures", "DBMS", "Web Development"
  const subjects = await Promise.all([
    prisma.subject.upsert({
      where: { subjectCode: 'CS101' },
      update: {},
      create: {
        courseId: course.id,
        subjectName: 'Introduction to Programming',
        subjectCode: 'CS101',
        credits: 3,
        theoryHours: 3,
        practicalHours: 2,
        tutorialHours: 1,
        subjectType: 'CORE',
        description: 'Fundamentals of programming using Python',
        syllabus:
          'Variables, loops, functions, data structures, and basic algorithms',
      },
    }),
    prisma.subject.upsert({
      where: { subjectCode: 'CS102' },
      update: {},
      create: {
        courseId: course.id,
        subjectName: 'Data Structures and Algorithms',
        subjectCode: 'CS102',
        credits: 4,
        theoryHours: 3,
        practicalHours: 2,
        tutorialHours: 1,
        subjectType: 'CORE',
        prerequisites: JSON.stringify(['CS101']),
        description: 'Advanced data structures and algorithm design',
        syllabus:
          'Arrays, linked lists, trees, graphs, sorting, and searching algorithms',
      },
    }),
    prisma.subject.upsert({
      where: { subjectCode: 'CS201' },
      update: {},
      create: {
        courseId: course.id,
        subjectName: 'Web Development',
        subjectCode: 'CS201',
        credits: 3,
        theoryHours: 2,
        practicalHours: 3,
        tutorialHours: 0,
        subjectType: 'CORE',
        prerequisites: JSON.stringify(['CS101']),
        description:
          'Modern web development using HTML, CSS, JavaScript, and frameworks',
        syllabus:
          'HTML5, CSS3, JavaScript ES6+, React, Node.js, and database integration',
      },
    }),
  ])

  return { course, subjects }
}

async function createUsers(
  roles: any[],
  institutionId: number,
  courseId: number
) {
  // Create super admin
  const superAdminPassword = await bcrypt.hash('admin123!', 12)
  const superAdminRole = roles.find(r => r.roleName === 'super_admin')!
  const superAdmin = await prisma.user.upsert({
    where: { email: 'admin@edverse.edu' },
    update: {},
    create: {
      firstName: 'Super',
      lastName: 'Administrator',
      name: 'Super Administrator',
      email: 'admin@edverse.edu',
      phone: '+1-555-0001',
      passwordHash: superAdminPassword,
      roleId: superAdminRole.id,
      edverseId: generateEdVerseId('EDU', 'super_admin', 2024),
      emailVerified: true,
      phoneVerified: true,
    },
  })

  // Create teacher
  const teacherPassword = await bcrypt.hash('teacher123!', 12)
  const teacherRole = roles.find(r => r.roleName === 'teacher')!
  const teacherUser = await prisma.user.upsert({
    where: { email: 'john.doe@edverse.edu' },
    update: {},
    create: {
      firstName: 'John',
      lastName: 'Doe',
      name: 'Dr. John Doe',
      email: 'john.doe@edverse.edu',
      phone: '+1-555-0002',
      passwordHash: teacherPassword,
      roleId: teacherRole.id,
      edverseId: generateEdVerseId('EDU', 'teacher', 2024),
      emailVerified: true,
      phoneVerified: true,
    },
  })

  const teacher = await prisma.teacher.upsert({
    where: { employeeId: 'EMP001' },
    update: {},
    create: {
      userId: teacherUser.id,
      institutionId,
      employeeId: 'EMP001',
      designation: 'Professor',
      specialization: 'Computer Science, Web Development',
      qualification: 'Ph.D. in Computer Science',
      experienceYears: 10,
      joinDate: new Date('2020-01-15'),
      salary: 75000.0,
      employmentType: 'FULL_TIME',
      officeLocation: 'CS Building, Room 201',
      officeHours: 'Monday-Friday 10:00 AM - 12:00 PM',
      researchInterests:
        'Web Technologies, Machine Learning, Software Engineering',
    },
  })

  // Create students and parents
  const students = []
  const parents = []
  const studentRole = roles.find(r => r.roleName === 'student')!
  const parentRole = roles.find(r => r.roleName === 'parent')!

  for (let i = 1; i <= 5; i++) {
    const studentPassword = await bcrypt.hash(`student${i}23!`, 12)
    const studentUser = await prisma.user.upsert({
      where: { email: `student${i}@edverse.edu` },
      update: {},
      create: {
        firstName: `Student`,
        lastName: `${i}`,
        name: `Student ${i}`,
        email: `student${i}@edverse.edu`,
        phone: `+1-555-000${i + 2}`,
        passwordHash: studentPassword,
        roleId: studentRole.id,
        edverseId: generateEdVerseId('EDU', 'student', 2024),
        emailVerified: true,
        phoneVerified: true,
      },
    })

    const student = await prisma.student.upsert({
      where: { admissionNumber: `ADM00${i}` },
      update: {},
      create: {
        userId: studentUser.id,
        institutionId,
        courseId,
        admissionNumber: `ADM00${i}`,
        rollNumber: `202400${i}`,
        admissionDate: new Date('2024-08-15'),
        currentSemester: 1,
        currentYear: 1,
        gradeLevel: 'Freshman',
        section: 'A',
        studentType: 'REGULAR',
        residentialStatus: 'DAY_SCHOLAR',
        emergencyContactName: `Parent ${i}`,
        emergencyContactPhone: `+1-555-000${i + 10}`,
        bloodGroup: 'O+',
      },
    })

    students.push(student)

    // Create parent for this student
    const parentPassword = await bcrypt.hash(`parent${i}23!`, 12)
    const parentUser = await prisma.user.upsert({
      where: { email: `parent${i}@email.com` },
      update: {},
      create: {
        firstName: `Parent`,
        lastName: `${i}`,
        name: `Parent ${i}`,
        email: `parent${i}@email.com`,
        phone: `+1-555-000${i + 10}`,
        passwordHash: parentPassword,
        roleId: parentRole.id,
        edverseId: generateEdVerseId('EDU', 'parent', 2024),
        emailVerified: true,
        phoneVerified: true,
      },
    })

    const parent = await prisma.parent.upsert({
      where: { userId: parentUser.id },
      update: {},
      create: {
        userId: parentUser.id,
        studentId: student.id,
        relation: 'FATHER',
        occupation: 'Software Engineer',
        annualIncome: 80000.0,
        educationLevel: "Bachelor's Degree",
        isPrimaryContact: true,
      },
    })

    parents.push(parent)
  }

  // Create staff
  const staffPassword = await bcrypt.hash('staff123!', 12)
  const staffRole = roles.find(r => r.roleName === 'staff')!
  const staffUser = await prisma.user.upsert({
    where: { email: 'staff@edverse.edu' },
    update: {},
    create: {
      firstName: 'Support',
      lastName: 'Staff',
      name: 'Support Staff',
      email: 'staff@edverse.edu',
      phone: '+1-555-0010',
      passwordHash: staffPassword,
      roleId: staffRole.id,
      edverseId: generateEdVerseId('EDU', 'staff', 2024),
      emailVerified: true,
      phoneVerified: true,
    },
  })

  await prisma.staff.upsert({
    where: { employeeId: 'STAFF001' },
    update: {},
    create: {
      userId: staffUser.id,
      institutionId,
      employeeId: 'STAFF001',
      staffType: 'ADMINISTRATIVE',
      designation: 'Administrative Assistant',
      department: 'Administration',
      joinDate: new Date('2023-01-01'),
      salary: 45000.0,
      employmentType: 'FULL_TIME',
      workingHours: 'Monday-Friday 9:00 AM - 5:00 PM',
      skills: ['Administration', 'Customer Service', 'Data Entry'],
      qualifications: 'Bachelor of Business Administration',
      experience: '5 years in administrative roles',
      emergencyContact: '+1-555-0011',
    },
  })

  // Create librarian
  const librarianPassword = await bcrypt.hash('librarian123!', 12)
  const librarianRole = roles.find(r => r.roleName === 'librarian')!
  const librarianUser = await prisma.user.upsert({
    where: { email: 'librarian@edverse.edu' },
    update: {},
    create: {
      firstName: 'Library',
      lastName: 'Manager',
      name: 'Library Manager',
      email: 'librarian@edverse.edu',
      phone: '+1-555-0012',
      passwordHash: librarianPassword,
      roleId: librarianRole.id,
      edverseId: generateEdVerseId('EDU', 'staff', 2024),
      emailVerified: true,
      phoneVerified: true,
    },
  })

  const librarian = await prisma.staff.upsert({
    where: { employeeId: 'LIB001' },
    update: {},
    create: {
      userId: librarianUser.id,
      institutionId,
      employeeId: 'LIB001',
      staffType: 'ADMINISTRATIVE',
      designation: 'Head Librarian',
      department: 'Library',
      joinDate: new Date('2022-06-01'),
      salary: 55000.0,
      employmentType: 'FULL_TIME',
      workingHours: 'Monday-Friday 8:00 AM - 6:00 PM',
      skills: ['Library Management', 'Cataloging', 'Research Support'],
      qualifications: 'Master of Library Science',
      experience: '8 years in library management',
      emergencyContact: '+1-555-0013',
    },
  })

  return { superAdmin, teacher, students, parents, librarian }
}

async function createClassSections(
  subjects: any[],
  semester: any,
  teacher: any
) {
  return await Promise.all([
    prisma.classSection.upsert({
      where: { id: 1 },
      update: {},
      create: {
        subjectId: subjects[0].id,
        semesterId: semester.id,
        teacherId: teacher.id,
        sectionName: 'A',
        maxCapacity: 30,
        currentEnrollment: 5,
        roomNumber: 'CS-101',
        schedule: JSON.stringify({
          Monday: '09:00-10:30',
          Wednesday: '09:00-10:30',
          Friday: '09:00-10:30',
        }),
        status: 'ACTIVE',
      },
    }),
    prisma.classSection.upsert({
      where: { id: 2 },
      update: {},
      create: {
        subjectId: subjects[1].id,
        semesterId: semester.id,
        teacherId: teacher.id,
        sectionName: 'A',
        maxCapacity: 25,
        currentEnrollment: 5,
        roomNumber: 'CS-102',
        schedule: JSON.stringify({
          Tuesday: '10:00-11:30',
          Thursday: '10:00-11:30',
        }),
        status: 'ACTIVE',
      },
    }),
  ])
}

async function createEnrollments(
  students: any[],
  subjects: any[],
  semester: any
) {
  for (const student of students) {
    for (const subject of subjects) {
      await prisma.enrollment.upsert({
        where: {
          unique_enrollment: {
            studentId: student.id,
            subjectId: subject.id,
            semesterId: semester.id,
          },
        },
        update: {},
        create: {
          studentId: student.id,
          subjectId: subject.id,
          semesterId: semester.id,
          enrollmentDate: new Date('2024-08-15'),
          enrollmentStatus: 'ENROLLED',
          creditsEarned: subject.credits,
          attendancePercentage: 85.0,
        },
      })
    }
  }
}

async function createCommunications(
  institutionId: number,
  adminId: number,
  librarianId: number
) {
  return await Promise.all([
    prisma.communication.upsert({
      where: { id: 1 },
      update: {},
      create: {
        institutionId,
        title: 'Welcome to Fall 2024 Semester',
        content:
          'Welcome all students to the Fall 2024 semester. Classes begin on August 15th.',
        communicationType: 'GENERAL',
        priority: 'HIGH',
        targetAudience: ['student', 'teacher', 'parent'],
        publishDate: new Date('2024-08-01'),
        isActive: true,
        isPinned: true,
        isEmergency: false,
        createdBy: adminId,
      },
    }),
    prisma.communication.upsert({
      where: { id: 2 },
      update: {},
      create: {
        institutionId,
        title: 'Library Hours Update',
        content:
          'The library will be open from 8 AM to 10 PM during the semester.',
        communicationType: 'GENERAL',
        priority: 'MEDIUM',
        targetAudience: ['student', 'teacher'],
        publishDate: new Date('2024-08-05'),
        isActive: true,
        isPinned: false,
        isEmergency: false,
        createdBy: librarianId,
      },
    }),
    prisma.communication.upsert({
      where: { id: 3 },
      update: {},
      create: {
        institutionId,
        title: 'New Computer Lab Opening',
        content:
          'We are excited to announce the opening of our new state-of-the-art computer lab.',
        communicationType: 'ACHIEVEMENT',
        priority: 'HIGH',
        targetAudience: ['student', 'teacher'],
        isEmergency: false,
        isPinned: true,
        publishDate: new Date('2024-08-10'),
        isActive: true,
        createdBy: adminId,
      },
    }),
    prisma.communication.upsert({
      where: { id: 4 },
      update: {},
      create: {
        institutionId,
        title: 'Emergency: Campus Closure Due to Weather',
        content:
          'Due to severe weather conditions, the campus will be closed tomorrow. All classes are cancelled.',
        communicationType: 'EMERGENCY',
        priority: 'URGENT',
        targetAudience: ['student', 'teacher', 'parent', 'staff'],
        isEmergency: true,
        isPinned: true,
        publishDate: new Date('2024-09-01'),
        isActive: true,
        createdBy: adminId,
      },
    }),
    prisma.communication.upsert({
      where: { id: 5 },
      update: {},
      create: {
        institutionId,
        title: 'Mid-Semester Examination Schedule',
        content:
          'The mid-semester examinations will be held from October 15-20. Please check your individual timetables.',
        communicationType: 'EXAMINATION',
        priority: 'HIGH',
        targetAudience: ['student', 'parent'],
        isPinned: true,
        isEmergency: false,
        publishDate: new Date('2024-09-15'),
        expiryDate: new Date('2024-10-20'),
        isActive: true,
        createdBy: adminId,
      },
    }),
  ])
}

async function createLibraryData(institutionId: number, librarianId: number) {
  const bookCategory = await prisma.bookCategory.upsert({
    where: { id: 1 },
    update: {},
    create: {
      name: 'Computer Science',
      description: 'Books related to computer science and programming',
      isActive: true,
    },
  })

  const books = await Promise.all([
    prisma.book.upsert({
      where: { isbn: '978-0134685991' },
      update: {},
      create: {
        institutionId,
        isbn: '978-0134685991',
        title: 'Effective Java',
        author: 'Joshua Bloch',
        publisher: 'Addison-Wesley',
        publicationYear: 2017,
        edition: '3rd Edition',
        language: 'English',
        categoryId: bookCategory.id,
        subjectArea: 'Programming',
        totalCopies: 5,
        availableCopies: 5,
        location: 'CS-Section-A',
        price: 45.99,
        condition: 'GOOD',
        description: 'A comprehensive guide to Java programming best practices',
        status: 'ACTIVE',
        addedBy: librarianId,
      },
    }),
    prisma.book.upsert({
      where: { isbn: '978-0132350884' },
      update: {},
      create: {
        institutionId,
        isbn: '978-0132350884',
        title: 'Clean Code',
        author: 'Robert C. Martin',
        publisher: 'Prentice Hall',
        publicationYear: 2008,
        edition: '1st Edition',
        language: 'English',
        categoryId: bookCategory.id,
        subjectArea: 'Software Engineering',
        totalCopies: 3,
        availableCopies: 3,
        location: 'CS-Section-B',
        price: 39.99,
        condition: 'EXCELLENT',
        description: 'A handbook of agile software craftsmanship',
        status: 'ACTIVE',
        addedBy: librarianId,
      },
    }),
  ])

  await prisma.librarySettings.upsert({
    where: { institutionId },
    update: {},
    create: {
      institutionId,
      maxBooksPerStudent: 5,
      defaultIssueDays: 14,
      maxRenewals: 2,
      finePerDay: 1.0,
      reservationDays: 3,
      isActive: true,
    },
  })

  return books
}

async function createFeeStructures(
  institutionId: number,
  courseId: number,
  academicYearId: number
) {
  return await Promise.all([
    prisma.feeStructure.upsert({
      where: { id: 1 },
      update: {},
      create: {
        institutionId,
        courseId,
        academicYearId,
        feeType: 'TUITION',
        feeName: 'Fall 2024 Tuition Fee',
        amount: 5000.0,
        dueDate: new Date('2024-09-15'),
        lateFeeAmount: 100.0,
        lateFeeAfterDays: 7,
        isRecurring: false,
        description: 'Tuition fee for Fall 2024 semester',
        status: 'ACTIVE',
      },
    }),
    prisma.feeStructure.upsert({
      where: { id: 2 },
      update: {},
      create: {
        institutionId,
        courseId,
        academicYearId,
        feeType: 'LIBRARY',
        feeName: 'Library Fee',
        amount: 100.0,
        dueDate: new Date('2024-09-01'),
        isRecurring: false,
        description: 'Annual library membership fee',
        status: 'ACTIVE',
      },
    }),
  ])
}

async function createStudentFees(
  students: any[],
  feeStructures: any[],
  semester: any
) {
  for (const student of students) {
    for (const feeStructure of feeStructures) {
      await prisma.studentFee.upsert({
        where: {
          unique_student_fee: {
            studentId: student.id,
            feeStructureId: feeStructure.id,
            semesterId: semester.id,
          },
        },
        update: {},
        create: {
          studentId: student.id,
          feeStructureId: feeStructure.id,
          semesterId: semester.id,
          amountDue: feeStructure.amount,
          amountPaid: 0.0,
          dueDate: feeStructure.dueDate!,
          status: 'PENDING',
        },
      })
    }
  }
}

async function createAssignments(
  subjects: any[],
  classSections: any[],
  teacher: any
) {
  return await Promise.all([
    prisma.assignment.upsert({
      where: { id: 1 },
      update: {},
      create: {
        subjectId: subjects[0].id,
        sectionId: classSections[0].id,
        teacherId: teacher.id,
        title: 'Programming Assignment 1',
        description: 'Create a simple calculator program in Python',
        instructions:
          'Implement basic arithmetic operations with user input validation',
        maxMarks: 100,
        weightagePercentage: 15.0,
        assignedDate: new Date('2024-08-20'),
        dueDate: new Date('2024-09-15'),
        lateSubmissionAllowed: true,
        latePenaltyPercentage: 10.0,
        status: 'PUBLISHED',
      },
    }),
  ])
}

async function createExaminations(
  subjects: any[],
  semester: any,
  teacher: any
) {
  return await Promise.all([
    prisma.examination.upsert({
      where: { id: 1 },
      update: {},
      create: {
        subjectId: subjects[0].id,
        semesterId: semester.id,
        examName: 'Midterm Exam - Introduction to Programming',
        examType: 'MIDTERM',
        examDate: new Date('2024-10-15'),
        startTime: new Date('2024-10-15T09:00:00'),
        durationMinutes: 120,
        totalMarks: 100,
        passingMarks: 40,
        weightagePercentage: 30.0,
        instructions:
          'Bring your student ID and calculator. No electronic devices allowed.',
        venue: 'Main Hall A',
        status: 'SCHEDULED',
        createdBy: teacher.id,
      },
    }),
  ])
}

async function createTimetableData(
  institutionId: number,
  academicYearId: number,
  semester: any,
  courseId: number,
  subjects: any[],
  teacher: any
) {
  const timeSlots = await Promise.all([
    prisma.timeSlot.upsert({
      where: { id: 1 },
      update: {},
      create: {
        institutionId,
        slotName: 'Period 1',
        startTime: new Date('2024-01-01T09:00:00'),
        endTime: new Date('2024-01-01T10:30:00'),
        slotType: 'LECTURE',
        duration: 90,
        isActive: true,
        sortOrder: 1,
      },
    }),
    prisma.timeSlot.upsert({
      where: { id: 2 },
      update: {},
      create: {
        institutionId,
        slotName: 'Period 2',
        startTime: new Date('2024-01-01T10:45:00'),
        endTime: new Date('2024-01-01T12:15:00'),
        slotType: 'LECTURE',
        duration: 90,
        isActive: true,
        sortOrder: 2,
      },
    }),
  ])

  const rooms = await Promise.all([
    prisma.room.upsert({
      where: {
        unique_room_number: { institutionId, roomNumber: 'CS-101' },
      },
      update: {},
      create: {
        institutionId,
        roomNumber: 'CS-101',
        roomName: 'Computer Lab 1',
        roomType: 'LABORATORY',
        building: 'Computer Science Building',
        floor: '1st Floor',
        capacity: 30,
        facilities: ['Projector', 'AC', 'Whiteboard', 'Computers'],
        isActive: true,
      },
    }),
    prisma.room.upsert({
      where: {
        unique_room_number: { institutionId, roomNumber: 'MAIN-001' },
      },
      update: {},
      create: {
        institutionId,
        roomNumber: 'MAIN-001',
        roomName: 'Main Hall A',
        roomType: 'AUDITORIUM',
        building: 'Main Building',
        floor: 'Ground Floor',
        capacity: 200,
        facilities: ['Projector', 'AC', 'Sound System', 'Stage'],
        isActive: true,
      },
    }),
  ])

  const timetables = await Promise.all([
    prisma.timeTable.upsert({
      where: { id: 1 },
      update: {},
      create: {
        institutionId,
        academicYearId,
        semesterId: semester.id,
        courseId,
        section: 'A',
        dayOfWeek: 'MONDAY',
        timeSlotId: timeSlots[0].id,
        subjectId: subjects[0].id,
        teacherId: teacher.id,
        roomId: rooms[0].id,
        isActive: true,
      },
    }),
  ])

  return { timeSlots, rooms, timetables }
}

function printSummary(studentCount: number, parentCount: number) {
  console.log('\n📋 Sample Accounts Created:')
  console.log('Super Admin: admin@edverse.edu / admin123!')
  console.log('Teacher: john.doe@edverse.edu / teacher123!')
  console.log(
    `Students: student1@edverse.edu / student123! (student1-${studentCount})`
  )
  console.log(
    `Parents: parent1@email.com / parent123! (parent1-${parentCount})`
  )
  console.log('Staff: staff@edverse.edu / staff123!')
  console.log('Librarian: librarian@edverse.edu / librarian123!')
  console.log('\n📊 Data Created:')
  console.log(
    '- 7 roles (super_admin, admin, teacher, student, parent, librarian, staff)'
  )
  console.log('- 1 institution with complete academic structure')
  console.log('- 1 program with 3 courses and 2 subjects')
  console.log(`- ${studentCount} students with ${parentCount} parents`)
  console.log('- 1 teacher + 2 staff members (including librarian)')
  console.log('- 2 class sections with enrollments')
  console.log('- 5 communications (unified notices & announcements)')
  console.log('- 2 books with library settings')
  console.log('- 2 fee structures with student fees')
  console.log('- 1 assignment + 1 examination')
  console.log('- 2 time slots + 2 rooms + 1 timetable entry')
  console.log('- Teacher dashboard data (attendance, grades, performance)')
}

/**
 * Create comprehensive teacher dashboard test data
 * Includes: attendance records, student progress, teacher-subject assignments
 */
async function createTeacherDashboardData(
  teacher: any,
  students: any[],
  subjects: any[],
  classSections: any[],
  semester: any,
  academicYear: any
) {
  // 0. Assign teacher as class teacher (homeroom teacher)
  console.log('  → Assigning teacher as class teacher...')
  await prisma.classTeacher.upsert({
    where: {
      unique_class_teacher: {
        courseId: 1,
        classLevel: 'Year 1',
        section: 'A',
        academicYearId: academicYear.id,
      },
    },
    update: {
      teacherId: teacher.id,
    },
    create: {
      teacherId: teacher.id,
      courseId: 1,
      classLevel: 'Year 1',
      section: 'A',
      academicYearId: academicYear.id,
      assignedDate: new Date(),
    },
  })

  // 1. Assign subjects to teacher
  console.log('  → Assigning subjects to teacher...')
  for (const subject of subjects) {
    await prisma.teacherSubject.upsert({
      where: {
        unique_teacher_subject: {
          teacherId: teacher.id,
          subjectId: subject.id,
          academicYearId: academicYear.id,
        },
      },
      update: {},
      create: {
        teacherId: teacher.id,
        subjectId: subject.id,
        academicYearId: academicYear.id,
        isPrimary: subject.code === 'MATH101',
      },
    })
  }

  // 2. Create attendance records for the past month (varied patterns)
  console.log('  → Creating attendance records...')
  const today = new Date()
  const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1)

  // Create attendance for each weekday in the current month
  for (
    let day = new Date(startOfMonth);
    day <= today;
    day.setDate(day.getDate() + 1)
  ) {
    const dayOfWeek = day.getDay()
    // Skip weekends
    if (dayOfWeek === 0 || dayOfWeek === 6) continue

    for (const student of students) {
      for (const section of classSections) {
        // Determine attendance status based on patterns
        const random = Math.random()
        let status = 'PRESENT'

        // Friday has worse attendance
        if (dayOfWeek === 5) {
          if (random < 0.15) status = 'ABSENT'
          else if (random < 0.2) status = 'LATE'
          else status = 'PRESENT'
        } else {
          if (random < 0.08) status = 'ABSENT'
          else if (random < 0.11) status = 'LATE'
          else if (random < 0.13) status = 'EXCUSED'
          else status = 'PRESENT'
        }

        try {
          await prisma.attendance.create({
            data: {
              studentId: student.id,
              sectionId: section.id,
              date: new Date(day),
              status: status as any,
              markedBy: teacher.id,
              remarks: status === 'ABSENT' ? 'No reason provided' : null,
            },
          })
        } catch {
          // Skip if already exists
        }
      }
    }
  }

  // 3. Create student progress records with varied grades
  console.log('  → Creating student progress records...')
  // Grading Scale: A+ (93+), A (85-92), B+ (77-84), B (70-76), C (60-69), D (<60)
  const gradePoints = {
    'A+': 4.0,
    A: 3.7,
    'B+': 3.3,
    B: 3.0,
    C: 2.0,
    D: 1.0,
  }

  for (const student of students) {
    for (const subject of subjects) {
      // Vary performance by subject
      let baseScore = 75 + Math.random() * 20 // 75-95 range

      // Mathematics tends to be harder
      if (subject.code === 'MATH101') {
        baseScore = 70 + Math.random() * 25
      }

      // Science varies more
      if (subject.code === 'SCI101') {
        baseScore = 65 + Math.random() * 30
      }

      const assignmentScore = baseScore + (Math.random() * 10 - 5)
      const examScore = baseScore + (Math.random() * 10 - 5)
      const participationScore = 80 + Math.random() * 15
      const attendancePercentage = 85 + Math.random() * 12

      // Determine grade based on average (A+, A, B+, B, C, D)
      const avgScore = (assignmentScore + examScore) / 2
      let grade = 'B'
      if (avgScore >= 93) grade = 'A+'
      else if (avgScore >= 85) grade = 'A'
      else if (avgScore >= 77) grade = 'B+'
      else if (avgScore >= 70) grade = 'B'
      else if (avgScore >= 60) grade = 'C'
      else grade = 'D'

      const status =
        attendancePercentage < 75
          ? 'AT_RISK'
          : avgScore >= 90
            ? 'EXCELLENT'
            : avgScore >= 80
              ? 'ON_TRACK'
              : 'NEEDS_IMPROVEMENT'

      try {
        await prisma.studentProgress.create({
          data: {
            studentId: student.id,
            subjectId: subject.id,
            semesterId: semester.id,
            academicYearId: academicYear.id,
            overallGrade: grade,
            gradePoints: gradePoints[grade as keyof typeof gradePoints],
            attendancePercentage: Math.round(attendancePercentage * 100) / 100,
            assignmentScore: Math.round(assignmentScore * 100) / 100,
            examScore: Math.round(examScore * 100) / 100,
            participationScore: Math.round(participationScore * 100) / 100,
            status: status as any,
            strengths:
              avgScore >= 85
                ? ['Strong understanding', 'Active participation']
                : ['Consistent effort'],
            areasForImprovement:
              avgScore < 80
                ? ['Needs more practice', 'Homework completion']
                : [],
            teacherComments:
              avgScore >= 90
                ? 'Excellent performance!'
                : avgScore >= 80
                  ? 'Good work, keep it up!'
                  : 'Needs improvement in understanding core concepts.',
          },
        })
      } catch {
        // Skip if already exists
      }
    }
  }

  // 4. Create more students for better dashboard visualization
  console.log('  → Creating additional students for dashboard...')
  const studentRole = await prisma.role.findFirst({
    where: { roleName: 'student' },
  })

  if (studentRole) {
    const additionalStudentCount = 23 // To make total ~28 students
    for (let i = 6; i <= 6 + additionalStudentCount; i++) {
      const studentPassword = await bcrypt.hash(`student${i}23!`, 12)

      try {
        const studentUser = await prisma.user.create({
          data: {
            firstName: `Student`,
            lastName: `${i}`,
            name: `Student ${i}`,
            email: `student${i}@edverse.edu`,
            phone: `+1-555-0${String(100 + i).slice(-3)}`,
            passwordHash: studentPassword,
            roleId: studentRole.id,
            edverseId: generateEdVerseId('EDU', 'student', 2024),
            emailVerified: true,
            phoneVerified: true,
          },
        })

        const student = await prisma.student.create({
          data: {
            userId: studentUser.id,
            institutionId: students[0].institutionId,
            courseId: students[0].courseId,
            admissionNumber: `ADM0${String(i).padStart(2, '0')}`,
            rollNumber: `20240${String(i).padStart(2, '0')}`,
            admissionDate: new Date('2024-08-15'),
            currentSemester: 1,
            currentYear: 1,
            gradeLevel: 'Freshman',
            section: 'A',
            studentType: 'REGULAR',
            residentialStatus: 'DAY_SCHOLAR',
            emergencyContactName: `Parent ${i}`,
            emergencyContactPhone: `+1-555-0${String(200 + i).slice(-3)}`,
            bloodGroup: ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'][
              i % 8
            ],
          },
        })

        // Create attendance for this student
        for (
          let day = new Date(startOfMonth);
          day <= today;
          day.setDate(day.getDate() + 1)
        ) {
          const dayOfWeek = day.getDay()
          if (dayOfWeek === 0 || dayOfWeek === 6) continue

          for (const section of classSections) {
            const random = Math.random()
            const status =
              random < 0.08 ? 'ABSENT' : random < 0.12 ? 'LATE' : 'PRESENT'

            try {
              await prisma.attendance.create({
                data: {
                  studentId: student.id,
                  sectionId: section.id,
                  date: new Date(day),
                  status: status as any,
                  markedBy: teacher.id,
                },
              })
            } catch {
              // Skip if exists
            }
          }
        }

        // Create student progress
        for (const subject of subjects) {
          const baseScore = 70 + Math.random() * 25
          const assignmentScore = baseScore + (Math.random() * 10 - 5)
          const examScore = baseScore + (Math.random() * 10 - 5)
          const avgScore = (assignmentScore + examScore) / 2

          let grade = 'B'
          if (avgScore >= 93) grade = 'A+'
          else if (avgScore >= 85) grade = 'A'
          else if (avgScore >= 77) grade = 'B+'
          else if (avgScore >= 70) grade = 'B'
          else if (avgScore >= 60) grade = 'C'
          else grade = 'D'

          try {
            await prisma.studentProgress.create({
              data: {
                studentId: student.id,
                subjectId: subject.id,
                semesterId: semester.id,
                academicYearId: academicYear.id,
                overallGrade: grade,
                gradePoints: gradePoints[grade as keyof typeof gradePoints],
                attendancePercentage: 85 + Math.random() * 12,
                assignmentScore: Math.round(assignmentScore * 100) / 100,
                examScore: Math.round(examScore * 100) / 100,
                participationScore: 80 + Math.random() * 15,
                status: 'ON_TRACK' as any,
                strengths: ['Consistent effort'],
                areasForImprovement: [],
              },
            })
          } catch {
            // Skip if exists
          }
        }
      } catch {
        // Skip if user already exists
      }
    }
  }

  console.log('  ✅ Teacher dashboard data created successfully!')
}

async function createStudentDashboardData() {
  console.log('📊 Creating student dashboard data...')

  // Get active semester and academic year
  const activeSemester = await prisma.semester.findFirst({
    where: { status: 'ACTIVE' },
  })

  const activeAcademicYear = await prisma.academicYear.findFirst({
    where: { status: 'CURRENT' },
  })

  if (!activeSemester || !activeAcademicYear) {
    console.log(
      '  ⚠️ No active semester or academic year found, skipping student dashboard data'
    )
    return
  }

  // Get all students
  const students = await prisma.student.findMany({
    include: { user: true },
    take: 10, // Limit to first 10 students for demo
  })

  // Get all subjects
  const subjects = await prisma.subject.findMany({
    take: 5, // Mathematics, Physics, Chemistry, English, History
  })

  if (students.length === 0 || subjects.length === 0) {
    console.log(
      '  ⚠️ No students or subjects found, skipping student dashboard data'
    )
    return
  }

  console.log(
    `  📝 Creating data for ${students.length} students and ${subjects.length} subjects`
  )

  // Create performance trends data (last 6 months)
  const months = [
    { name: 'Jan', date: new Date(2024, 0, 15) },
    { name: 'Feb', date: new Date(2024, 1, 15) },
    { name: 'Mar', date: new Date(2024, 2, 15) },
    { name: 'Apr', date: new Date(2024, 3, 15) },
    { name: 'May', date: new Date(2024, 4, 15) },
    { name: 'Jun', date: new Date(2024, 5, 15) },
  ]

  for (const student of students) {
    console.log(`  👤 Creating dashboard data for ${student.user.name}`)

    // Create student progress for each subject and month
    for (const subject of subjects) {
      let baseScore = 3.0 + Math.random() * 1.0 // Base GPA between 3.0-4.0

      for (const month of months) {
        // Add some variation to create trends
        const variation = (Math.random() - 0.5) * 0.3
        const monthScore = Math.max(2.0, Math.min(4.0, baseScore + variation))

        try {
          await prisma.studentProgress.create({
            data: {
              studentId: student.id,
              subjectId: subject.id,
              semesterId: activeSemester.id,
              academicYearId: activeAcademicYear.id,
              overallGrade:
                monthScore >= 4.0
                  ? 'A+'
                  : monthScore >= 3.7
                    ? 'A'
                    : monthScore >= 3.3
                      ? 'B+'
                      : monthScore >= 3.0
                        ? 'B'
                        : monthScore >= 2.0
                          ? 'C'
                          : 'D',
              gradePoints: monthScore,
              attendancePercentage: 85 + Math.random() * 12,
              assignmentScore: monthScore * 25, // Convert to percentage
              examScore: monthScore * 25,
              participationScore: 80 + Math.random() * 15,
              status:
                monthScore >= 3.5
                  ? 'EXCELLENT'
                  : monthScore >= 3.0
                    ? 'ON_TRACK'
                    : 'NEEDS_IMPROVEMENT',
              strengths:
                monthScore >= 3.5
                  ? ['Excellent understanding', 'Active participation']
                  : ['Consistent effort'],
              areasForImprovement:
                monthScore < 3.0
                  ? ['Needs more practice', 'Attendance improvement']
                  : [],
              teacherComments: `${month.name} performance: ${monthScore >= 3.5 ? 'Excellent' : monthScore >= 3.0 ? 'Good' : 'Needs improvement'}`,
              createdAt: month.date,
              lastUpdated: month.date,
            },
          })
        } catch {
          // Skip if already exists
        }

        // Slightly adjust base score for next month (create trends)
        baseScore += (Math.random() - 0.4) * 0.1
        baseScore = Math.max(2.5, Math.min(4.0, baseScore))
      }
    }

    // Create academic records for GPA calculation
    for (const subject of subjects) {
      const gradePoints = 3.0 + Math.random() * 1.0
      const credits = 3 + Math.floor(Math.random() * 2) // 3-4 credits

      try {
        await prisma.academicRecord.create({
          data: {
            studentId: student.id,
            semesterId: activeSemester.id,
            subjectId: subject.id, // Using subject as course for simplicity
            marksObtained: gradePoints * 25, // Convert to percentage
            maxMarks: 100,
            grade:
              gradePoints >= 4.0
                ? 'A+'
                : gradePoints >= 3.7
                  ? 'A'
                  : gradePoints >= 3.3
                    ? 'B+'
                    : gradePoints >= 3.0
                      ? 'B'
                      : gradePoints >= 2.0
                        ? 'C'
                        : 'D',
            gradePoints: gradePoints,
            creditsEarned: credits,
            status: 'PASSED',
          },
        })
      } catch {
        // Skip if already exists
      }
    }

    // Create attendance records for the last 3 months
    const attendanceDates = []
    const today = new Date()
    for (let i = 90; i >= 0; i--) {
      const date = new Date(today)
      date.setDate(date.getDate() - i)
      // Only weekdays
      if (date.getDay() !== 0 && date.getDay() !== 6) {
        attendanceDates.push(date)
      }
    }

    // Get class sections for attendance
    const classSections = await prisma.classSection.findMany({
      take: 3, // Limit to 3 sections
    })

    for (const section of classSections) {
      for (const date of attendanceDates) {
        // 90% chance of being present
        const isPresent = Math.random() > 0.1

        try {
          await prisma.attendance.create({
            data: {
              studentId: student.id,
              sectionId: section.id,
              date: date,
              status: isPresent
                ? 'PRESENT'
                : Math.random() > 0.5
                  ? 'ABSENT'
                  : 'LATE',
              markedBy: section.teacherId,
              markedAt: date,
            },
          })
        } catch {
          // Skip if already exists
        }
      }
    }
  }

  // Create upcoming examinations
  console.log('  📅 Creating upcoming examinations...')

  const upcomingDates = [
    {
      name: 'Mathematics Test',
      date: new Date(2025, 10, 25),
      time: '10:00:00',
    }, // Nov 25, 2025
    { name: 'Physics Quiz', date: new Date(2025, 10, 28), time: '14:00:00' }, // Nov 28, 2025
    {
      name: 'Chemistry Midterm',
      date: new Date(2025, 11, 2),
      time: '09:00:00',
    }, // Dec 2, 2025
    {
      name: 'English Essay Test',
      date: new Date(2025, 11, 5),
      time: '11:00:00',
    }, // Dec 5, 2025
    { name: 'History Final', date: new Date(2025, 11, 8), time: '13:00:00' }, // Dec 8, 2025
  ]

  for (let i = 0; i < Math.min(subjects.length, upcomingDates.length); i++) {
    const subject = subjects[i]
    const examData = upcomingDates[i]

    try {
      await prisma.examination.create({
        data: {
          subjectId: subject.id,
          semesterId: activeSemester.id,
          examName: examData.name,
          examType:
            i === 4
              ? 'FINAL'
              : i === 2
                ? 'MIDTERM'
                : i === 1
                  ? 'QUIZ'
                  : 'ASSIGNMENT',
          examDate: examData.date,
          startTime: new Date(`2024-01-01T${examData.time}`),
          durationMinutes: 120,
          totalMarks: 100,
          passingMarks: 40,
          status: 'SCHEDULED',
          createdBy: 1, // Assuming teacher ID 1
          instructions: `Instructions for ${examData.name}`,
          venue: `Room ${100 + i}`,
        },
      })
    } catch {
      // Skip if already exists
    }
  }

  // Create upcoming assignments
  console.log('  📋 Creating upcoming assignments...')
  const teachers = await prisma.teacher.findMany({ take: 3 })

  if (teachers.length > 0) {
    const assignmentData = [
      {
        title: 'Science Fair Project',
        dueDate: new Date(2025, 10, 30),
        subject: 'Physics',
      },
      {
        title: 'History Research Paper',
        dueDate: new Date(2025, 11, 3),
        subject: 'History',
      },
      {
        title: 'Chemistry Lab Report',
        dueDate: new Date(2025, 11, 7),
        subject: 'Chemistry',
      },
      {
        title: 'Math Problem Set 5',
        dueDate: new Date(2025, 11, 10),
        subject: 'Mathematics',
      },
      {
        title: 'English Literature Essay',
        dueDate: new Date(2025, 11, 12),
        subject: 'English',
      },
    ]

    for (let i = 0; i < Math.min(subjects.length, assignmentData.length); i++) {
      const subject = subjects[i]
      const assignment = assignmentData[i]
      const teacher = teachers[i % teachers.length]

      try {
        await prisma.assignment.create({
          data: {
            subjectId: subject.id,
            teacherId: teacher.id,
            title: assignment.title,
            description: `Complete the ${assignment.title} as discussed in class.`,
            instructions: `Detailed instructions for ${assignment.title}`,
            maxMarks: 100,
            assignedDate: new Date(),
            dueDate: assignment.dueDate,
            status: 'PUBLISHED',
            lateSubmissionAllowed: true,
            latePenaltyPercentage: 10,
          },
        })
      } catch {
        // Skip if already exists
      }
    }
  }

  console.log('  ✅ Student dashboard data created successfully!')
}

async function createPhase1TestData() {
  console.log(
    '🎯 Creating Phase 1 test data (Pending Submissions & At-Risk Students)...'
  )

  // Get teacher and students
  const teacher = await prisma.teacher.findFirst({
    where: { user: { email: 'john.doe@edverse.edu' } },
    include: { user: true },
  })

  if (!teacher) {
    console.log('  ⚠️ No teacher found, skipping Phase 1 data')
    return
  }

  const students = await prisma.student.findMany({
    where: { status: 'ACTIVE' },
    include: { user: true },
  })

  if (students.length === 0) {
    console.log('  ⚠️ No students found, skipping Phase 1 data')
    return
  }

  console.log(`  📚 Found ${students.length} students to work with`)

  // Get active semester and subjects
  const activeSemester = await prisma.semester.findFirst({
    where: { status: 'ACTIVE' },
  })

  const subjects = await prisma.subject.findMany({
    take: 3,
  })

  if (!activeSemester || subjects.length === 0) {
    console.log(
      '  ⚠️ No active semester or subjects found, skipping Phase 1 data'
    )
    return
  }

  // Get or create class sections
  const classSections = await prisma.classSection.findMany({
    where: { teacherId: teacher.id, status: 'ACTIVE' },
  })

  console.log('  📝 Creating assignments with pending submissions...')

  // Create assignments with PAST due dates (positive days = days AGO)
  const assignmentDates = [
    { days: 7, title: 'Week 1 Quiz', priority: 'high' }, // 7 days ago
    { days: 5, title: 'Chapter 2 Essay', priority: 'high' }, // 5 days ago
    { days: 4, title: 'Lab Report #1', priority: 'high' }, // 4 days ago
    { days: 2, title: 'Homework Set 3', priority: 'medium' }, // 2 days ago
    { days: 1, title: 'Reading Response', priority: 'medium' }, // 1 day ago
    { days: 0, title: 'Discussion Post', priority: 'low' }, // Today
  ]

  const createdAssignments = []

  for (let i = 0; i < assignmentDates.length; i++) {
    const assignmentInfo = assignmentDates[i]
    const subject = subjects[i % subjects.length]

    try {
      const assignment = await prisma.assignment.create({
        data: {
          subjectId: subject.id,
          teacherId: teacher.id,
          title: assignmentInfo.title,
          description: `Complete ${assignmentInfo.title} assignment`,
          instructions: 'Follow the guidelines provided in class',
          maxMarks: 100,
          assignedDate: new Date(
            Date.now() - (assignmentInfo.days + 7) * 24 * 60 * 60 * 1000
          ), // Assigned 7 days before due
          dueDate: new Date(
            Date.now() - assignmentInfo.days * 24 * 60 * 60 * 1000
          ), // Due date in the PAST
          status: 'PUBLISHED',
          lateSubmissionAllowed: true,
          latePenaltyPercentage: 10,
        },
      })
      createdAssignments.push({ assignment, priority: assignmentInfo.priority })
    } catch {
      // Skip if already exists
    }
  }

  console.log(`  ✅ Created ${createdAssignments.length} assignments`)

  // Create pending submissions (SUBMITTED status, not graded)
  console.log('  📤 Creating pending submissions...')
  let submissionCount = 0

  for (const { assignment, priority } of createdAssignments) {
    // Create 2-3 pending submissions per assignment
    const numSubmissions =
      priority === 'high' ? 3 : priority === 'medium' ? 2 : 1

    for (let i = 0; i < Math.min(numSubmissions, students.length); i++) {
      const student = students[i]

      try {
        await prisma.submission.create({
          data: {
            assignmentId: assignment.id,
            studentId: student.id,
            submittedAt: new Date(
              assignment.dueDate.getTime() - 2 * 60 * 60 * 1000
            ), // Submitted 2 hours before due date
            status: 'SUBMITTED', // Not graded yet
            submissionText: `Submission for ${assignment.title} by ${student.user.name}`,
          },
        })
        submissionCount++
      } catch (error) {
        console.log(
          `  ⚠️ Could not create submission for ${student.user.name}: ${error.message}`
        )
      }
    }
  }

  console.log(`  ✅ Created ${submissionCount} pending submissions`)

  // Create at-risk students data
  console.log('  ⚠️ Creating at-risk student scenarios...')

  // Scenario 1: High-risk student (missing assignments, low attendance, inactive)
  if (students.length > 0 && classSections.length > 0) {
    const highRiskStudent = students[0]

    // Create attendance records with low attendance rate
    for (let i = 0; i < 20; i++) {
      const date = new Date(Date.now() - i * 24 * 60 * 60 * 1000)
      const status = i % 3 === 0 ? 'PRESENT' : 'ABSENT' // 33% attendance

      try {
        await prisma.attendance.create({
          data: {
            studentId: highRiskStudent.id,
            sectionId: classSections[0].id,
            date: date,
            status: status,
            markedBy: teacher.id,
          },
        })
      } catch {
        // Skip if already exists
      }
    }

    // Create poor exam results
    const exam = await prisma.examination.findFirst({
      where: { createdBy: teacher.id },
    })

    if (exam) {
      try {
        await prisma.examResult.create({
          data: {
            examId: exam.id,
            studentId: highRiskStudent.id,
            marksObtained: 45, // 45%
            grade: 'F',
            remarks: 'Needs improvement',
          },
        })
      } catch {
        // Skip if already exists
      }
    }

    // Update last login to 10 days ago
    await prisma.user.update({
      where: { id: highRiskStudent.userId },
      data: { lastLogin: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000) },
    })

    console.log(
      `  🔴 Created high-risk scenario for ${highRiskStudent.user.name}`
    )
  }

  // Scenario 2: Medium-risk student (missing some assignments, okay attendance)
  if (students.length > 1 && classSections.length > 0) {
    const mediumRiskStudent = students[1]

    // Create attendance records with medium attendance rate
    for (let i = 0; i < 20; i++) {
      const date = new Date(Date.now() - i * 24 * 60 * 60 * 1000)
      const status = i % 4 === 0 ? 'ABSENT' : 'PRESENT' // 75% attendance

      try {
        await prisma.attendance.create({
          data: {
            studentId: mediumRiskStudent.id,
            sectionId: classSections[0].id,
            date: date,
            status: status,
            markedBy: teacher.id,
          },
        })
      } catch {
        // Skip if already exists
      }
    }

    // Update last login to 5 days ago
    await prisma.user.update({
      where: { id: mediumRiskStudent.userId },
      data: { lastLogin: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000) },
    })

    console.log(
      `  🟡 Created medium-risk scenario for ${mediumRiskStudent.user.name}`
    )
  }

  // Scenario 3: Low-risk student (one missing assignment, good attendance)
  if (students.length > 2 && classSections.length > 0) {
    const lowRiskStudent = students[2]

    // Create attendance records with good attendance rate
    for (let i = 0; i < 20; i++) {
      const date = new Date(Date.now() - i * 24 * 60 * 60 * 1000)
      const status = i % 10 === 0 ? 'ABSENT' : 'PRESENT' // 90% attendance

      try {
        await prisma.attendance.create({
          data: {
            studentId: lowRiskStudent.id,
            sectionId: classSections[0].id,
            date: date,
            status: status,
            markedBy: teacher.id,
          },
        })
      } catch {
        // Skip if already exists
      }
    }

    // Update last login to 2 days ago
    await prisma.user.update({
      where: { id: lowRiskStudent.userId },
      data: { lastLogin: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000) },
    })

    console.log(
      `  🟢 Created low-risk scenario for ${lowRiskStudent.user.name}`
    )
  }

  // Scenario 4: Good students (no risk) - create good attendance for remaining students
  if (classSections.length > 0) {
    for (let i = 3; i < Math.min(students.length, 6); i++) {
      const goodStudent = students[i]

      for (let j = 0; j < 20; j++) {
        const date = new Date(Date.now() - j * 24 * 60 * 60 * 1000)

        try {
          await prisma.attendance.create({
            data: {
              studentId: goodStudent.id,
              sectionId: classSections[0].id,
              date: date,
              status: 'PRESENT',
              markedBy: teacher.id,
            },
          })
        } catch {
          // Skip if already exists
        }
      }

      // Create submissions for all assignments
      for (const { assignment } of createdAssignments) {
        try {
          await prisma.submission.create({
            data: {
              assignmentId: assignment.id,
              studentId: goodStudent.id,
              submittedAt: new Date(
                assignment.dueDate.getTime() - 24 * 60 * 60 * 1000
              ),
              status: 'GRADED',
              submissionText: `Submission for ${assignment.title} by ${goodStudent.user.name}`,
              marksObtained: 85 + Math.floor(Math.random() * 15), // 85-100
              feedback: 'Excellent work!',
            },
          })
        } catch {
          // Skip if already exists
        }
      }

      // Update last login to today
      await prisma.user.update({
        where: { id: goodStudent.userId },
        data: { lastLogin: new Date() },
      })
    }
  }

  console.log('  ✅ Phase 1 test data created successfully!')
  console.log('')
  console.log('  📊 Summary:')
  console.log(
    `     • ${createdAssignments.length} assignments with varied due dates`
  )
  console.log(`     • ${submissionCount} pending submissions (need grading)`)
  console.log(`     • 3 at-risk student scenarios (high, medium, low)`)
  console.log(
    `     • ${Math.min(students.length - 3, 3)} good students (no risk)`
  )
  console.log('')
  console.log('  🎯 Test the APIs:')
  console.log(`     • GET /teachers/${teacher.user.uuid}/submissions/pending`)
  console.log(`     • GET /teachers/${teacher.user.uuid}/students/at-risk`)
}

/**
 * Creates comprehensive data specifically for Student 1 to populate full dashboard
 */
async function createStudent1ComprehensiveData(
  students: { id: number; userId: number }[],
  _subjects: { id: number; subjectName: string }[],
  semesters: { id: number; semesterName: string }[],
  classSections: { id: number; teacherId: number; subjectId: number }[],
  _academicYear: { id: number }
) {
  // Get Student 1
  const student1 = students[0]
  if (!student1) {
    console.log('  ⚠️ Student 1 not found, skipping')
    return
  }

  // Get student's enrollments
  const enrollments = await prisma.enrollment.findMany({
    where: { studentId: student1.id },
    include: { subject: true },
  })

  if (enrollments.length === 0) {
    console.log('  ⚠️ Student 1 has no enrollments, skipping')
    return
  }

  // Get the latest semester (Spring 2025)
  const latestSemester =
    semesters.find(s => s.semesterName === 'Spring 2025') ||
    semesters[semesters.length - 1]

  // Get sections for enrolled courses
  const sections = classSections.filter(s =>
    enrollments.some(e => e.subjectId === s.subjectId)
  )

  console.log(`  👤 Creating comprehensive data for Student 1`)
  console.log(`     - ${enrollments.length} courses enrolled`)
  console.log(`     - ${sections.length} sections`)

  // Create assignments for each course
  const assignmentCount = { past: 0, upcoming: 0, overdue: 0 }
  for (let i = 0; i < enrollments.length && i < sections.length; i++) {
    const enrollment = enrollments[i]
    const section = sections[i]

    // Past assignment (submitted & graded)
    try {
      const pastAssignment = await prisma.assignment.create({
        data: {
          subjectId: enrollment.subjectId,
          sectionId: section.id,
          teacherId: section.teacherId,
          title: `${enrollment.subject.subjectName} - Assignment 1`,
          description: `Complete the first chapter exercises for ${enrollment.subject.subjectName}`,
          instructions: 'Submit your answers in PDF format',
          maxMarks: 100,
          assignedDate: new Date('2025-10-15'),
          dueDate: new Date('2025-10-25'),
          status: 'PUBLISHED',
        },
      })

      await prisma.submission.create({
        data: {
          assignmentId: pastAssignment.id,
          studentId: student1.id,
          submittedAt: new Date('2025-10-24'),
          status: 'GRADED',
          marksObtained: 85,
          feedback: 'Excellent work! Well structured and comprehensive.',
          gradedBy: section.teacherId,
          gradedAt: new Date('2025-10-26'),
        },
      })
      assignmentCount.past++
    } catch {
      // Skip if exists
    }

    // Upcoming assignment (not submitted)
    try {
      await prisma.assignment.create({
        data: {
          subjectId: enrollment.subjectId,
          sectionId: section.id,
          teacherId: section.teacherId,
          title: `${enrollment.subject.subjectName} - Assignment 2`,
          description: `Research project on advanced topics in ${enrollment.subject.subjectName}`,
          instructions:
            'Submit a 5-page report with references. Include diagrams and examples.',
          maxMarks: 100,
          assignedDate: new Date('2025-11-01'),
          dueDate: new Date('2025-11-20'),
          status: 'PUBLISHED',
        },
      })
      assignmentCount.upcoming++
    } catch {
      // Skip if exists
    }

    // Overdue assignment (not submitted)
    try {
      await prisma.assignment.create({
        data: {
          subjectId: enrollment.subjectId,
          sectionId: section.id,
          teacherId: section.teacherId,
          title: `${enrollment.subject.subjectName} - Quiz 1`,
          description: `Online quiz covering chapters 1-3 of ${enrollment.subject.subjectName}`,
          instructions: 'Complete within 30 minutes. No retakes allowed.',
          maxMarks: 50,
          assignedDate: new Date('2025-10-28'),
          dueDate: new Date('2025-11-05'),
          status: 'PUBLISHED',
        },
      })
      assignmentCount.overdue++
    } catch {
      // Skip if exists
    }

    // Additional past assignment (submitted but not graded)
    try {
      const pastAssignment2 = await prisma.assignment.create({
        data: {
          subjectId: enrollment.subjectId,
          sectionId: section.id,
          teacherId: section.teacherId,
          title: `${enrollment.subject.subjectName} - Lab Work 1`,
          description: `Practical lab exercises for ${enrollment.subject.subjectName}`,
          instructions: 'Complete all lab exercises and submit the report.',
          maxMarks: 50,
          assignedDate: new Date('2025-09-15'),
          dueDate: new Date('2025-09-30'),
          status: 'PUBLISHED',
        },
      })

      await prisma.submission.create({
        data: {
          assignmentId: pastAssignment2.id,
          studentId: student1.id,
          submittedAt: new Date('2025-09-29'),
          status: 'SUBMITTED',
        },
      })
      assignmentCount.past++
    } catch {
      // Skip if exists
    }

    // Additional past assignment (graded - high score)
    try {
      const pastAssignment3 = await prisma.assignment.create({
        data: {
          subjectId: enrollment.subjectId,
          sectionId: section.id,
          teacherId: section.teacherId,
          title: `${enrollment.subject.subjectName} - Midterm Project`,
          description: `Comprehensive project covering first half of ${enrollment.subject.subjectName}`,
          instructions:
            'Create a detailed project report with code examples and documentation.',
          maxMarks: 100,
          assignedDate: new Date('2025-09-01'),
          dueDate: new Date('2025-10-10'),
          status: 'PUBLISHED',
        },
      })

      await prisma.submission.create({
        data: {
          assignmentId: pastAssignment3.id,
          studentId: student1.id,
          submittedAt: new Date('2025-10-09'),
          status: 'GRADED',
          marksObtained: 92,
          feedback:
            'Outstanding work! Excellent understanding of concepts and clear presentation.',
          gradedBy: section.teacherId,
          gradedAt: new Date('2025-10-12'),
        },
      })
      assignmentCount.past++
    } catch {
      // Skip if exists
    }

    // Additional overdue assignment (recently overdue)
    try {
      await prisma.assignment.create({
        data: {
          subjectId: enrollment.subjectId,
          sectionId: section.id,
          teacherId: section.teacherId,
          title: `${enrollment.subject.subjectName} - Reading Assignment`,
          description: `Read chapters 5-7 and submit summary for ${enrollment.subject.subjectName}`,
          instructions: 'Write a 2-page summary of key concepts.',
          maxMarks: 30,
          assignedDate: new Date('2025-11-01'),
          dueDate: new Date('2025-11-08'),
          status: 'PUBLISHED',
        },
      })
      assignmentCount.overdue++
    } catch {
      // Skip if exists
    }
  }

  // Create examinations
  const examCount = { past: 0, upcoming: 0 }
  for (let i = 0; i < enrollments.length && i < sections.length; i++) {
    const enrollment = enrollments[i]
    const section = sections[i]

    // Past exam (graded)
    try {
      const midtermExam = await prisma.examination.create({
        data: {
          subject: { connect: { id: enrollment.subjectId } },
          semester: { connect: { id: latestSemester.id } },
          creator: { connect: { id: section.teacherId } },
          examName: `${enrollment.subject.subjectName} - Midterm Exam`,
          examType: 'MIDTERM',
          totalMarks: 100,
          passingMarks: 40,
          durationMinutes: 120,
          examDate: new Date('2025-10-20'),
          venue: 'Exam Hall A',
          instructions:
            'Bring your ID card. No electronic devices allowed. Answer all questions.',
          status: 'COMPLETED',
        },
      })

      await prisma.examResult.create({
        data: {
          examId: midtermExam.id,
          studentId: student1.id,
          marksObtained: 78,
          grade: 'B+',
          rankInClass: 5,
          remarks: 'Good performance. Focus on time management.',
          isAbsent: false,
          evaluatedBy: section.teacherId,
          evaluatedAt: new Date('2025-10-25'),
        },
      })
      examCount.past++
    } catch {
      // Skip if exists
    }

    // Upcoming exam
    try {
      await prisma.examination.create({
        data: {
          subject: { connect: { id: enrollment.subjectId } },
          semester: { connect: { id: latestSemester.id } },
          creator: { connect: { id: section.teacherId } },
          examName: `${enrollment.subject.subjectName} - Final Exam`,
          examType: 'FINAL',
          totalMarks: 100,
          passingMarks: 40,
          durationMinutes: 180,
          examDate: new Date('2025-11-25'),
          venue: 'Exam Hall B',
          instructions:
            'Comprehensive exam covering all topics. Bring calculator and drawing instruments.',
          status: 'SCHEDULED',
        },
      })
      examCount.upcoming++
    } catch {
      // Skip if exists
    }
  }

  // Create attendance records (last 30 days)
  let attendanceCount = 0
  for (const section of sections) {
    for (let i = 30; i >= 0; i--) {
      const date = new Date()
      date.setDate(date.getDate() - i)

      // Skip weekends
      if (date.getDay() === 0 || date.getDay() === 6) continue

      // Determine status (90% present, 5% late, 5% absent)
      let status: 'PRESENT' | 'LATE' | 'ABSENT' | 'EXCUSED' = 'PRESENT'
      const random = Math.random()
      if (random < 0.05) status = 'ABSENT'
      else if (random < 0.1) status = 'LATE'

      try {
        await prisma.attendance.create({
          data: {
            studentId: student1.id,
            sectionId: section.id,
            date: new Date(
              Date.UTC(date.getFullYear(), date.getMonth(), date.getDate())
            ),
            status: status,
            remarks:
              status === 'LATE'
                ? 'Arrived 10 minutes late'
                : status === 'ABSENT'
                  ? 'Medical leave'
                  : undefined,
            markedBy: section.teacherId,
          },
        })
        attendanceCount++
      } catch {
        // Skip if exists
      }
    }
  }

  // Create academic records for previous semesters
  const previousSemesters = semesters
    .filter(
      s =>
        s.semesterName.includes('2024') ||
        s.semesterName.includes('Jan') ||
        s.semesterName.includes('Feb')
    )
    .slice(0, 2)

  let academicRecordsCount = 0
  for (const semester of previousSemesters) {
    for (const enrollment of enrollments) {
      try {
        await prisma.academicRecord.upsert({
          where: {
            unique_record: {
              studentId: student1.id,
              semesterId: semester.id,
              subjectId: enrollment.subjectId,
            },
          },
          update: {
            marksObtained: 85,
            maxMarks: 100,
            grade: 'A',
            gradePoints: 4.0,
            creditsEarned: 3,
            status: 'PASSED',
            remarks: 'Good performance',
          },
          create: {
            studentId: student1.id,
            semesterId: semester.id,
            subjectId: enrollment.subjectId,
            marksObtained: 85,
            maxMarks: 100,
            grade: 'A',
            gradePoints: 4.0,
            creditsEarned: 3,
            status: 'PASSED',
            remarks: 'Good performance',
          },
        })
        academicRecordsCount++
      } catch {
        // Skip if exists
      }
    }
  }

  // Create StudentProgress records for Spring 2025
  const spring2025 = semesters.find(s => s.semesterName === 'Spring 2025')
  const currentAcademicYear = await prisma.academicYear.findFirst({
    where: { status: 'CURRENT' },
  })
  const institution = await prisma.institution.findFirst()

  let studentProgressCount = 0
  if (spring2025 && currentAcademicYear && institution) {
    // Get subjects for enrolled students
    for (const enrollment of enrollments) {
      // Get the subject from enrollment
      const subject = enrollment.subject

      // Create StudentProgress record
      try {
        await prisma.studentProgress.create({
          data: {
            studentId: student1.id,
            subjectId: subject.id,
            semesterId: spring2025.id,
            academicYearId: currentAcademicYear.id,
            overallGrade: 'A',
            gradePoints: 4.0,
            attendancePercentage: 92.5,
            assignmentScore: 85.0,
            examScore: 78.0,
            participationScore: 88.0,
            status: 'ON_TRACK',
            strengths: [
              'Strong analytical skills',
              'Good problem-solving',
              'Active participation',
            ],
            areasForImprovement: [
              'Time management',
              'More practice with complex topics',
            ],
            teacherComments:
              'Excellent progress this semester. Keep up the good work!',
          },
        })
        studentProgressCount++
      } catch {
        // Skip if exists
      }
    }
  }

  console.log(
    `     ✅ Assignments: ${assignmentCount.past} past, ${assignmentCount.upcoming} upcoming, ${assignmentCount.overdue} overdue`
  )
  console.log(
    `     ✅ Exams: ${examCount.past} past, ${examCount.upcoming} upcoming`
  )
  console.log(`     ✅ Attendance: ${attendanceCount} records`)
  console.log(`     ✅ Academic Records: ${academicRecordsCount}`)
  console.log(`     ✅ Student Progress: ${studentProgressCount} records`)
}

main()
  .catch(e => {
    console.error('❌ Error during seeding:', e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
