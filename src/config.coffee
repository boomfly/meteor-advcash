export default {
  sci:
    email: process.env.ADVCASH_SCI_EMAIL
    secret: process.env.ADVCASH_SCI_SECRET
    name: process.env.ADVCASH_SCI_NAME
    callbackScriptName: 'advcash'
    callbackMethod: process.env.ADVCASH_SCI_CALLBACK_METHOD or 'get'
    siteUrl: Meteor.absoluteUrl()
  api:
    email: process.env.ADVCASH_API_EMAIL
    secret: process.env.ADVCASH_API_SECRET
    name: process.env.ADVCASH_API_NAME
  currency: 'USD'
  language: 'EN'
}