import { Type } from 'class-transformer'
import {
  ArrayMinSize,
  IsArray,
  IsBoolean,
  IsInt,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Min,
  ValidateNested,
} from 'class-validator'

export class EnterExamResultDto {
  @IsInt()
  @IsNotEmpty()
  studentId: number

  @IsNumber()
  @IsOptional()
  @Min(0)
  marksObtained?: number

  @IsBoolean()
  @IsOptional()
  isAbsent?: boolean

  @IsString()
  @IsOptional()
  remarks?: string
}

export class BulkEnterExamResultDto {
  @IsArray()
  @ValidateNested({ each: true })
  @ArrayMinSize(1)
  @Type(() => EnterExamResultDto)
  results: EnterExamResultDto[]
}

export class UpdateExamResultDto {
  @IsNumber()
  @IsOptional()
  @Min(0)
  marksObtained?: number

  @IsBoolean()
  @IsOptional()
  isAbsent?: boolean

  @IsString()
  @IsOptional()
  remarks?: string
}
