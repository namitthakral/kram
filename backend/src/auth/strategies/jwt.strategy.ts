import { Injectable, UnauthorizedException } from '@nestjs/common'
import { PassportStrategy } from '@nestjs/passport'
import { ExtractJwt, Strategy } from 'passport-jwt'
import { ConfigService } from '@nestjs/config'
import { PrismaService } from '../../prisma/prisma.service'
import { UserWithRelations, JWTPayload } from '../../types/auth.types'

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    private configService: ConfigService,
    private prisma: PrismaService
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get<string>('JWT_SECRET'),
    })
  }

  async validate(payload: JWTPayload): Promise<UserWithRelations> {
    const user = await this.prisma.user.findUnique({
      where: { id: payload.userId },
      include: {
        role: true,
        student: true,
        teacher: true,
        parent: true,
        staff: true,
      },
    })

    if (!user) {
      throw new UnauthorizedException('User not found')
    }

    if (user.status !== 'ACTIVE') {
      throw new UnauthorizedException('Account is not active')
    }

    return user
  }
}
