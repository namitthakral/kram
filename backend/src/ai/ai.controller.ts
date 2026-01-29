import { Body, Controller, Post, UseGuards, ValidationPipe } from '@nestjs/common'
import { CurrentUser } from '../auth/decorators/current-user.decorator'
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard'
import { UserWithRelations } from '../types/auth.types'
import { AiService } from './ai.service'
import { ChatDto } from './dto/chat.dto'

@Controller('ai')
@UseGuards(JwtAuthGuard)
export class AiController {
    constructor(private readonly aiService: AiService) {}

    @Post('chat')
    async chat(
        @CurrentUser() user: UserWithRelations,
        @Body(new ValidationPipe({ transform: true })) chatDto: ChatDto,
    ) {
        return this.aiService.chat(user, chatDto.message, chatDto.conversationHistory)
    }
}
