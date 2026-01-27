import { Module } from '@nestjs/common'
import { AiController } from './ai.controller'
import { AiService } from './ai.service'
import { ContextService } from './context.service'
import { PrismaModule } from '../prisma/prisma.module'
import { ClaudeProvider } from './providers/claude.provider'
import { GeminiProvider } from './providers/gemini.provider'
import { OpenAIProvider } from './providers/openai.provider'

@Module({
    imports: [PrismaModule],
    controllers: [AiController],
    providers: [
        AiService,
        ContextService,
        GeminiProvider,
        OpenAIProvider,
        ClaudeProvider,
    ],
    exports: [AiService],
})
export class AiModule { }
