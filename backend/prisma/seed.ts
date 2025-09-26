import { PrismaClient } from '@prisma/client'
import bcrypt from 'bcryptjs'

const prisma = new PrismaClient()

async function main() {
  console.log('🌱 Starting database seeding...')

  // Create roles
  console.log('Creating roles...')
  const roles = await Promise.all([
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
        ],
      },
    }),
  ])

  console.log(`✅ Created ${roles.length} roles`)

  // Create sample institution
  console.log('Creating sample institution...')
  const institution = await prisma.institution.upsert({
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

  console.log(`✅ Created institution: ${institution.name}`)

  // Create sample department
  console.log('Creating sample department...')
  const department = await prisma.department.upsert({
    where: { id: 1 },
    update: {},
    create: {
      institutionId: institution.id,
      name: 'Computer Science',
      code: 'CS',
      description: 'Department of Computer Science and Engineering',
      budget: 500000.0,
    },
  })

  console.log(`✅ Created department: ${department.name}`)

  // Create sample program
  console.log('Creating sample program...')
  const program = await prisma.program.upsert({
    where: { id: 1 },
    update: {},
    create: {
      institutionId: institution.id,
      deptId: department.id,
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

  console.log(`✅ Created program: ${program.name}`)

  // Create sample courses
  console.log('Creating sample courses...')
  const courses = await Promise.all([
    prisma.course.upsert({
      where: { courseCode: 'CS101' },
      update: {},
      create: {
        programId: program.id,
        deptId: department.id,
        courseName: 'Introduction to Programming',
        courseCode: 'CS101',
        credits: 3,
        lectureHours: 3,
        labHours: 0,
        tutorialHours: 0,
        courseType: 'CORE',
        description: 'Fundamentals of programming using Python',
        syllabus:
          'Variables, data types, control structures, functions, and basic algorithms',
      },
    }),
    prisma.course.upsert({
      where: { courseCode: 'CS102' },
      update: {},
      create: {
        programId: program.id,
        deptId: department.id,
        courseName: 'Data Structures and Algorithms',
        courseCode: 'CS102',
        credits: 4,
        lectureHours: 3,
        labHours: 2,
        tutorialHours: 0,
        courseType: 'CORE',
        prerequisites: JSON.stringify(['CS101']),
        description:
          'Study of fundamental data structures and algorithm design',
        syllabus:
          'Arrays, linked lists, stacks, queues, trees, graphs, sorting, and searching algorithms',
      },
    }),
    prisma.course.upsert({
      where: { courseCode: 'CS201' },
      update: {},
      create: {
        programId: program.id,
        deptId: department.id,
        courseName: 'Web Development',
        courseCode: 'CS201',
        credits: 3,
        lectureHours: 2,
        labHours: 2,
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

  console.log(`✅ Created ${courses.length} courses`)

  // Create super admin user
  console.log('Creating super admin user...')
  const superAdminPassword = await bcrypt.hash('admin123!', 12)
  const superAdmin = await prisma.user.upsert({
    where: { email: 'admin@edverse.edu' },
    update: {},
    create: {
      name: 'Super Administrator',
      email: 'admin@edverse.edu',
      phone: '+1-555-0001',
      passwordHash: superAdminPassword,
      roleId: roles.find(r => r.roleName === 'super_admin')!.id,
      emailVerified: true,
      phoneVerified: true,
    },
  })

  console.log(`✅ Created super admin: ${superAdmin.email}`)

  // Create sample teacher
  console.log('Creating sample teacher...')
  const teacherPassword = await bcrypt.hash('teacher123!', 12)
  const teacherUser = await prisma.user.upsert({
    where: { email: 'john.doe@edverse.edu' },
    update: {},
    create: {
      name: 'Dr. John Doe',
      email: 'john.doe@edverse.edu',
      phone: '+1-555-0002',
      passwordHash: teacherPassword,
      roleId: roles.find(r => r.roleName === 'teacher')!.id,
      emailVerified: true,
      phoneVerified: true,
    },
  })

  await prisma.teacher.upsert({
    where: { employeeId: 'EMP001' },
    update: {},
    create: {
      userId: teacherUser.id,
      institutionId: institution.id,
      deptId: department.id,
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

  console.log(`✅ Created teacher: ${teacherUser.name}`)

  // Create sample student
  console.log('Creating sample student...')
  const studentPassword = await bcrypt.hash('student123!', 12)
  const studentUser = await prisma.user.upsert({
    where: { email: 'jane.smith@edverse.edu' },
    update: {},
    create: {
      name: 'Jane Smith',
      email: 'jane.smith@edverse.edu',
      phone: '+1-555-0003',
      passwordHash: studentPassword,
      roleId: roles.find(r => r.roleName === 'student')!.id,
      emailVerified: true,
      phoneVerified: true,
    },
  })

  const student = await prisma.student.upsert({
    where: { admissionNumber: 'ADM001' },
    update: {},
    create: {
      userId: studentUser.id,
      institutionId: institution.id,
      programId: program.id,
      admissionNumber: 'ADM001',
      rollNumber: '2024001',
      admissionDate: new Date('2024-08-15'),
      currentSemester: 1,
      currentYear: 1,
      gradeLevel: 'Freshman',
      section: 'A',
      studentType: 'REGULAR',
      residentialStatus: 'DAY_SCHOLAR',
      emergencyContactName: 'Robert Smith',
      emergencyContactPhone: '+1-555-0004',
      bloodGroup: 'O+',
    },
  })

  console.log(`✅ Created student: ${studentUser.name}`)

  // Create sample parent
  console.log('Creating sample parent...')
  const parentPassword = await bcrypt.hash('parent123!', 12)
  const parentUser = await prisma.user.upsert({
    where: { email: 'robert.smith@email.com' },
    update: {},
    create: {
      name: 'Robert Smith',
      email: 'robert.smith@email.com',
      phone: '+1-555-0004',
      passwordHash: parentPassword,
      roleId: roles.find(r => r.roleName === 'parent')!.id,
      emailVerified: true,
      phoneVerified: true,
    },
  })

  await prisma.parent.upsert({
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

  console.log(`✅ Created parent: ${parentUser.name}`)

  console.log('🎉 Database seeding completed successfully!')
  console.log('\n📋 Sample Accounts Created:')
  console.log('Super Admin: admin@edverse.edu / admin123!')
  console.log('Teacher: john.doe@edverse.edu / teacher123!')
  console.log('Student: jane.smith@edverse.edu / student123!')
  console.log('Parent: robert.smith@email.com / parent123!')
}

main()
  .catch(e => {
    console.error('❌ Error during seeding:', e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
