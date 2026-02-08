import { AiToolDefinition } from '../interfaces/ai-provider.interface'
import { UserWithRelations } from '../../types/auth.types'

export abstract class BaseTool {
    abstract readonly name: string
    abstract readonly description: string
    abstract readonly allowedRoles: string[]
    abstract readonly parameters: Record<string, any>

    abstract execute(
        params: Record<string, any>,
        user: UserWithRelations,
    ): Promise<string>

    canBeUsedBy(roleName: string): boolean {
        return this.allowedRoles.includes(roleName.toLowerCase())
    }

    getDefinition(): AiToolDefinition {
        return {
            name: this.name,
            description: this.description,
            parameters: this.parameters,
        }
    }
}
