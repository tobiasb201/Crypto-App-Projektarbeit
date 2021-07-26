
class Constant{
  static final List currencies =["BTC","BAT","ETH","LTC","ADA","LINK","XLM","EOS","XTZ"]; // Used for api calls
  static String currentCurrency; //Value can change
  static var assetNameMap = {'BTC':'Bitcoin','BAT':'Basic Attention Token','ETH':'Ethereum','LTC':'Litecoin','ADA':'Cardano',
    'LINK':'Chainlink','XLM':'Stellar','EOS':'Electro-Optical System','XTZ':'Tezos'}; //Used for assetPage to get Full Name
}