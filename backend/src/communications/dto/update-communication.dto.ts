import { OmitType, PartialType } from '@nestjs/mapped-types';
import { CreateCommunicationDto } from './create-communication.dto';

// Omit createdBy since it shouldn't be updated
export class UpdateCommunicationDto extends PartialType(
  OmitType(CreateCommunicationDto, ['createdBy'] as const),
) {}

