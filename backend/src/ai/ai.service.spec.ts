import { ConfigService } from '@nestjs/config'
import { Test, TestingModule } from '@nestjs/testing'
import { AiService } from './ai.service'
import { ContextService } from './context.service'
import { ToolRegistry } from './tools/tool-registry'
import { GeminiProvider } from './providers/gemini.provider'
import { OpenAIProvider } from './providers/openai.provider'
import { ClaudeProvider } from './providers/claude.provider'

describe('AiService', () => {
    let service: AiService
    let toolRegistry: ToolRegistry
    let geminiProvider: GeminiProvider

    const mockUser: any = {
        id: 1,
        firstName: 'Test',
        lastName: 'User',
        role: { roleName: 'teacher' },
        teacher: { id: 1, institutionId: 1 },
    }

    beforeEach(async () => {
        const module: TestingModule = await Test.createTestingModule({
            providers: [
                AiService,
                {
                    provide: ContextService,
                    useValue: {
                        getUserContext: jest.fn().mockResolvedValue('User: Test User | Role: teacher'),
                    },
                },
                {
                    provide: ToolRegistry,
                    useValue: {
                        getToolDefinitions: jest.fn().mockReturnValue([
                            { name: 'query_student', description: 'Query students', parameters: {} },
                        ]),
                        executeTool: jest.fn().mockResolvedValue(JSON.stringify([{ name: 'Alice' }])),
                    },
                },
                {
                    provide: GeminiProvider,
                    useValue: {
                        generateResponse: jest.fn(),
                        chat: jest.fn(),
                    },
                },
                { provide: OpenAIProvider, useValue: { chat: jest.fn() } },
                { provide: ClaudeProvider, useValue: { chat: jest.fn() } },
                {
                    provide: ConfigService,
                    useValue: {
                        get: jest.fn().mockReturnValue('gemini'),
                    },
                },
            ],
        }).compile()

        service = module.get<AiService>(AiService)
        toolRegistry = module.get<ToolRegistry>(ToolRegistry)
        geminiProvider = module.get<GeminiProvider>(GeminiProvider)

        service.onModuleInit()
    })

    it('should be defined', () => {
        expect(service).toBeDefined()
    })

    it('should return direct response when no tools are called', async () => {
        ;(geminiProvider.chat as jest.Mock).mockResolvedValue({
            content: 'Hello there!',
            toolCalls: [],
            finishReason: 'stop',
        })

        const result = await service.chat(mockUser, 'Hi')

        expect(result.response).toBe('Hello there!')
        expect(toolRegistry.executeTool).not.toHaveBeenCalled()
    })

    it('should execute tool when AI requests it (tool-calling loop)', async () => {
        ;(geminiProvider.chat as jest.Mock)
            .mockResolvedValueOnce({
                content: null,
                toolCalls: [{ id: 'call_1', name: 'query_student', arguments: { limit: 5 } }],
                finishReason: 'tool_calls',
            })
            .mockResolvedValueOnce({
                content: 'Here are your top students: Alice.',
                toolCalls: [],
                finishReason: 'stop',
            })

        const result = await service.chat(mockUser, 'Show me my students')

        expect(toolRegistry.executeTool).toHaveBeenCalledWith(
            'query_student',
            { limit: 5 },
            mockUser,
        )
        expect(result.response).toBe('Here are your top students: Alice.')
    })

    it('should filter tools by user role', async () => {
        ;(geminiProvider.chat as jest.Mock).mockResolvedValue({
            content: 'Done',
            toolCalls: [],
            finishReason: 'stop',
        })

        await service.chat(mockUser, 'Hello')

        expect(toolRegistry.getToolDefinitions).toHaveBeenCalledWith('teacher')
    })

    it('should include conversation history in messages', async () => {
        ;(geminiProvider.chat as jest.Mock).mockResolvedValue({
            content: 'Response',
            toolCalls: [],
            finishReason: 'stop',
        })

        await service.chat(mockUser, 'Follow up', [
            { role: 'user', content: 'First message' },
            { role: 'assistant', content: 'First reply' },
        ])

        const chatCall = (geminiProvider.chat as jest.Mock).mock.calls[0]
        const messages = chatCall[0]

        // system + 2 history + 1 user = 4 messages
        expect(messages).toHaveLength(4)
        expect(messages[0].role).toBe('system')
        expect(messages[1].content).toBe('First message')
        expect(messages[2].content).toBe('First reply')
        expect(messages[3].content).toBe('Follow up')
    })

    it('should cap tool iterations to prevent runaway loops', async () => {
        let callCount = 0
        ;(geminiProvider.chat as jest.Mock).mockImplementation(() => {
            callCount++
            if (callCount > 3) {
                return Promise.resolve({
                    content: 'Final answer after max iterations.',
                    toolCalls: [],
                    finishReason: 'stop',
                })
            }
            return Promise.resolve({
                content: null,
                toolCalls: [{ id: `call_${callCount}`, name: 'query_student', arguments: {} }],
                finishReason: 'tool_calls',
            })
        })

        const result = await service.chat(mockUser, 'Infinite loop test')

        expect(result.response).toBe('Final answer after max iterations.')
        expect(geminiProvider.chat).toHaveBeenCalledTimes(4)
    })
})
