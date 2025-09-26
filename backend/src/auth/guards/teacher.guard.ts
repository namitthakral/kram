import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
} from '@nestjs/common'
import { User } from '../../types'

@Injectable()
export class TeacherGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest()
    const user: User = request.user

    if (!user) {
      throw new ForbiddenException('Authentication required')
    }

    if (!user.teacher) {
      throw new ForbiddenException('Teacher access required')
    }

    return true
  }
}
