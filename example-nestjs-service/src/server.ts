import { NestFactory } from '@nestjs/core';
import { ApiModule } from './modules/api.module';
import { AnyExceptionFilter } from './filter/any-exception.filter';
import * as express from 'express';
import * as bodyParser from 'body-parser';
import * as compression from 'compression';

async function bootstrap() {

  const expressApp = express();
  expressApp.use(compression());
  expressApp.use(bodyParser.json({limit: '1mb'}));
  expressApp.use(bodyParser.urlencoded({limit: '1mb', extended: false }));
  // expressApp.set('trust proxy', 'proxy');

  const app = await NestFactory.create(ApiModule, <any>expressApp);
  app.setGlobalPrefix('api/v1');
  app.useGlobalFilters(new AnyExceptionFilter());
  await app.listen(3000);
}

bootstrap();