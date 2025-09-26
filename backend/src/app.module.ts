import { Module } from '@nestjs/common'
import { ConfigModule } from '@nestjs/config'
import { ThrottlerModule } from '@nestjs/throttler'
import { PrismaModule } from './prisma/prisma.module'
import { AuthModule } from './auth/auth.module'
import { StudentsModule } from './students/students.module'
import { TeachersModule } from './teachers/teachers.module'
import { CoursesModule } from './courses/courses.module'
import { InstitutionsModule } from './institutions/institutions.module'

@Module({
  imports: [
    // Configuration
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),

    // Rate limiting
    ThrottlerModule.forRoot([
      {
        ttl: 60000, // 1 minute
        limit: 100, // 100 requests per minute
      },
    ]),

    // Database
    PrismaModule,

    // Feature modules
    AuthModule,
    StudentsModule,
    TeachersModule,
    CoursesModule,
    InstitutionsModule,
  ],
})
export class AppModule {}
