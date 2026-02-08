import { Injectable, Logger, OnModuleInit } from '@nestjs/common'
import { ConfigService } from '@nestjs/config'
import { UserWithRelations } from '../types/auth.types'
import { ContextService } from './context.service'
import { ConversationMessageDto } from './dto/chat.dto'
import { AiMessage, AiProvider } from './interfaces/ai-provider.interface'
import { buildSystemPrompt } from './prompts/system-prompts'
import { ClaudeProvider } from './providers/claude.provider'
import { GeminiProvider } from './providers/gemini.provider'
import { OpenAIProvider } from './providers/openai.provider'
import { ToolRegistry } from './tools/tool-registry'

import { KramProvider } from './providers/kram.provider'

@Injectable()
export class AiService implements OnModuleInit {
    private readonly logger = new Logger(AiService.name)
    private providers: Record<string, AiProvider> = {}
    private readonly MAX_TOOL_ITERATIONS = 3
    private readonly MAX_HISTORY_MESSAGES = 10

    constructor(
        private readonly contextService: ContextService,
        private readonly toolRegistry: ToolRegistry,
        private readonly geminiProvider: GeminiProvider,
        private readonly openAiProvider: OpenAIProvider,
        private readonly claudeProvider: ClaudeProvider,
        private readonly kramProvider: KramProvider,
        private readonly configService: ConfigService,
    ) { }

    onModuleInit() {
        this.providers = {
            gemini: this.geminiProvider,
            openai: this.openAiProvider,
            claude: this.claudeProvider,
            kram: this.kramProvider,
        }

        const defaultProvider = this.configService.get<string>('AI_PROVIDER', 'gemini')
        this.logger.log(`AI Service initialized. Default provider: ${defaultProvider}`)
    }

    async chat(
        user: UserWithRelations,
        message: string,
        history?: ConversationMessageDto[],
    ): Promise<{ response: string }> {
        const providerName = this.configService.get<string>('AI_PROVIDER', 'gemini').toLowerCase()
        const provider = this.providers[providerName]

        if (!provider) {
            throw new Error(`AI Provider '${providerName}' not supported.`)
        }

        const roleName = user.role.roleName.toLowerCase()

        // 1. Build compact, role-specific context
        const userContext = await this.contextService.getUserContext(user.id)
        const systemPrompt = buildSystemPrompt(roleName, userContext)

        // 2. Get role-filtered tool definitions
        const tools = this.toolRegistry.getToolDefinitions(roleName)
        this.logger.debug(`Tools available for ${roleName}: ${tools.map(t => t.name).join(', ')}`)

        // 3. Build message array
        const messages: AiMessage[] = [
            { role: 'system', content: systemPrompt },
        ]

        // Add trimmed conversation history
        if (history?.length) {
            const trimmed = history.slice(-this.MAX_HISTORY_MESSAGES)
            for (const h of trimmed) {
                messages.push({
                    role: h.role as 'user' | 'assistant',
                    content: h.content.substring(0, 500),
                })
            }
        }

        messages.push({ role: 'user', content: message })

        // 4. Tool-calling loop
        let iterations = 0
        while (iterations < this.MAX_TOOL_ITERATIONS) {
            const response = await provider.chat(messages, tools, {
                temperature: 0.3,
                maxTokens: 1024,
            })

            // If no tool calls, return the text response
            if (response.finishReason === 'stop' || response.toolCalls.length === 0) {
                return { response: response.content || 'I could not generate a response.' }
            }

            // Add assistant's response (with tool call intent) to message history
            messages.push({
                role: 'assistant',
                content: response.content || '',
            })

            // Execute each tool call and add results
            for (const toolCall of response.toolCalls) {
                this.logger.debug(`Executing tool: ${toolCall.name} (${JSON.stringify(toolCall.arguments)})`)

                const result = await this.toolRegistry.executeTool(
                    toolCall.name,
                    toolCall.arguments,
                    user,
                )

                this.logger.debug(`Tool ${toolCall.name} returned ${result.length} chars`)

                messages.push({
                    role: 'tool',
                    content: result,
                    toolCallId: toolCall.id,
                    name: toolCall.name,
                })
            }

            iterations++
        }

        // If we exhausted iterations, make one final call without tools
        this.logger.warn(`Max tool iterations (${this.MAX_TOOL_ITERATIONS}) reached`)
        const finalResponse = await provider.chat(messages, [], { temperature: 0.3 })
        return {
            response: finalResponse.content || 'I processed your request but could not formulate a response.',
        }
    }
}
