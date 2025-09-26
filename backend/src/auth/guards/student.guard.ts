import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
} from '@nestjs/common'
import { UserWithRelations } from '../../types/auth.types'

@Injectable()
export class StudentGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest()
    const user: UserWithRelations = request.user

    if (!user) {
      throw new ForbiddenException('Authentication required')
    }

    if (!user.student) {
      throw new ForbiddenException('Student access required')
    }

    return true
  }
}
