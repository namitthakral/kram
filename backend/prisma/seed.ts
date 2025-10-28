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

  // Create program and courses
  console.log('Creating program and courses...')
  const { program, courses } = await createProgramAndCourses(institution.id)
  console.log(
    `✅ Created program: ${program.name} with ${courses.length} courses`
  )

  // Create subjects
  console.log('Creating subjects...')
  const subjects = await createSubjects(institution.id)
  console.log(`✅ Created ${subjects.length} subjects`)

  // Create users (admin, teacher, students, parents, staff)
  console.log('Creating users...')
  const { superAdmin, teacher, students, parents, librarian } =
    await createUsers(roles, institution.id, program.id)
  console.log(
    `✅ Created users: 1 admin, 1 teacher, ${students.length} students, ${parents.length} parents, 2 staff`
  )

  // Create class sections and enrollments
  console.log('Creating class sections and enrollments...')
  const classSections = await createClassSections(
    courses,
    semesters[0],
    teacher
  )
  await createEnrollments(students, courses, semesters[0])
  console.log(
    `✅ Created ${classSections.length} class sections and enrollments`
  )

  // Create notices and announcements
  console.log('Creating notices and announcements...')
  const notices = await createNotices(
    institution.id,
    superAdmin.id,
    librarian.id
  )
  const announcements = await createAnnouncements(institution.id, superAdmin.id)
  console.log(
    `✅ Created ${notices.length} notices and ${announcements.length} announcements`
  )

  // Create library data
  console.log('Creating library data...')
  const books = await createLibraryData(institution.id, librarian.id)
  console.log(`✅ Created library with ${books.length} books`)

  // Create fee structures
  console.log('Creating fee structures...')
  const feeStructures = await createFeeStructures(
    institution.id,
    program.id,
    academicYear.id
  )
  await createStudentFees(students, feeStructures, semesters[0])
  console.log(`✅ Created ${feeStructures.length} fee structures`)

  // Create assignments and examinations
  console.log('Creating assignments and examinations...')
  const assignments = await createAssignments(courses, classSections, teacher)
  const examinations = await createExaminations(courses, semesters[0], teacher)
  console.log(
    `✅ Created ${assignments.length} assignments and ${examinations.length} examinations`
  )

  // Create timetable data
  console.log('Creating timetable data...')
  const { timeSlots, rooms, timetables } = await createTimetableData(
    institution.id,
    academicYear.id,
    semesters[0],
    program.id,
    subjects,
    teacher
  )
  console.log(
    `✅ Created ${timeSlots.length} time slots, ${rooms.length} rooms, ${timetables.length} timetable entries`
  )

  // Create dashboard stats
  console.log('Creating dashboard stats...')
  const dashboardStats = await createDashboardStats(
    institution.id,
    students.length
  )
  console.log(`✅ Created ${dashboardStats.length} dashboard statistics`)

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

  console.log('🎉 Comprehensive database seeding completed successfully!')
  printSummary(students.length, parents.length)
}

