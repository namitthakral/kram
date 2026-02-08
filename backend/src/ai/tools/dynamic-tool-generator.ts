import { Injectable, Logger } from '@nestjs/common'
import { AiToolDefinition } from '../interfaces/ai-provider.interface'
import { MODEL_ACCESS_CONFIG, ModelAccessEntry } from './model-access.config'

interface GeneratedTool {
    definition: AiToolDefinition
    config: ModelAccessEntry
    modelKey: string
}

@Injectable()
export class DynamicToolGenerator {
    private readonly logger = new Logger(DynamicToolGenerator.name)
    private generatedTools: GeneratedTool[] = []

    onModuleInit() {
        this.generateTools()
    }

    private generateTools() {
        for (const [modelKey, config] of Object.entries(MODEL_ACCESS_CONFIG)) {
            const toolName = `query_${this.toSnakeCase(modelKey)}`
            const filterableDesc = config.filterableFields.length
                ? ` Filterable: ${config.filterableFields.join(', ')}.`
                : ''
            const includeDesc = config.allowedIncludes.length
                ? ` Includable relations: ${config.allowedIncludes.join(', ')}.`
                : ''

            const definition: AiToolDefinition = {
                name: toolName,
                description: `${config.description}${filterableDesc}${includeDesc}`,
                parameters: {
                    type: 'object',
                    properties: {
                        filters: {
                            type: 'object',
                            description: `Key-value pairs to filter by. Allowed keys: ${config.filterableFields.join(', ')}`,
                        },
                        include: {
                            type: 'array',
                            items: { type: 'string' },
                            description: config.allowedIncludes.length
                                ? `Related data to include. Options: ${config.allowedIncludes.join(', ')}`
                                : 'No includes available for this model.',
                        },
                        orderBy: {
                            type: 'string',
                            description: 'Field to sort by. Prefix with - for descending. Example: "-currentYear"',
                        },
                        limit: {
                            type: 'number',
                            description: 'Max results to return (default 10, max 50)',
                        },
                        count: {
                            type: 'boolean',
                            description: 'If true, returns only the count of matching records instead of the records themselves.',
                        },
                    },
                },
            }

            this.generatedTools.push({ definition, config, modelKey })
        }

        this.logger.log(`Generated ${this.generatedTools.length} dynamic query tools from schema config`)
    }

    /** Get tool definitions filtered by role */
    getToolsForRole(roleName: string): AiToolDefinition[] {
        const role = roleName.toLowerCase()
        return this.generatedTools
            .filter(t => t.config.allowedRoles.includes(role))
            .map(t => t.definition)
    }

    /** Get the model config for a tool by its name */
    getConfigForTool(toolName: string): ModelAccessEntry | null {
        const tool = this.generatedTools.find(t => t.definition.name === toolName)
        return tool?.config || null
    }

    /** Check if a tool name is a dynamic query tool */
    isDynamicTool(toolName: string): boolean {
        return this.generatedTools.some(t => t.definition.name === toolName)
    }

    /** Get all generated tool names */
    getAllToolNames(): string[] {
        return this.generatedTools.map(t => t.definition.name)
    }

    private toSnakeCase(str: string): string {
        return str
            .replace(/([A-Z])/g, '_$1')
            .toLowerCase()
            .replace(/^_/, '')
    }
}
