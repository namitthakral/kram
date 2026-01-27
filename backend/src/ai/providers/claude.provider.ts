import Anthropic from '@anthropic-ai/sdk'
import { Injectable, Logger } from '@nestjs/common'
import { AiProvider } from '../interfaces/ai-provider.interface'

@Injectable()
export class ClaudeProvider implements AiProvider {
    private readonly logger = new Logger(ClaudeProvider.name)
    private anthropic: Anthropic | undefined // Changed type to allow undefined

    constructor() {
        const apiKey = process.env.ANTHROPIC_API_KEY
        if (!apiKey) {
            this.logger.warn('ANTHROPIC_API_KEY is not set. Claude provider will not work.')
        } else {
            this.anthropic = new Anthropic({
                apiKey: apiKey,
            })
        }
    }

    async generateResponse(prompt: string): Promise<string> {
        if (!this.anthropic) {
            throw new Error('Anthropic API Key is missing. Please set ANTHROPIC_API_KEY in .env')
        }
        try {
            const message = await this.anthropic.messages.create({
                max_tokens: 1024,
                messages: [{ role: 'user', content: prompt }],
                model: 'claude-3-haiku-20240307',
            })

            if (message.content && message.content.length > 0 && message.content[0].type === 'text') {
                return message.content[0].text
            }

            return 'No response generated.'
        } catch (error) {
            this.logger.error('Error generating content with Claude', error)
            throw error
        }
    }
}
