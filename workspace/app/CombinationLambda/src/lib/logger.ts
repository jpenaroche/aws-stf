import {graylog as G2} from 'graylog2';
import {app, graylog} from '../config';

interface ILogger {
  log: (message: string, data?: Record<string, unknown>) => void;
  info: (message: string) => void;
  error: (error: string) => void;
  warn: (message: string) => void;
  close: () => void;
}

class GraylogLogger implements ILogger {
  private g2;
  constructor(host: string, port: number) {
    this.g2 = new G2({
      servers: [{host, port}],
      facility: 'CombinationLambda',
    });
  }
  log(message: string, data?: Record<string, unknown>) {
    this.g2.log(message, data);
  }
  info(message: string) {
    this.g2.info(message);
  }
  error(error: string | Error) {
    this.g2.error(error);
  }
  warn(message: string) {
    this.g2.warn(message);
  }
  close() {
    this.g2.close();
  }
}

class ConsoleLogger implements ILogger {
  log(message: string, data?: Record<string, unknown>) {
    console.log(message, data);
  }
  info(message: string) {
    console.info(message);
  }
  error(error: string | Error) {
    console.error(error);
  }
  warn(message: string) {
    console.warn(message);
  }
  close() {}
}

export const getLogger = (): ILogger => {
  if (app.environment === 'local') {
    const {host, port} = graylog;
    return new GraylogLogger(host, +port);
  }
  return new ConsoleLogger();
};
