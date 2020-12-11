exports.handler = (event, context, callback) => {
  console.log('Entering authorizer handler with params: ');
  console.log('event: ', event);

  const {
    headers
  } = event.Records[0].cf.request;
  const username = 'sarasa';
  const password = 'sarasa';
  const validator = `Basic ${Buffer.from(`${username}:${password}`).toString('base64')}`;
  const unauthorizedResponse = {
    status: '401',
    statusDescription: 'Unauthorized',
    headers: {
      'www-authenticate': [{
        key: 'WWW-Authenticate',
        value: 'Basic'
      }]
    },
  };

  console.log('headers: ', headers);
  if (headers.authorization == null ||
    typeof headers.authorization === 'undefined' ||
    headers.authorization[0].value !== validator) {
    console.log('Request is not unauthorized...');
    callback(null, unauthorizedResponse);
  }

  console.log('Request is authorized!!!');
  callback(null, event.Records[0].cf.request);
};