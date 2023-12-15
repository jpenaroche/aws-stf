import {getLogger} from './lib/logger';

export async function handler(event: any, context: any) {
  const logger = getLogger();
  const data = [
    {
      key: 'hello',
    },
    {
      key: 'world',
    },
  ];

  logger.log('Mesage in Combination Lambda handler. Sending Item list', {
    payload: data,
  });
  data.push({key: '!!'});
  logger.close();
  return data;
}
handler(null, null);
