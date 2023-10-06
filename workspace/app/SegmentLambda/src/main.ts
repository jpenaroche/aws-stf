export async function handler(event: any, context: any) {
  console.log(
    'New logic executed from segment lambda' + JSON.stringify(context)
  );
  return context.logStreamName;
}
