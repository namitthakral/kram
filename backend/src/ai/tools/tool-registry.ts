import { Injectable, Logger, OnModuleInit } from '@nestjs/common'
import { UserWithRelations } from '../../types/auth.types'
import { AiToolDefinition } from '../interfaces/ai-provider.interface'
import { BaseTool } from './base.tool'
import { DynamicQueryExecutor } from './dynamic-query-executor'
import { DynamicToolGenerator } from './dynamic-tool-generator'

@Injectable()
export class ToolRegistry implements OnModuleInit {
    private readonly logger = new Logger(ToolRegistry.name)
    private customTools: Map<string, BaseTool> = new Map()

    constructor(
        private readonly dynamicToolGenerator: DynamicToolGenerator,
        private readonly dynamicQueryExecutor: DynamicQueryExecutor,
    ) { }

    onModuleInit() {
        // this.dynamicToolGenerator.onModuleInit() - Removed to prevent duplicate tool generation
        this.logger.log(
            `Tool registry initialized: ${this.dynamicToolGenerator.getAllToolNames().length} dynamic tools, ${this.customTools.size} custom tools`,
        )
    }

    /** Register a custom (hand-written) tool */
    registerCustomTool(tool: BaseTool) {
        this.customTools.set(tool.name, tool)
        this.logger.log(`Registered custom tool: ${tool.name}`)
    }

    /** Get all tool definitions the user's role can access */
    getToolDefinitions(roleName: string): AiToolDefinition[] {
        const role = roleName.toLowerCase()

        // Dynamic tools filtered by role
        const dynamicDefs = this.dynamicToolGenerator.getToolsForRole(role)

        // Custom tools filtered by role
        const customDefs = Array.from(this.customTools.values())
            .filter(t => t.canBeUsedBy(role))
            .map(t => t.getDefinition())

        return [...dynamicDefs, ...customDefs]
    }

    /** Execute a tool by name */
    async executeTool(
        toolName: string,
        params: Record<string, any>,
        user: UserWithRelations,
    ): Promise<string> {
        const roleName = user.role.roleName.toLowerCase()

        // Check if it's a dynamic query tool
        if (this.dynamicToolGenerator.isDynamicTool(toolName)) {
            const config = this.dynamicToolGenerator.getConfigForTool(toolName)
            if (!config) {
                return JSON.stringify({ error: `Tool '${toolName}' config not found` })
            }

            if (!config.allowedRoles.includes(roleName)) {
                return JSON.stringify({ error: `Access denied: '${toolName}' is not available for role '${roleName}'` })
            }

            return this.dynamicQueryExecutor.execute(config, params, user)
        }

        // Check if it's a custom tool
        const customTool = this.customTools.get(toolName)
        if (customTool) {
            if (!customTool.canBeUsedBy(roleName)) {
                return JSON.stringify({ error: `Access denied: '${toolName}' is not available for role '${roleName}'` })
            }
            return customTool.execute(params, user)
        }

        return JSON.stringify({ error: `Tool '${toolName}' not found` })
    }
}
