import { Injectable, Logger, OnModuleInit } from '@nestjs/common'
import { AiProvider } from './interfaces/ai-provider.interface'
import { ClaudeProvider } from './providers/claude.provider'
import { GeminiProvider } from './providers/gemini.provider'
import { OpenAIProvider } from './providers/openai.provider'
import { ConfigService } from '@nestjs/config'

@Injectable()
export class AiService implements OnModuleInit {
    private readonly logger = new Logger(AiService.name)
    private providers: Record<string, AiProvider> = {}

    constructor(
        private readonly geminiProvider: GeminiProvider,
        private readonly openAiProvider: OpenAIProvider,
        private readonly claudeProvider: ClaudeProvider,
        private readonly configService: ConfigService
    ) { }

    onModuleInit() {
        this.providers = {
            gemini: this.geminiProvider,
            openai: this.openAiProvider,
            claude: this.claudeProvider,
        }

        const defaultProvider = this.configService.get<string>('AI_PROVIDER', 'gemini')
        this.logger.log(`AI Service initialized. Default provider: ${defaultProvider}`)
    }

    async chat(prompt: string, context: string = ''): Promise<{ response: string }> {
        const activeProviderName = this.configService.get<string>('AI_PROVIDER', 'gemini').toLowerCase()
        const provider = this.providers[activeProviderName]

        if (!provider) {
            throw new Error(`AI Provider '${activeProviderName}' not supported. Available: ${Object.keys(this.providers).join(', ')}`)
        }

        this.logger.debug(`Sending prompt to AI (${activeProviderName}). Context length: ${context.length}`)

        const fullPrompt = context ? `${context}\n\nUser Question: ${prompt}` : prompt
        const response = await provider.generateResponse(fullPrompt)

        return { response }
    }
}
