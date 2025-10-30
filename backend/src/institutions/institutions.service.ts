import { Injectable } from '@nestjs/common'
import { PrismaService } from '../prisma/prisma.service'

@Injectable()
export class InstitutionsService {
  constructor(private prisma: PrismaService) {}

  async getPublicInstitutions() {
    return this.prisma.institution.findMany({
      where: {
        status: 'ACTIVE',
      },
      select: {
        id: true,
        code: true,
        name: true,
        type: true,
        city: true,
        state: true,
        country: true,
      },
      orderBy: {
        name: 'asc',
      },
    })
  }

  async findByCode(code: string) {
    return this.prisma.institution.findUnique({
      where: { code },
      select: {
        id: true,
        code: true,
        name: true,
      },
    })
  }
}
