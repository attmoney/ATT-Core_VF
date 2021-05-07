# xATT

xATT is a non-rebasing BEP20 token that is swappable for ATT at a variable rate. It's purpose is to create an asset is tied to the market cap of ATT, can be easily listed on CEXes, can be used in more yield farms and dapps to expand ATT's total reach and market cap. xATT is can only be created by locking ATT meaning that it does not dilute ATT's market cap.

## Minting

Users lock ATT in the xATT smart contract to mint xATT. This is done by calling the mint() function with the desired ATT input amount. In return, the user receives xATT at the current rate (note that xATT has 18 decimals while ATT has 9). E.g.:

```
approve(XA_ADDRESS, 10000000000000)
mint(XA_ADDRESS,10000000000000)
```

## Redemption

Users can get ATT by burning xATT using the burn function. `burn(amount)` burns `amount` xATT and returns ATT according to the current exchange rate.

## Exchange rate

The exchange rate adjusts dynamically as ATT rebases. To get the ATT returned for 1 xATT call:

`getRedeemAmount(1000000000000000000)`


# Attributions

1. Project was forked from https://github.com/Ditto-money
