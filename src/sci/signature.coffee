import { URL } from 'url'
import path from 'path'
import crypto from 'crypto'
import {sprintf} from 'sprintf-js'
import config from '../config'

export default class Signature
  @hash: (params) ->
    {
      ac_transfer
      ac_start_date
      ac_sci_name
      ac_src_wallet
      ac_dest_wallet
      ac_order_id
      ac_amount
      ac_merchant_currency
    } = params
    paramsArray = [
      ac_transfer
      ac_start_date
      ac_sci_name
      ac_src_wallet
      ac_dest_wallet
      ac_order_id
      ac_amount
      ac_merchant_currency
      config.sci.secret
    ]
    sign = crypto.createHash('sha256').update(paramsArray.join(':'), 'utf-8').digest('hex')

  @sign: (params, secret) ->
    {
      ac_account_email
      ac_sci_name
      ac_amount
      ac_currency
      ac_order_id
    } = params

    paramsArray = [
      ac_account_email
      ac_sci_name
      ac_amount
      ac_currency
      secret
      ac_order_id
    ]

    sign = crypto.createHash('sha256').update(paramsArray.join(':'), 'utf-8').digest('hex').toUpperCase()
