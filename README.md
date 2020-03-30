# Meteor AdvCash integration

Accept payments from AdvCash for Meteor.js.

## Intall

```shell
meteor add boomfly:meteor-advcash
```

## Simple example SCI usage

```coffeescript
import React from 'react'
import ReactDOM from 'react-dom'
import AdvCash from 'meteor/boomfly:meteor-advcash'

AdvCash.config {
  sci:
    email: ''
    secret: ''
    name: ''
  currency: 'USD'
}

if Meteor.isServer
  Meteor.methods
    placeOrder: (amount) ->
      params = { amount }
      paymentUrl = AdvCash.getPaymentUrl params

if Meteor.isClient
  class PaymentButton extends React.Component
    placeOrder: ->
      Meteor.call 'placeOrder', 100, (error, result) ->
        window.location.href = result.ac_redirect_url._text # Redirect to payment page

    render: ->
      <button className='btn btn-success' onClick={@placeOrder}>Pay 100 USD</button>

  ReactDOM.render <PaymentButton />, document.getElementById('app')
```

## API

### AdvCash.getPaymentUrl(params)

Инициализация платежа

**params** - Объект, полный список допустимых параметров можно посмотреть на [странице](https://advcash.com/files/documents/sci_1_10_final_uptodate_1.pdf)

## Events

### AdvCash.onStatus(callback)

Обработка результата платежа

**callback** - Функция обработки результата платежа, принимает 1 параметр (params). Полный список параметров на [странице](https://advcash.com/files/documents/sci_1_10_final_uptodate_1.pdf)

**return** - Функция должна вернуть объект с результатом проверки. Результат функции будет конвертирован в `xml` и отправлен ответом на запрос AdvCash.

**пример**:

```coffeescript
AdvCash.SCI.onStatus (params) ->
  order = Order.findOne params.ac_order_id
  if not order
    ac_status: 'rejected'
    ac_description: "Order with _id: '#{params.ac_order_id}' not found"
  else
    if order.status is OrderStatus.PENDING_PAYMENT
      ac_status: 'ok'
    else if order.status is OrderStatus.CANCELLED
      ac_status: 'rejected'
      ac_description: 'Order cancelled'
    else if order.status is OrderStatus.PROCESSED
      ac_status: 'rejected'
      ac_description: 'Order already processed'
```
