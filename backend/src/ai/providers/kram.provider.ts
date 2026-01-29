import { Injectable, Logger } from '@nestjs/common'
import { ConfigService } from '@nestjs/config'
import axios from 'axios'
import {
    AiMessage,
    AiProvider,
    AiResponse,
    AiToolDefinition,
} from '../interfaces/ai-provider.interface'

@Injectable()
export class KramProvider implements AiProvider {
    private readonly logger = new Logger(KramProvider.name)
    private readonly apiUrl: string

    constructor(private readonly configService: ConfigService) {
        // Default to the known IP of the AI Lab machine
        this.apiUrl = this.configService.get<string>('KRAM_API_URL', 'http://192.168.1.99:9001')
    }

    async generateResponse(prompt: string): Promise<string> {
        try {
            const response = await axios.post(`${this.apiUrl}/ai/chat`, {
                message: prompt,
                conversationHistory: [],
            })
            return response.data.response
        } catch (error) {
            this.logger.error(`Error generating response from Kram AI: ${error.message}`)
            throw error
        }
    }

    async chat(
        messages: AiMessage[],
        tools?: AiToolDefinition[],
        options?: { temperature?: number; maxTokens?: number },
    ): Promise<AiResponse> {
        try {
            // Extract the last user message
            const lastMessage = messages[messages.length - 1]
            if (lastMessage.role !== 'user') {
                throw new Error('Last message must be from user')
            }

            // Convert history (excluding last message)
            const history = messages.slice(0, -1).map(msg => ({
                role: msg.role,
                content: msg.content,
            }))

            this.logger.debug(`Sending chat request to Kram AI at ${this.apiUrl}`)

            const response = await axios.post(`${this.apiUrl}/ai/chat`, {
                message: lastMessage.content,
                conversationHistory: history,
            })

            const content = response.data.response

            // Note: Current Kram implementation might not support tool calls yet.
            // Returning 'stop' as finishReason for now.
            return {
                content: content,
                toolCalls: [],
                finishReason: 'stop',
            }
        } catch (error) {
            this.logger.error(`Error in chat with Kram AI: ${error.message}`)
            return {
                content: 'Error communicating with Kram AI service.',
                toolCalls: [],
                finishReason: 'error',
            }
        }
    }
}
