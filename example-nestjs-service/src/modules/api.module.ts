import { Module } from '@nestjs/common';
import { ApiController } from './api.controller';


@Module({
  modules:      [ ],
  controllers:  [ ApiController ],
  components:   [ ],
})
export class ApiModule {}
