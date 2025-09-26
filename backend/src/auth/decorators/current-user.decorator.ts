import { createParamDecorator, ExecutionContext } from '@nestjs/common'
import { UserWithRelations } from '../../types/auth.types'

export const CurrentUser = createParamDecorator(
  (data: unknown, ctx: ExecutionContext): UserWithRelations => {
    const request = ctx.switchToHttp().getRequest()
    return request.user
  }
)
