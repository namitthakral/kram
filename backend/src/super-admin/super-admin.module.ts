import { Module } from '@nestjs/common'
import { SuperAdminController } from './super-admin.controller'
import { SuperAdminService } from './super-admin.service'
import { PrismaModule } from '../prisma/prisma.module'

/**
 * Super Admin Module
 * Provides system-wide analytics and management functionality for super administrators
 * 
 * Features:
 * - System-wide statistics and metrics
 * - Institution overview and management
 * - User growth analytics
 * - Recent activity monitoring
 * - Performance-optimized queries using database views
 */
@Module({
  imports: [PrismaModule],
  controllers: [SuperAdminController],
  providers: [SuperAdminService],
  exports: [SuperAdminService],
})
export class SuperAdminModule {}