async function createRoles() {
  return await Promise.all([
    prisma.role.upsert({
      where: { roleName: 'super_admin' },
      update: {},
      create: {
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
    }),
    prisma.role.upsert({
      where: { roleName: 'admin' },
      update: {},
      create: {
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
    }),
    prisma.role.upsert({
      where: { roleName: 'teacher' },
      update: {},
      create: {
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
    }),
    prisma.role.upsert({
      where: { roleName: 'student' },
      update: {},
      create: {
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
    }),
    prisma.role.upsert({
      where: { roleName: 'parent' },
      update: {},
      create: {
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
    }),
    prisma.role.upsert({
      where: { roleName: 'librarian' },
      update: {},
      create: {
        roleName: 'librarian',
        description: 'Library Staff',
        permissions: [
          'canManageBooks',
          'canManageBookIssues',
          'canViewLibraryReports',
          'canManageLibrarySettings',
        ],
      },
    }),
    prisma.role.upsert({
      where: { roleName: 'staff' },
      update: {},
      create: {
        roleName: 'staff',
        description: 'Support Staff',
        permissions: ['canViewOwnData', 'canMarkAttendance', 'canViewNotices'],
      },
    }),
  ])
}

async function createInstitution() {
  return await prisma.institution.upsert({
    where: { id: 1 },
    update: {},
    create: {
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

async function createProgramAndCourses(institutionId: number) {
  const program = await prisma.program.upsert({
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

  const courses = await Promise.all([
    prisma.course.upsert({
      where: { courseCode: 'CS101' },
      update: {},
      create: {
        programId: program.id,
        courseName: 'Introduction to Programming',
        courseCode: 'CS101',
        credits: 3,
        lectureHours: 3,
        labHours: 2,
        tutorialHours: 1,
        courseType: 'CORE',
        description: 'Fundamentals of programming using Python',
        syllabus:
          'Variables, loops, functions, data structures, and basic algorithms',
      },
    }),
    prisma.course.upsert({
      where: { courseCode: 'CS102' },
      update: {},
      create: {
        programId: program.id,
        courseName: 'Data Structures and Algorithms',
        courseCode: 'CS102',
        credits: 4,
        lectureHours: 3,
        labHours: 2,
        tutorialHours: 1,
        courseType: 'CORE',
        prerequisites: JSON.stringify(['CS101']),
        description: 'Advanced data structures and algorithm design',
        syllabus:
          'Arrays, linked lists, trees, graphs, sorting, and searching algorithms',
      },
    }),
    prisma.course.upsert({
      where: { courseCode: 'CS201' },
      update: {},
      create: {
        programId: program.id,
        courseName: 'Web Development',
        courseCode: 'CS201',
        credits: 3,
        lectureHours: 2,
        labHours: 3,
        tutorialHours: 0,
        courseType: 'CORE',
        prerequisites: JSON.stringify(['CS101']),
        description:
          'Modern web development using HTML, CSS, JavaScript, and frameworks',
        syllabus:
          'HTML5, CSS3, JavaScript ES6+, React, Node.js, and database integration',
      },
    }),
  ])

  return { program, courses }
}

async function createSubjects(institutionId: number) {
  return await Promise.all([
    prisma.subject.upsert({
      where: { unique_subject_code: { institutionId, code: 'MATH101' } },
      update: {},
      create: {
        institutionId,
        name: 'Calculus I',
        code: 'MATH101',
        description: 'Differential and integral calculus',
        subjectType: 'CORE',
        credits: 4,
        theoryHours: 4,
        practicalHours: 0,
      },
    }),
    prisma.subject.upsert({
      where: { unique_subject_code: { institutionId, code: 'ENG101' } },
      update: {},
      create: {
        institutionId,
        name: 'English Composition',
        code: 'ENG101',
        description: 'Academic writing and communication skills',
        subjectType: 'CORE',
        credits: 3,
        theoryHours: 3,
        practicalHours: 0,
      },
    }),
  ])
}

async function createUsers(
  roles: any[],
  institutionId: number,
  programId: number
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
      edverseId: generateEdVerseId('super_admin', 1, 2024),
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
      edverseId: generateEdVerseId('teacher', 1, 2024),
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
        edverseId: generateEdVerseId('student', i, 2024),
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
        programId,
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
        edverseId: generateEdVerseId('parent', i, 2024),
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
      edverseId: generateEdVerseId('staff', 1, 2024),
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
      edverseId: generateEdVerseId('librarian', 1, 2024),
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
  courses: any[],
  semester: any,
  teacher: any
) {
  return await Promise.all([
    prisma.classSection.upsert({
      where: { id: 1 },
      update: {},
      create: {
        courseId: courses[0].id,
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
        courseId: courses[1].id,
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
  courses: any[],
  semester: any
) {
  for (const student of students) {
    for (const course of courses) {
      await prisma.enrollment.upsert({
        where: {
          unique_enrollment: {
            studentId: student.id,
            courseId: course.id,
            semesterId: semester.id,
          },
        },
        update: {},
        create: {
          studentId: student.id,
          courseId: course.id,
          semesterId: semester.id,
          enrollmentDate: new Date('2024-08-15'),
          enrollmentStatus: 'ENROLLED',
          creditsEarned: course.credits,
          attendancePercentage: 85.0,
        },
      })
    }
  }
}

async function createNotices(
  institutionId: number,
  adminId: number,
  librarianId: number
) {
  return await Promise.all([
    prisma.notice.upsert({
      where: { id: 1 },
      update: {},
      create: {
        institutionId,
        title: 'Welcome to Fall 2024 Semester',
        content:
          'Welcome all students to the Fall 2024 semester. Classes begin on August 15th.',
        noticeType: 'GENERAL',
        priority: 'HIGH',
        targetAudience: ['student', 'teacher', 'parent'],
        publishDate: new Date('2024-08-01'),
        isActive: true,
        isPinned: true,
        createdBy: adminId,
      },
    }),
    prisma.notice.upsert({
      where: { id: 2 },
      update: {},
      create: {
        institutionId,
        title: 'Library Hours Update',
        content:
          'The library will be open from 8 AM to 10 PM during the semester.',
        noticeType: 'GENERAL',
        priority: 'MEDIUM',
        targetAudience: ['student', 'teacher'],
        publishDate: new Date('2024-08-05'),
        isActive: true,
        isPinned: false,
        createdBy: librarianId,
      },
    }),
  ])
}

async function createAnnouncements(institutionId: number, adminId: number) {
  return await Promise.all([
    prisma.announcement.upsert({
      where: { id: 1 },
      update: {},
      create: {
        institutionId,
        title: 'New Computer Lab Opening',
        content:
          'We are excited to announce the opening of our new state-of-the-art computer lab.',
        announcementType: 'GENERAL',
        priority: 'HIGH',
        targetAudience: ['student', 'teacher'],
        isEmergency: false,
        publishDate: new Date('2024-08-10'),
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
  programId: number,
  academicYearId: number
) {
  return await Promise.all([
    prisma.feeStructure.upsert({
      where: { id: 1 },
      update: {},
      create: {
        institutionId,
        programId,
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
        programId,
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
  courses: any[],
  classSections: any[],
  teacher: any
) {
  return await Promise.all([
    prisma.assignment.upsert({
      where: { id: 1 },
      update: {},
      create: {
        courseId: courses[0].id,
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

async function createExaminations(courses: any[], semester: any, teacher: any) {
  return await Promise.all([
    prisma.examination.upsert({
      where: { id: 1 },
      update: {},
      create: {
        courseId: courses[0].id,
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
  programId: number,
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
        programId,
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

async function createDashboardStats(
  institutionId: number,
  studentCount: number
) {
  return await Promise.all([
    prisma.dashboardStats.upsert({
      where: { id: 1 },
      update: {},
      create: {
        institutionId,
        statType: 'attendance',
        statName: 'Overall Attendance Rate',
        statValue: 85.5,
        statUnit: 'percentage',
        period: 'monthly',
        periodStart: new Date('2024-08-01'),
        periodEnd: new Date('2024-08-31'),
        metadata: { department: 'Computer Science', semester: 'Fall 2024' },
      },
    }),
    prisma.dashboardStats.upsert({
      where: { id: 2 },
      update: {},
      create: {
        institutionId,
        statType: 'enrollment',
        statName: 'Total Students',
        statValue: studentCount,
        statUnit: 'count',
        period: 'yearly',
        periodStart: new Date('2024-08-01'),
        periodEnd: new Date('2025-07-31'),
      },
    }),
  ])
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
  console.log('- 2 notices + 1 announcement')
  console.log('- 2 books with library settings')
  console.log('- 2 fee structures with student fees')
  console.log('- 1 assignment + 1 examination')
  console.log('- 2 time slots + 2 rooms + 1 timetable entry')
  console.log('- 2 dashboard statistics')
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
  const gradePoints = {
    'A+': 4.0,
    A: 3.7,
    'A-': 3.3,
    'B+': 3.0,
    B: 2.7,
    'B-': 2.3,
    'C+': 2.0,
    C: 1.7,
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

      // Determine grade based on average
      const avgScore = (assignmentScore + examScore) / 2
      let grade = 'B'
      if (avgScore >= 93) grade = 'A+'
      else if (avgScore >= 90) grade = 'A'
      else if (avgScore >= 87) grade = 'A-'
      else if (avgScore >= 83) grade = 'B+'
      else if (avgScore >= 80) grade = 'B'
      else if (avgScore >= 77) grade = 'B-'
      else if (avgScore >= 73) grade = 'C+'
      else grade = 'C'

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
            edverseId: generateEdVerseId('student', i, 2024),
            emailVerified: true,
            phoneVerified: true,
          },
        })

        const student = await prisma.student.create({
          data: {
            userId: studentUser.id,
            institutionId: students[0].institutionId,
            programId: students[0].programId,
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
          else if (avgScore >= 90) grade = 'A'
          else if (avgScore >= 87) grade = 'A-'
          else if (avgScore >= 83) grade = 'B+'
          else if (avgScore >= 80) grade = 'B'
          else if (avgScore >= 77) grade = 'B-'
          else if (avgScore >= 73) grade = 'C+'
          else grade = 'C'

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

main()
  .catch(e => {
    console.error('❌ Error during seeding:', e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
