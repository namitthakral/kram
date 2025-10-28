/**
 * Script to check for users without EdVerse IDs
 *
 * Run with: npx ts-node src/scripts/check-missing-edverse-ids.ts
 */

import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {
  console.log('🔍 Checking for users without EdVerse IDs...\n')

  try {
    // Get users without EdVerse ID
    const usersWithoutEdverseId = await prisma.user.findMany({
      where: {
        edverseId: null,
      },
      include: {
        role: true,
      },
      orderBy: {
        id: 'asc',
      },
    })

    if (usersWithoutEdverseId.length === 0) {
      console.log('✅ All users have EdVerse IDs!')
      console.log('\n✨ Database is up to date. No action needed.')
    } else {
      console.log(
        `⚠️  Found ${usersWithoutEdverseId.length} users without EdVerse IDs:\n`
      )

      usersWithoutEdverseId.forEach(user => {
        console.log(
          `   - User ID ${user.id}: ${user.name} (${user.role.roleName})`
        )
      })

      console.log('\n📝 To fix this, run:')
      console.log('   npx ts-node src/scripts/populate-uuid-edverse-id.ts')
    }

    // Also check for users without UUID
    const usersWithoutUuid = await prisma.user.findMany({
      where: {
        uuid: null,
      },
    })

    if (usersWithoutUuid.length > 0) {
      console.log(`\n⚠️  Found ${usersWithoutUuid.length} users without UUID`)
      console.log('   (UUIDs are auto-generated, this should not happen)')
    }
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
