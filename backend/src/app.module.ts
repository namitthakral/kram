import { Module } from '@nestjs/common'
import { ConfigModule } from '@nestjs/config'
import { EventEmitterModule } from '@nestjs/event-emitter'
import { ScheduleModule } from '@nestjs/schedule'
import { ServeStaticModule } from '@nestjs/serve-static'
import { ThrottlerModule } from '@nestjs/throttler'
import { join } from 'path'
import { AdminModule } from './admin/admin.module'
import { AuthModule } from './auth/auth.module'
import { CoursesModule } from './courses/courses.module'
import { IdGenerationModule } from './id-generation/id-generation.module'
import { InstitutionsModule } from './institutions/institutions.module'
import { PrismaModule } from './prisma/prisma.module'
import { QuestionPaperModule } from './question-paper/question-paper.module'
import { StudentsModule } from './students/students.module'
import { TeachersModule } from './teachers/teachers.module'
import { TimetableModule } from './timetable/timetable.module'
import { UsersModule } from './users/users.module'

@Module({
  imports: [
    // Configuration
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),

    // Serve Flutter web app at root
    ServeStaticModule.forRoot({
      rootPath: join(__dirname, '..', '..', 'public', 'dashboard'),
      exclude: ['/api/(.*)', '/health'],
      serveStaticOptions: {
        index: ['index.html'],
        fallthrough: true, // Allow falling through to other controllers (like API) if file not found
        setHeaders: (res) => {
          res.setHeader('Cross-Origin-Opener-Policy', 'same-origin')
          res.setHeader('Cross-Origin-Embedder-Policy', 'require-corp')
        },
      },
    }),

    // Event-driven architecture
    EventEmitterModule.forRoot({
      wildcard: false,
      delimiter: '.',
      newListener: false,
      removeListener: false,
      maxListeners: 10,
      verboseMemoryLeak: false,
      ignoreErrors: false,
    }),

    // Scheduled jobs
    ScheduleModule.forRoot(),

    // Rate limiting
    ThrottlerModule.forRoot([
      {
        ttl: 60000, // 1 minute
        limit: 100, // 100 requests per minute
      },
    ]),

    // Database
    PrismaModule,

    // ID Generation (Global)
    IdGenerationModule,

    // Feature modules
    AuthModule,
    AdminModule,
    UsersModule,
    StudentsModule,
    TeachersModule,
    CoursesModule,
    InstitutionsModule,
    TimetableModule,
    QuestionPaperModule,
  ],
})
export class AppModule {}
