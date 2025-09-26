import {
  Injectable,
  UnauthorizedException,
  ConflictException,
} from '@nestjs/common'
import { JwtService } from '@nestjs/jwt'
import { ConfigService } from '@nestjs/config'
import { PrismaService } from '../prisma/prisma.service'
import { LoginDto, CreateUserDto } from './dto/auth.dto'
import { UserWithRelations } from '../types/auth.types'
import * as bcrypt from 'bcryptjs'

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private configService: ConfigService
  ) {}

  async validateUser(
    email: string,
    password: string
  ): Promise<UserWithRelations | null> {
    const user = await this.prisma.user.findUnique({
      where: { email },
      include: {
        role: true,
        student: true,
        teacher: true,
        parent: true,
      },
    })

    if (!user) {
      return null
    }

    const isPasswordValid = await bcrypt.compare(password, user.passwordHash)
    if (!isPasswordValid) {
      return null
    }

    return user
  }

  async login(loginDto: LoginDto) {
    const user = await this.validateUser(loginDto.email, loginDto.password)

    if (!user) {
      throw new UnauthorizedException('Invalid credentials')
    }

    if (user.status !== 'ACTIVE') {
      throw new UnauthorizedException('Account is not active')
    }

    const payload = {
      userId: user.id,
      email: user.email,
      roleId: user.roleId,
    }

    const accessToken = this.jwtService.sign(payload)
    const refreshToken = this.jwtService.sign(payload, {
      secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
      expiresIn: '7d',
    })

    // Update last login
    await this.prisma.user.update({
      where: { id: user.id },
      data: { lastLogin: new Date() },
    })

    return {
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        student: user.student,
        teacher: user.teacher,
        parent: user.parent,
        status: user.status,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      },
      accessToken,
      refreshToken,
    }
  }

  async register(createUserDto: CreateUserDto) {
    // Check if user already exists
    const existingUser = await this.prisma.user.findUnique({
      where: { email: createUserDto.email },
    })

    if (existingUser) {
      throw new ConflictException('User with this email already exists')
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(createUserDto.password, 12)

    // Create user
    const user = await this.prisma.user.create({
      data: {
        name: createUserDto.name,
        email: createUserDto.email,
        phone: createUserDto.phone,
        passwordHash: hashedPassword,
        roleId: createUserDto.roleId,
      },
      include: {
        role: true,
      },
    })

    return {
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: user.role,
      status: user.status,
      createdAt: user.createdAt,
    }
  }

  async refreshToken(userId: number) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        role: true,
        student: true,
        teacher: true,
        parent: true,
      },
    })

    if (!user || user.status !== 'ACTIVE') {
      throw new UnauthorizedException('User not found or inactive')
    }

    const payload = {
      userId: user.id,
      email: user.email,
      roleId: user.roleId,
    }

    const accessToken = this.jwtService.sign(payload)

    return {
      accessToken,
    }
  }
}
