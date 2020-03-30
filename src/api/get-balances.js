function convertWalletIdToSymbol(walletId) {
  switch (walletId[0]) {
    case 'U': return 'USD'
    case 'E': return 'EUR'
    case 'R': return 'RUB'
    case 'T': return 'KZT'
    case 'H': return 'UAH'
    default: return 'Unknown'
  }
}
export default (balances) => balances.map(balance => {
    return { amount: parseFloat(balance.amount), id: balance.id, currency: convertWalletIdToSymbol(balance.id) }
})