import { Get, Response, Controller } from '@nestjs/common';
import * as Express from 'express';

@Controller()
export class ApiController {

  @Get()
  root(@Response() response: Express.Response) {
    response.send('Example Nest.js API v1');
  }
}
