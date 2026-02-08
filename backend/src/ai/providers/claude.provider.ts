import Anthropic from '@anthropic-ai/sdk'
import { Injectable, Logger } from '@nestjs/common'
import {
    AiMessage,
    AiProvider,
    AiResponse,
    AiToolDefinition,
} from '../interfaces/ai-provider.interface'

@Injectable()
export class ClaudeProvider implements AiProvider {
    private readonly logger = new Logger(ClaudeProvider.name)
    private anthropic: Anthropic | undefined

    constructor() {
        const apiKey = process.env.ANTHROPIC_API_KEY
        if (!apiKey) {
            this.logger.warn('ANTHROPIC_API_KEY is not set. Claude provider will not work.')
        } else {
            this.anthropic = new Anthropic({ apiKey })
        }
    }

    async generateResponse(prompt: string): Promise<string> {
        if (!this.anthropic) {
            throw new Error('Anthropic API Key is missing. Please set ANTHROPIC_API_KEY in .env')
        }
        const message = await this.anthropic.messages.create({
            max_tokens: 1024,
            messages: [{ role: 'user', content: prompt }],
            model: 'claude-3-haiku-20240307',
        })

        if (message.content?.length > 0 && message.content[0].type === 'text') {
            return message.content[0].text
        }
        return 'No response generated.'
    }

    async chat(
        messages: AiMessage[],
        tools?: AiToolDefinition[],
        options?: { temperature?: number; maxTokens?: number },
    ): Promise<AiResponse> {
        if (!this.anthropic) {
            throw new Error('Anthropic API Key is missing. Please set ANTHROPIC_API_KEY in .env')
        }

        // Extract system message (Claude uses a separate system parameter)
        const systemMessage = messages.find(m => m.role === 'system')
        const conversationMessages = messages.filter(m => m.role !== 'system')

        // Convert to Claude message format
        const claudeMessages: Anthropic.MessageParam[] = conversationMessages.map(m => {
            if (m.role === 'tool') {
                return {
                    role: 'user' as const,
                    content: [{
                        type: 'tool_result' as const,
                        tool_use_id: m.toolCallId || '',
                        content: m.content,
                    }],
                }
            }
            if (m.role === 'assistant') {
                return { role: 'assistant' as const, content: m.content }
            }
            return { role: 'user' as const, content: m.content }
        })

        // Convert to Claude tool format
        const claudeTools: Anthropic.Tool[] | undefined = tools?.length
            ? tools.map(t => ({
                name: t.name,
                description: t.description,
                input_schema: t.parameters as Anthropic.Tool.InputSchema,
            }))
            : undefined

        const response = await this.anthropic.messages.create({
            model: 'claude-3-haiku-20240307',
            max_tokens: options?.maxTokens ?? 1024,
            system: systemMessage?.content,
            messages: claudeMessages,
            tools: claudeTools,
        })

        // Extract text content and tool calls
        let textContent: string | null = null
        const toolCalls = []

        for (const block of response.content) {
            if (block.type === 'text') {
                textContent = block.text
            } else if (block.type === 'tool_use') {
                toolCalls.push({
                    id: block.id,
                    name: block.name,
                    arguments: block.input as Record<string, any>,
                })
            }
        }

        return {
            content: textContent,
            toolCalls,
            finishReason: response.stop_reason === 'tool_use' ? 'tool_calls' : 'stop',
        }
    }
}
