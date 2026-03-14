import { PrismaClient } from '@prisma/client'
const prisma = new PrismaClient()
async function run() {
  const users = await prisma.user.findMany({
    where: { institutionId: 1 },
    include: { role: true }
  })
  console.log(users.map(u => ({ email: u.email, role: u.role?.roleName, status: u.status })))
}
run().finally(() => prisma.$disconnect())
