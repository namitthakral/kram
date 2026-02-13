import { ConflictException, Injectable } from '@nestjs/common'
import { PrismaService } from '../prisma/prisma.service'
import { generateInstitutionCode } from '../utils/kramid.util'
import { CreateInstitutionDto } from './dto/institution.dto'

@Injectable()
export class InstitutionsService {
  constructor(private prisma: PrismaService) {}

  /**
   * Create a new institution
   * If code is not provided, it will be auto-generated from the institution name
   */
  async create(createInstitutionDto: CreateInstitutionDto) {
    // Get existing codes to ensure uniqueness
    const existingInstitutions = await this.prisma.institution.findMany({
      select: { code: true },
    })
    const existingCodes = existingInstitutions
      .map(i => i.code)
      .filter((code): code is string => code !== null)

    let code: string

    if (createInstitutionDto.code) {
      // User provided a code - validate it's unique
      const upperCode = createInstitutionDto.code.toUpperCase()

      if (existingCodes.includes(upperCode)) {
        throw new ConflictException(
          `Institution code "${upperCode}" is already in use. Please choose a different code.`
        )
      }
      code = upperCode
    } else {
      // Auto-generate code from institution name
      code = generateInstitutionCode(createInstitutionDto.name, existingCodes)
    }

    // Create the institution
    const institution = await this.prisma.institution.create({
      data: {
        name: createInstitutionDto.name,
        type: createInstitutionDto.type,
        code,
        address: createInstitutionDto.address,
        city: createInstitutionDto.city,
        state: createInstitutionDto.state,
        country: createInstitutionDto.country,
        postalCode: createInstitutionDto.postalCode,
        phone: createInstitutionDto.phone,
        email: createInstitutionDto.email,
        website: createInstitutionDto.website,
        establishedYear: createInstitutionDto.establishedYear,
        accreditation: createInstitutionDto.accreditation,
      },
    })

    // Also create default ID config for this institution
    await this.prisma.institutionIdConfig.create({
      data: {
        institutionId: institution.id,
      },
    })

    return {
      success: true,
      message: 'Institution created successfully',
      data: institution,
    }
  }

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
