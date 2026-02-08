import { GoogleGenerativeAI, SchemaType } from '@google/generative-ai'
import { Injectable, Logger } from '@nestjs/common'
import {
    AiMessage,
    AiProvider,
    AiResponse,
    AiToolDefinition,
} from '../interfaces/ai-provider.interface'

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
        const result = await this.model.generateContent(prompt)
        const response = await result.response
        return response.text()
    }

    async chat(
        messages: AiMessage[],
        tools?: AiToolDefinition[],
        options?: { temperature?: number; maxTokens?: number },
    ): Promise<AiResponse> {
        if (!this.genAI) {
            throw new Error('Gemini API Key is missing. Please set GEMINI_API_KEY in .env')
        }

        // Separate system instruction from conversation messages
        const systemMessage = messages.find(m => m.role === 'system')
        const conversationMessages = messages.filter(m => m.role !== 'system')

        // Build Gemini tools from our tool definitions
        const geminiTools = tools?.length
            ? [{
                functionDeclarations: tools.map(t => ({
                    name: t.name,
                    description: t.description,
                    parameters: this.convertToGeminiSchema(t.parameters),
                })),
            }]
            : undefined

        // Create model with system instruction and tools
        const model = this.genAI.getGenerativeModel({
            model: 'gemini-2.5-flash-lite',
            systemInstruction: systemMessage?.content,
            tools: geminiTools,
            generationConfig: {
                temperature: options?.temperature ?? 0.3,
                maxOutputTokens: options?.maxTokens ?? 1024,
            },
        })

        // Convert messages to Gemini format
        const geminiHistory = this.convertToGeminiHistory(
            conversationMessages.slice(0, -1),
        )
        const lastMessage = conversationMessages[conversationMessages.length - 1]

        const chat = model.startChat({ history: geminiHistory })
        const result = await chat.sendMessage(lastMessage.content)
        const response = result.response

        // Extract tool calls if any
        const toolCalls = []
        const candidate = response.candidates?.[0]

        if (candidate?.content?.parts) {
            for (const part of candidate.content.parts) {
                if (part.functionCall) {
                    toolCalls.push({
                        id: `gemini_${Date.now()}_${part.functionCall.name}`,
                        name: part.functionCall.name,
                        arguments: (part.functionCall.args as Record<string, any>) || {},
                    })
                }
            }
        }

        let textContent: string | null = null
        try {
            textContent = response.text() || null
        } catch {
            // response.text() throws if the response only contains function calls
        }

        if (response.usageMetadata) {
            this.logger.log(`Token usage: ${JSON.stringify(response.usageMetadata)}`)
        }

        return {
            content: textContent,
            toolCalls,
            finishReason: toolCalls.length > 0 ? 'tool_calls' : 'stop',
        }
    }

    private convertToGeminiHistory(messages: AiMessage[]): any[] {
        const history: any[] = []

        for (const msg of messages) {
            if (msg.role === 'user') {
                history.push({ role: 'user', parts: [{ text: msg.content }] })
            } else if (msg.role === 'assistant') {
                history.push({ role: 'model', parts: [{ text: msg.content }] })
            } else if (msg.role === 'tool') {
                history.push({
                    role: 'function',
                    parts: [{
                        functionResponse: {
                            name: msg.name || 'unknown',
                            response: { result: msg.content },
                        },
                    }],
                })
            }
        }

        return history
    }

    private convertToGeminiSchema(params: Record<string, any>): any {
        if (!params || !params.properties) {
            return { type: SchemaType.OBJECT, properties: {} }
        }

        const convertType = (prop: any): any => {
            const typeMap: Record<string, SchemaType> = {
                string: SchemaType.STRING,
                number: SchemaType.NUMBER,
                integer: SchemaType.INTEGER,
                boolean: SchemaType.BOOLEAN,
                array: SchemaType.ARRAY,
                object: SchemaType.OBJECT,
            }

            const result: any = {
                type: typeMap[prop.type] || SchemaType.STRING,
                description: prop.description,
            }

            if (prop.enum) result.enum = prop.enum
            if (prop.items) result.items = convertType(prop.items)
            if (prop.properties) {
                result.properties = {}
                for (const [key, val] of Object.entries(prop.properties)) {
                    result.properties[key] = convertType(val)
                }
            }

            return result
        }

        const properties: Record<string, any> = {}
        for (const [key, val] of Object.entries(params.properties)) {
            properties[key] = convertType(val)
        }

        return {
            type: SchemaType.OBJECT,
            properties,
            required: params.required || [],
        }
    }
}
