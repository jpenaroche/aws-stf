export async function handler(event: any, context: any) {
  console.log(
    'New logic executed from query lambda + event data in parallel: ',
    JSON.stringify(event)
  );
  return context.logStreamName;
}
