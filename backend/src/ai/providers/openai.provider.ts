import { Injectable, Logger } from '@nestjs/common'
import OpenAI from 'openai'
import {
    AiMessage,
    AiProvider,
    AiResponse,
    AiToolDefinition,
} from '../interfaces/ai-provider.interface'

@Injectable()
export class OpenAIProvider implements AiProvider {
    private readonly logger = new Logger(OpenAIProvider.name)
    private openai: OpenAI

    constructor() {
        const apiKey = process.env.OPENAI_API_KEY
        if (!apiKey) {
            this.logger.warn('OPENAI_API_KEY is not set. OpenAI provider will not work.')
        } else {
            this.openai = new OpenAI({ apiKey })
        }
    }

    async generateResponse(prompt: string): Promise<string> {
        if (!this.openai) {
            throw new Error('OpenAI API Key is missing. Please set OPENAI_API_KEY in .env')
        }
        const completion = await this.openai.chat.completions.create({
            messages: [{ role: 'user', content: prompt }],
            model: 'gpt-4o-mini',
        })
        return completion.choices[0].message.content || 'No response generated.'
    }

    async chat(
        messages: AiMessage[],
        tools?: AiToolDefinition[],
        options?: { temperature?: number; maxTokens?: number },
    ): Promise<AiResponse> {
        if (!this.openai) {
            throw new Error('OpenAI API Key is missing. Please set OPENAI_API_KEY in .env')
        }

        // Convert to OpenAI message format
        const openaiMessages: OpenAI.Chat.Completions.ChatCompletionMessageParam[] =
            messages.map(m => {
                if (m.role === 'tool') {
                    return {
                        role: 'tool' as const,
                        content: m.content,
                        tool_call_id: m.toolCallId || '',
                    }
                }
                if (m.role === 'system') {
                    return { role: 'system' as const, content: m.content }
                }
                if (m.role === 'assistant') {
                    return { role: 'assistant' as const, content: m.content }
                }
                return { role: 'user' as const, content: m.content }
            })

        // Convert to OpenAI tool format
        const openaiTools: OpenAI.Chat.Completions.ChatCompletionTool[] | undefined =
            tools?.length
                ? tools.map(t => ({
                    type: 'function' as const,
                    function: {
                        name: t.name,
                        description: t.description,
                        parameters: t.parameters,
                    },
                }))
                : undefined

        const completion = await this.openai.chat.completions.create({
            model: 'gpt-4o-mini',
            messages: openaiMessages,
            tools: openaiTools,
            temperature: options?.temperature ?? 0.3,
            max_tokens: options?.maxTokens ?? 1024,
        })

        const choice = completion.choices[0]
        const toolCalls = (choice.message.tool_calls || [])
            .filter((tc): tc is OpenAI.Chat.Completions.ChatCompletionMessageFunctionToolCall => tc.type === 'function')
            .map(tc => ({
                id: tc.id,
                name: tc.function.name,
                arguments: JSON.parse(tc.function.arguments),
            }))

        return {
            content: choice.message.content,
            toolCalls,
            finishReason: choice.finish_reason === 'tool_calls' ? 'tool_calls' : 'stop',
        }
    }
}
