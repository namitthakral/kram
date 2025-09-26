import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
} from '@nestjs/common'
import { User } from '../../types'

@Injectable()
export class ParentGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest()
    const user: User = request.user

    if (!user) {
      throw new ForbiddenException('Authentication required')
    }

    if (!user.parent) {
      throw new ForbiddenException('Parent access required')
    }

    return true
  }
}
