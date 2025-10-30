/**
 * EdVerse ID Examples and Test Cases
 *
 * This file demonstrates the new EdVerse ID generation with variable-length
 * institution codes (2-4 characters)
 */

import {
  generateEdVerseId,
  generateInstitutionCode,
  getRoleNameFromEdVerseId,
  isValidEdVerseId,
  parseEdVerseId,
} from './edverse-id.util'

/**
 * Example institution names and their generated codes
 */
export const INSTITUTION_EXAMPLES = [
  // Universities (often 2-4 character codes)
  { name: 'Delhi University', expectedCode: 'DU' },
  { name: 'Manipal University', expectedCode: 'MU' },
  { name: 'Amity University', expectedCode: 'AU' },
  { name: 'Jawaharlal Nehru University', expectedCode: 'JNU' },
  { name: 'Indian Institute of Technology Delhi', expectedCode: 'IITD' },
  { name: 'Indian Institute of Technology Bombay', expectedCode: 'IITB' },
  { name: 'Indian Institute of Technology Kanpur', expectedCode: 'IITK' },
  { name: 'Symbiosis International University', expectedCode: 'SIU' },

  // Schools (typically 3-4 character codes)
  { name: 'Delhi Public School', expectedCode: 'DPS' },
  { name: "St. Xavier's High School", expectedCode: 'SXHS' },
  { name: 'Modern School Delhi', expectedCode: 'MSD' },
  { name: 'The Heritage School', expectedCode: 'THS' },
  { name: 'Kendriya Vidyalaya Sector 8', expectedCode: 'KVS' },
  { name: 'Birla Public School', expectedCode: 'BPS' },
  { name: 'Ryan International School', expectedCode: 'RIS' },

  // Colleges (typically 2-3 character codes)
  { name: "St. Stephen's College", expectedCode: 'SSC' },
  { name: 'Hindu College Delhi', expectedCode: 'HCD' },
  { name: 'Miranda House', expectedCode: 'MH' },
  { name: 'Ramjas College', expectedCode: 'RC' },
  { name: 'Lady Shri Ram College', expectedCode: 'LSR' },
  { name: 'Hansraj College', expectedCode: 'HC' },

  // Technical Institutes
  { name: 'Birla Institute of Technology and Science', expectedCode: 'BITS' },
  { name: 'RV College of Engineering', expectedCode: 'RVCE' },
  { name: 'National Institute of Technology', expectedCode: 'NIT' },
]

/**
 * Run examples to demonstrate code generation
 */
export function runExamples() {
  console.log('='.repeat(80))
  console.log(
    'EdVerse ID Generation Examples with Variable-Length Institution Codes'
  )
  console.log('='.repeat(80))
  console.log()

  const existingCodes: string[] = []

  INSTITUTION_EXAMPLES.forEach(({ name, expectedCode }) => {
    const generatedCode = generateInstitutionCode(name, existingCodes)
    existingCodes.push(generatedCode)

    const match = generatedCode === expectedCode ? '✅' : '⚠️'

    console.log(`Institution: ${name}`)
    console.log(`  Generated Code: ${generatedCode} ${match}`)
    console.log(`  Code Length: ${generatedCode.length} characters`)

    // Generate sample EdVerse IDs for different roles
    const studentId = generateEdVerseId(generatedCode, 'student')
    const teacherId = generateEdVerseId(generatedCode, 'teacher')
    const adminId = generateEdVerseId(generatedCode, 'admin')

    console.log(`  Sample Student ID: ${studentId} (${studentId.length} chars)`)
    console.log(`  Sample Teacher ID: ${teacherId} (${teacherId.length} chars)`)
    console.log(`  Sample Admin ID:   ${adminId} (${adminId.length} chars)`)
    console.log()
  })

  console.log('='.repeat(80))
  console.log('EdVerse ID Parsing Examples')
  console.log('='.repeat(80))
  console.log()

  // Demonstrate parsing
  const exampleIds = [
    'DPS-S25-K8M2', // 2-char school
    'DU-T25-P9X7', // 2-char university
    'SSC-AD25-L3N8', // 3-char college
    'IITD-S25-Q4R6', // 4-char institute
  ]

  exampleIds.forEach(id => {
    console.log(`EdVerse ID: ${id}`)
    console.log(`  Valid: ${isValidEdVerseId(id) ? '✅' : '❌'}`)

    const parsed = parseEdVerseId(id)
    if (parsed) {
      console.log(`  Institution Code: ${parsed.institutionCode}`)
      console.log(`  Role Code: ${parsed.roleCode}`)
      console.log(`  Year: ${parsed.year}`)
      console.log(`  Random Code: ${parsed.randomCode}`)
      console.log(`  Role Name: ${getRoleNameFromEdVerseId(id)}`)
    }
    console.log()
  })

  console.log('='.repeat(80))
  console.log('Length Distribution Analysis')
  console.log('='.repeat(80))
  console.log()

  const lengthDistribution: Record<number, number> = {}
  const idLengthDistribution: Record<number, number> = {}

  existingCodes.forEach(code => {
    lengthDistribution[code.length] = (lengthDistribution[code.length] || 0) + 1

    // Generate a sample ID to check total length
    const sampleId = generateEdVerseId(code, 'student')
    idLengthDistribution[sampleId.length] =
      (idLengthDistribution[sampleId.length] || 0) + 1
  })

  console.log('Institution Code Lengths:')
  Object.entries(lengthDistribution).forEach(([length, count]) => {
    console.log(`  ${length} characters: ${count} institutions`)
  })

  console.log()
  console.log('EdVerse ID Lengths:')
  Object.entries(idLengthDistribution).forEach(([length, count]) => {
    console.log(`  ${length} characters: ${count} IDs`)
  })
  console.log()

  console.log('='.repeat(80))
  console.log('Key Features:')
  console.log('='.repeat(80))
  console.log('✅ Variable-length institution codes (2-4 characters)')
  console.log('✅ Automatic acronym generation from institution names')
  console.log('✅ Duplicate handling with numeric suffixes')
  console.log('✅ Compact EdVerse IDs (11-14 characters total)')
  console.log('✅ Random 4-character code for security')
  console.log('✅ Excludes ambiguous characters (0, O, 1, I)')
  console.log('✅ Human-readable and easy to communicate')
  console.log('✅ Institution and role visible at a glance')
  console.log()
}

// Run if executed directly
if (require.main === module) {
  runExamples()
}
