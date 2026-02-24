import { Module, OnModuleInit } from '@nestjs/common'
import { ConfigService } from '@nestjs/config'
import { PrismaModule } from '../prisma/prisma.module'
import { AiController } from './ai.controller'
import { AiService } from './ai.service'
import { ContextService } from './context.service'
import { ClaudeProvider } from './providers/claude.provider'
import { GeminiProvider } from './providers/gemini.provider'
import { KramProvider } from './providers/kram.provider'
import { OpenAIProvider } from './providers/openai.provider'
import { SarvamProvider } from './providers/sarvam.provider'
import { AssignmentGeneratorTool } from './tools/custom/assignment-generator.tool'
import { TopicHelpTool } from './tools/custom/topic-help.tool'
import { DynamicQueryExecutor } from './tools/dynamic-query-executor'
import { DynamicToolGenerator } from './tools/dynamic-tool-generator'
import { ToolRegistry } from './tools/tool-registry'

@Module({
    imports: [PrismaModule],
    controllers: [AiController],
    providers: [
        AiService,
        ContextService,
        // AI Providers
        GeminiProvider,
        OpenAIProvider,
        ClaudeProvider,
        KramProvider,
        SarvamProvider,
        // Tool Infrastructure
        DynamicToolGenerator,
        DynamicQueryExecutor,
        ToolRegistry,
        // Custom Tools
        AssignmentGeneratorTool,
        TopicHelpTool,
    ],
    exports: [AiService, SarvamProvider],
})
export class AiModule implements OnModuleInit {
    constructor(
        private readonly toolRegistry: ToolRegistry,
        private readonly assignmentGeneratorTool: AssignmentGeneratorTool,
        private readonly topicHelpTool: TopicHelpTool,
        private readonly geminiProvider: GeminiProvider,
        private readonly openAiProvider: OpenAIProvider,
        private readonly claudeProvider: ClaudeProvider,
        private readonly sarvamProvider: SarvamProvider,
        private readonly configService: ConfigService,
    ) { }

    onModuleInit() {
        // Set AI provider for custom generative tools
        const providerName = this.configService.get<string>('AI_PROVIDER', 'gemini').toLowerCase()
        const providers: Record<string, any> = {
            gemini: this.geminiProvider,
            openai: this.openAiProvider,
            claude: this.claudeProvider,
            sarvam: this.sarvamProvider,
        }
        const activeProvider = providers[providerName] || this.geminiProvider
        this.assignmentGeneratorTool.setProvider(activeProvider)
        this.topicHelpTool.setProvider(activeProvider)

        // Register custom tools
        this.toolRegistry.registerCustomTool(this.assignmentGeneratorTool)
        this.toolRegistry.registerCustomTool(this.topicHelpTool)
    }
}
