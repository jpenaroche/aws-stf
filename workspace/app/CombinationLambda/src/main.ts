export async function handler(event: any, context: any) {
  console.log(
    'New logic executed from combination lambda ' + JSON.stringify(event)
  );
  return [
    {
      name: 'joe',
    },
    {
      name: 'ana',
    },
  ];
}
