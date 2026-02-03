const fs = require('fs')
const path = require('path')

// Build script to combine individual schema files into main schema.prisma
const schemaDir = path.join(__dirname, '../prisma/schema')
const outputFile = path.join(__dirname, '../prisma/schema.prisma')

// Main schema configuration
const mainSchema = `// This is your Prisma schema file,
// learn more about it in the docs: https://pris.ly/d/prisma-schema

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql" // or "mysql", "sqlite", etc.
  url      = env("DATABASE_URL")
}

// ============================================================================
// MULTI-FILE SCHEMA ORGANIZATION
// ============================================================================
// This schema is automatically generated from individual files in /prisma/schema/
// To modify models, edit the individual files and run: npm run build:schema
// ============================================================================

`

// Read and combine all schema files
let combinedSchema = mainSchema

const schemaFiles = [
  'core.prisma',
  'academic.prisma',
  'users.prisma',
  'records.prisma',
  'assessment.prisma',
  'fees.prisma',
  'communication.prisma',
  'library.prisma',
  'staff.prisma',
  'gatepass.prisma',
  'timetable.prisma',
  'analytics.prisma',
  'question-paper.prisma',
]

console.log('Building schema from individual files...')

schemaFiles.forEach(file => {
  const filePath = path.join(schemaDir, file)
  if (fs.existsSync(filePath)) {
    console.log(`  ✓ Including ${file}`)
    const content = fs.readFileSync(filePath, 'utf8')
    // Remove the section header comments from individual files to avoid duplication
    const cleanContent = content.replace(
      /^\/\/ ============================================================================\n.*\n\/\/ ============================================================================\n\n/gm,
      ''
    )
    combinedSchema += `\n${cleanContent}\n`
  } else {
    console.log(`  ⚠ Skipping ${file} (not found)`)
  }
})

// Write the combined schema
fs.writeFileSync(outputFile, combinedSchema)
console.log(`\n✅ Schema built successfully!`)
console.log(`📁 Output: ${outputFile}`)
console.log(`📊 Total files processed: ${schemaFiles.length}`)
