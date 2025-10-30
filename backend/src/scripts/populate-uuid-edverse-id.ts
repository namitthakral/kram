/**
 * Script to populate UUID and EdVerse ID for existing users
 *
 * This script:
 * 1. Generates UUID for all users who don't have one
 * 2. Generates EdVerse ID for all users based on their institution and role
 *
 * NOTE: This script requires all institutions to have codes generated first.
 * Run generate-institution-codes.ts before running this script.
 *
 * Run with: npx ts-node src/scripts/populate-uuid-edverse-id.ts
 */

import { PrismaClient } from '@prisma/client'
import { generateEdVerseId } from '../utils/edverse-id.util'

const prisma = new PrismaClient()

async function main() {
  console.log('🚀 Starting EdVerse ID migration to new format...\n')

  try {
    // First, ensure all institutions have codes
    const institutions = await prisma.institution.findMany()

    console.log(`📊 Found ${institutions.length} institutions\n`)

    const institutionsWithoutCode = institutions.filter(inst => !inst.code)
    if (institutionsWithoutCode.length > 0) {
      console.log('❌ ERROR: Some institutions do not have codes:')
      institutionsWithoutCode.forEach(inst => {
        console.log(`   - ${inst.name} (ID: ${inst.id})`)
      })
      console.log(
        '\n⚠️  Please run generate-institution-codes.ts first to generate codes for all institutions.'
      )
      return
    }

    console.log('✅ All institutions have codes\n')

    // Get all users with their institutions and roles
    const users = await prisma.user.findMany({
      include: {
        role: true,
        student: {
          include: {
            institution: true,
          },
        },
        teacher: {
          include: {
            institution: true,
          },
        },
        staff: {
          include: {
            institution: true,
          },
        },
      },
      orderBy: {
        id: 'asc',
      },
    })

    console.log(`📊 Found ${users.length} users to process\n`)

    let updatedCount = 0
    let skippedCount = 0
    const errors: string[] = []

    for (const user of users) {
      try {
        // Determine institution from user's role-specific data
        let institution = null

        if (user.student?.institution) {
          institution = user.student.institution
        } else if (user.teacher?.institution) {
          institution = user.teacher.institution
        } else if (user.staff?.institution) {
          institution = user.staff.institution
        }

        // Skip users without institution (e.g., super admins, parents without mapping)
        if (!institution) {
          console.log(
            `⚠️  Skipping user ${user.id}: ${user.name} (${user.role.roleName}) - No institution found`
          )
          skippedCount++
          continue
        }

        // Skip if user already has a new-format EdVerse ID
        if (
          user.edverseId &&
          /^[A-Z0-9]{2,4}-[A-Z]{1,2}\d{2}-[A-Z0-9]{4}$/.test(user.edverseId)
        ) {
          console.log(
            `⏭️  Skipping user ${user.id}: ${user.name} - Already has new format ID: ${user.edverseId}`
          )
          skippedCount++
          continue
        }

        // Generate new EdVerse ID
        const year = new Date(user.createdAt).getFullYear()
        const edverseId = generateEdVerseId(
          institution.code,
          user.role.roleName,
          year
        )

        // Update user
        await prisma.user.update({
          where: { id: user.id },
          data: { edverseId },
        })

        updatedCount++
        console.log(
          `✅ Updated user ${user.id}: ${user.name.padEnd(30)} → ${edverseId}`
        )
      } catch (error) {
        const errorMsg = `Failed to update user ${user.id} (${user.name}): ${error.message}`
        console.error(`❌ ${errorMsg}`)
        errors.push(errorMsg)
      }
    }

    console.log('\n' + '='.repeat(80))
    console.log('📋 Summary:')
    console.log('='.repeat(80))
    console.log(`✨ Successfully updated ${updatedCount} users`)
    if (skippedCount > 0) {
      console.log(
        `⏭️  Skipped ${skippedCount} users (no institution or already updated)`
      )
    }
    if (errors.length > 0) {
      console.log(`❌ Failed to update ${errors.length} users`)
      console.log('\nErrors:')
      errors.forEach(err => console.log(`   - ${err}`))
    }
    console.log()
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
