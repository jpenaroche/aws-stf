import * as dotenv from 'dotenv';

dotenv.config();

export default {
  host: process.env.GRAYLOG_HOST || '127.0.0.1',
  port: process.env.GRAYLOG_PORT || 12201,
};
