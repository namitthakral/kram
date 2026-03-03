import { PartialType } from '@nestjs/mapped-types'
import { CreateClassDivisionDto } from './create-class-division.dto'

export class UpdateClassDivisionDto extends PartialType(CreateClassDivisionDto) {}