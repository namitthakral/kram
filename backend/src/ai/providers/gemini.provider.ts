import { GoogleGenerativeAI } from '@google/generative-ai'
import { Injectable, Logger } from '@nestjs/common'
import { ConfigService } from '@nestjs/config'
import { AiProvider } from '../interfaces/ai-provider.interface'

@Injectable()
export class GeminiProvider implements AiProvider {
    private readonly logger = new Logger(GeminiProvider.name)
    private genAI: GoogleGenerativeAI
    private model: any

    constructor() {
        const apiKey = process.env.GEMINI_API_KEY
        if (!apiKey) {
            this.logger.warn('GEMINI_API_KEY is not set. Gemini provider will not work.')
        } else {
            this.genAI = new GoogleGenerativeAI(apiKey)
            this.model = this.genAI.getGenerativeModel({ model: 'gemini-2.5-flash-lite' })
        }
    }

    async generateResponse(prompt: string): Promise<string> {
        if (!this.model) {
            throw new Error('Gemini API Key is missing. Please set GEMINI_API_KEY in .env')
        }
        try {
            const result = await this.model.generateContent(prompt)
            const response = await result.response
            return response.text()
        } catch (error) {
            this.logger.error('Error generating content with Gemini', error)
            throw error
        }
    }
}
