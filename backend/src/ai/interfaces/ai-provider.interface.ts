export interface AiMessage {
    role: 'system' | 'user' | 'assistant' | 'tool'
    content: string
    toolCallId?: string
    name?: string
}

export interface AiToolDefinition {
    name: string
    description: string
    parameters: Record<string, any>
}

export interface AiToolCall {
    id: string
    name: string
    arguments: Record<string, any>
}

export interface AiResponse {
    content: string | null
    toolCalls: AiToolCall[]
    finishReason: 'stop' | 'tool_calls' | 'error'
}

export interface AiProvider {
    generateResponse(prompt: string): Promise<string>

    chat(
        messages: AiMessage[],
        tools?: AiToolDefinition[],
        options?: { temperature?: number; maxTokens?: number }
    ): Promise<AiResponse>
}
