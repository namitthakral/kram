import { Injectable, Logger } from '@nestjs/common'
import OpenAI from 'openai'
import {
    AiMessage,
    AiProvider,
    AiResponse,
    AiToolDefinition,
} from '../interfaces/ai-provider.interface'

@Injectable()
export class SarvamProvider implements AiProvider {
    private readonly logger = new Logger(SarvamProvider.name)
    private openai: OpenAI

    constructor() {
        const apiKey = process.env.SARVAM_API_KEY
        if (!apiKey) {
            this.logger.warn('SARVAM_API_KEY is not set. Sarvam provider will not work.')
        } else {
            this.openai = new OpenAI({
                apiKey,
                baseURL: 'https://api.sarvam.ai/v1',
            })
            this.logger.log('SarvamProvider initialized with base URL: https://api.sarvam.ai/v1')
        }
    }

    async generateResponse(prompt: string): Promise<string> {
        if (!this.openai) {
            throw new Error('Sarvam API Key is missing. Please set SARVAM_API_KEY in .env')
        }
        try {
            const completion = await this.openai.chat.completions.create({
                messages: [{ role: 'user', content: prompt }],
                model: 'sarvam-m', // Defaulting to a likely available model, can be configured
            })
            return completion.choices[0].message.content || 'No response generated.'
        } catch (error) {
            this.logger.error(`Error generating response from Sarvam AI: ${error.message}`)
            throw error
        }
    }

    async chat(
        messages: AiMessage[],
        tools?: AiToolDefinition[],
        options?: { temperature?: number; maxTokens?: number },
    ): Promise<AiResponse> {
        if (!this.openai) {
            throw new Error('Sarvam API Key is missing. Please set SARVAM_API_KEY in .env')
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
                    return { role: 'assistant' as const, content: m.content, tool_calls: m.toolCallId ? undefined : undefined } // tool_calls handled by OpenAI lib usually
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

        try {
            // Attempt to use tools
            const completion = await this.openai.chat.completions.create({
                model: 'sarvam-2.0', // Updated to a model that likely supports tools, or fallback to sarvam-m
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
        } catch (error) {
            // Fallback: If tools are not supported (400 error or specific message), try without tools
            if (error.message?.includes('tools') || error.status === 400) {
                this.logger.warn(`Sarvam AI tool call failed, retrying without tools. Error: ${error.message}`)

                // Append a system note about tool unavailability if possible, or just retry
                const fallbackMessages = [...openaiMessages]
                // Optionally add a user message saying "Tools are unavailable, please provide a general answer."

                const completion = await this.openai.chat.completions.create({
                    model: 'sarvam-2.0',
                    messages: fallbackMessages,
                    // No tools
                    temperature: options?.temperature ?? 0.3,
                    max_tokens: options?.maxTokens ?? 1024,
                })

                return {
                    content: completion.choices[0].message.content,
                    toolCalls: [],
                    finishReason: 'stop',
                }
            }

            this.logger.error(`Error in chat with Sarvam AI: ${error.message}`)
            throw error
        }
    }
}
