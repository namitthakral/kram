import { Type } from 'class-transformer'
import {
    IsArray,
    IsEnum,
    IsNotEmpty,
    IsOptional,
    IsString,
    MaxLength,
    ValidateNested,
} from 'class-validator'

export class ConversationMessageDto {
    @IsEnum(['user', 'assistant'])
    role: 'user' | 'assistant'

    @IsString()
    @MaxLength(5000)
    content: string
}

export class ChatDto {
    @IsString()
    @IsNotEmpty()
    @MaxLength(2000)
    message: string

    @IsOptional()
    @IsArray()
    @ValidateNested({ each: true })
    @Type(() => ConversationMessageDto)
    conversationHistory?: ConversationMessageDto[]
}
