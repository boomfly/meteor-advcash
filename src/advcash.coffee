import { Meteor } from 'meteor/meteor'
import { Random } from 'meteor/random'
import { check, Match } from 'meteor/check'
import { HTTP } from 'meteor/http'
import querystring from 'querystring'

import { sprintf } from 'sprintf-js'
import requestIp from 'request-ip'

import Signature from './signature'
import config from './config'

export default class AdvCash
  @debug: true

  @config: (cfg) -> if cfg then _.extend(config, cfg) else _.extend({}, config)
  @onSuccess: (cb) -> @_onSuccess = cb
  @onStatus: (cb) -> @_onStatus = cb
  @onFail: (cb) -> @_onFail = cb

  @call: (params, cb) ->
    # console.log config
    params.m_shop = config.merchantId
    params.m_curr = config.currency unless params.m_curr
    params.m_sign = Signature.sign(params, config.secretKey)
    return cb?(null, params)

  @getPaymentUrl: (options) ->
    check options, {
      amount: Number
      comment: Match.Optional String
      currency: Match.Optional String
      orderId: Match.OneOf String, Number
      language: Match.Optional String
    }
    { amount, comment, currency, language, orderId } = options
    params = {
      ac_account_email: config.email
      ac_sci_name: config.name
      ac_amount: sprintf("%01.2f", amount)
      ac_comment: new Buffer(comment).toString('base64')
      ac_currency: currency or config.currency
      ac_order_id: orderId
      ac_client_lang: language or config.language
    }

    # if @_onStatus
    #   params.ac_success_url = "#{config.siteUrl}/api/advcash/status"

    # if @_onStatus
    #   params.ac_status_url = "#{config.siteUrl}/api/#{config.callbackScriptName}?action=status"
    #
    # if @_onFail
    #   params.ac_fail_url = "#{config.siteUrl}/api/#{config.callbackScriptName}?action=fail"

    # params.m_params = Signature.encodeParams params.m_orderid, m_params
    params.ac_sign = Signature.sign(params, config.secret)

    query = querystring.stringify params

    "https://wallet.advcash.com/sci/?#{query}"

# Маршруты для обработки REST запросов от AdvCash

Rest = new Restivus
  useDefaultAuth: true
  prettyJson: true

# http://localhost:3200/api/paybox?action=result&amount=50&order_id=vYyioup4zJG9Tk5vd
Meteor.startup ->
  Rest.addRoute 'advcash/status', {authRequired: false},
    "#{config.callbackMethod}": ->
      if config.debug
        console.log 'AdvCash.restRoute', @queryParams, @bodyParams

      # if not config.debug
      #   clientIp = requestIp.getClientIp(@request)
      #   if clientIp not in ['185.71.65.92', '185.71.65.189', '149.202.17.210']
      #     return
      #       statusCode: 403
      #       body: 'Access restricted 403'

      if @queryParams?.ac_transfer? or @queryParams?.ac_order_id?
        params = _.omit @queryParams, ['__proto__']
      else if @bodyParams?.ac_transfer? or @bodyParams?.ac_order_id?
        params = _.omit @bodyParams, ['__proto__']
      else
        params = {}

      { action, ac_transaction_status, ac_hash } = params

      if ac_hash isnt Signature.hash(params)
        console.log 'Wrong hash', ac_hash, Signature.hash(params)
        return
          statusCode: 403
          body: 'Sign isnt correct'

      response = AdvCash._onStatus?(params)

      if response?.error
        console.log 'AdvCash.restRoute.error', response
        response =
          statusCode: 500
          body: "#{params.ac_order_id}.|error"

      if config.debug
        console.log 'AdvCash.restRoute.response', response

      response
