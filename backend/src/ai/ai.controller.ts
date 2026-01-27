import { Body, Controller, Logger, Post, ValidationPipe } from '@nestjs/common'
import { IsNotEmpty, IsNumber, IsOptional, IsString } from 'class-validator'
import { AiService } from './ai.service'
import { ContextService } from './context.service'

class ChatDto {
    @IsString()
    @IsNotEmpty()
    prompt: string

    @IsNumber()
    @IsOptional()
    userId?: number
}

@Controller('ai')
export class AiController {
    private readonly logger = new Logger(AiController.name)

    constructor(
        private readonly aiService: AiService,
        private readonly contextService: ContextService
    ) { }

    @Post('chat')
    async chat(@Body(new ValidationPipe()) chatDto: ChatDto) {
        let context = ''
        if (chatDto.userId) {
            this.logger.debug(`Fetching context for user ${chatDto.userId}`)
            context = await this.contextService.getUserContext(chatDto.userId)
        }

        return this.aiService.chat(chatDto.prompt, context)
    }
}
