import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
} from '@nestjs/common'
import { Reflector } from '@nestjs/core'
import { UserWithRelations } from '../../types/auth.types'

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<string[]>('roles', [
      context.getHandler(),
      context.getClass(),
    ])

    if (!requiredRoles) {
      return true
    }

    const request = context.switchToHttp().getRequest()
    const user: UserWithRelations = request.user

    if (!user) {
      throw new ForbiddenException('Authentication required')
    }

    const userRoleLower = user.role?.roleName?.toLowerCase()
    const hasRole =
      userRoleLower &&
      requiredRoles.some(
        (role) => userRoleLower === role.toLowerCase(),
      )

    if (!hasRole) {
      throw new ForbiddenException('Insufficient permissions')
    }

    return true
  }
}
