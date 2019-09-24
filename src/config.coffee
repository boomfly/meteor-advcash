export default
  email: process.env.ADVCASH_EMAIL
  name: process.env.ADVCASH_NAME
  secret: process.env.ADVCASH_SECRET
  callbackScriptName: 'advcash'
  callbackMethod: process.env.ADVCASH_CALLBACK_METHOD or 'get'
  currency: 'USD'
  language: 'EN'
