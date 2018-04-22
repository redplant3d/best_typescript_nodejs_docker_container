import { ExceptionFilter, Catch } from '@nestjs/common';

const isProduction = process.env.NODE_ENV == 'docker_production';

@Catch()
export class AnyExceptionFilter implements ExceptionFilter {
  catch(exception, response) {

    const message = isProduction ? undefined : exception.message;

    response
      .status(500)
      .json({
        statusCode: 500,
        message
      });
  }
}