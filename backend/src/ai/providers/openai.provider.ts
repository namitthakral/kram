import { Injectable, Logger } from '@nestjs/common'
import OpenAI from 'openai'
import { AiProvider } from '../interfaces/ai-provider.interface'

@Injectable()
export class OpenAIProvider implements AiProvider {
    private readonly logger = new Logger(OpenAIProvider.name)
    private openai: OpenAI

    constructor() {
        const apiKey = process.env.OPENAI_API_KEY
        if (!apiKey) {
            this.logger.warn('OPENAI_API_KEY is not set. OpenAI provider will not work.')
        } else {
            this.openai = new OpenAI({
                apiKey: apiKey,
            })
        }
    }

    async generateResponse(prompt: string): Promise<string> {
        if (!this.openai) {
            throw new Error('OpenAI API Key is missing. Please set OPENAI_API_KEY in .env')
        }
        try {
            const completion = await this.openai.chat.completions.create({
                messages: [{ role: 'user', content: prompt }],
                model: 'gpt-4o-mini',
            })
            return completion.choices[0].message.content || 'No response generated.'
        } catch (error) {
            this.logger.error('Error generating content with OpenAI', error)
            throw error
        }
    }
}
