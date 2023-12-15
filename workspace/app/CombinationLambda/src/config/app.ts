import * as dotenv from 'dotenv';

dotenv.config();

export default {
  environment: process.env.ENV ?? 'local',
};
