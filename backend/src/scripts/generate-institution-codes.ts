/**
 * Script to generate institution codes for existing institutions
 *
 * This script:
 * 1. Fetches all institutions from the database
 * 2. Generates unique 2-4 character codes based on institution names
 * 3. Updates each institution with its generated code
 *
 * Run with: npx ts-node src/scripts/generate-institution-codes.ts
 */

import { PrismaClient } from '@prisma/client'
import { generateInstitutionCode } from '../utils/edverse-id.util'

const prisma = new PrismaClient()

async function main() {
  console.log('🚀 Starting institution code generation...\n')

  try {
    // Get all institutions
    const institutions = await prisma.institution.findMany({
      orderBy: { id: 'asc' },
    })

    if (institutions.length === 0) {
      console.log('⚠️  No institutions found in database')
      return
    }

    console.log(`📊 Found ${institutions.length} institutions to process\n`)

    // Track existing codes to avoid duplicates
    const existingCodes: string[] = []
    let updatedCount = 0
    let skippedCount = 0

    for (const institution of institutions) {
      // Skip if institution already has a code
      if (institution.code) {
        console.log(
          `⏭️  Skipping "${institution.name}" - already has code: ${institution.code}`
        )
        existingCodes.push(institution.code)
        skippedCount++
        continue
      }

      // Generate unique code
      const code = generateInstitutionCode(institution.name, existingCodes)
      existingCodes.push(code)

      // Update institution with code
      await prisma.institution.update({
        where: { id: institution.id },
        data: { code },
      })

      updatedCount++
      console.log(
        `✅ ${institution.name.padEnd(50)} → ${code} (${code.length} chars)`
      )
    }

    console.log('\n' + '='.repeat(80))
    console.log('📋 Summary:')
    console.log('='.repeat(80))
    console.log(
      `✨ Successfully generated codes for ${updatedCount} institutions`
    )
    if (skippedCount > 0) {
      console.log(
        `⏭️  Skipped ${skippedCount} institutions (already had codes)`
      )
    }
    console.log()

    // Show code length distribution
    const lengthDistribution: Record<number, number> = {}
    existingCodes.forEach(code => {
      lengthDistribution[code.length] =
        (lengthDistribution[code.length] || 0) + 1
    })

    console.log('Code Length Distribution:')
    Object.entries(lengthDistribution)
      .sort(([a], [b]) => Number(a) - Number(b))
      .forEach(([length, count]) => {
        console.log(`  ${length} characters: ${count} institutions`)
      })

    console.log()
    console.log('✅ Institution code generation complete!')
  } catch (error) {
    console.error('❌ Error:', error)
    throw error
  } finally {
    await prisma.$disconnect()
  }
}

main().catch(error => {
  console.error(error)
  process.exit(1)
})
