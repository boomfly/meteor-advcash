import AdvCashSCI from './sci'
import AdvCashAPI from './api'
import config from './config'

options = {
  password: config.api.secret
  apiName: config.api.name
  accountEmail: config.api.email
}

apiInit = ->
  apiClient = await AdvCashAPI options

export default {
  config: (cfg) -> if cfg then _.extend(config, cfg) else _.extend({}, config)
  API: apiInit
  SCI: AdvCashSCI
}