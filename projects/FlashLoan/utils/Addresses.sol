pragma solidity ^0.6.6;

contract Addresses {

        mapping (string=>address) tokenAddress;

        constructor() public {

            // // Kovan testnet addresses - COMMENT OUT WHEN DEPLOYING TO MAINNET
            // address ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
            // address DAI = 0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD;
            // address USDT = 0x13512979ADE267AB5100878E2e0f485B568328a4;
            // address BAT = 0x2d12186Fbb9f9a8C28B3FfdD4c42920f8539D738;
            // address LINK = 0xAD5ce863aE3E4E9394Ab43d4ba0D80f419F61789;
            // address KNC = 0x3F80c39c0b96A0945f9F0E9f55d8A8891c5671A8;
            // address ZRX = 0xD0d76886cF8D952ca26177EB7CfDf83bad08C00C;
            // address MKR = 0x61e4CAE3DA7FD189e52a4879C7B8067D7C2Cc0FA;
            // address WBTC = 0x3b92f58feD223E2cB1bCe4c286BD97e42f2A12EA;
            // address REP = 0x260071C8D61DAf730758f8BD0d6370353956AE0E;
            // address SNX = 0x7FDb81B0b8a010dd4FFc57C3fecbf145BA8Bd947;
            // address LEND = 0x1BCe8A0757B7315b74bA1C7A731197295ca4747a;

            // // // Mainnet addresses - COMMENT OUT WHEN DEPLOYING TO KOVAN TESTNET
            // // address ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
            // // address DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
            // // address USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
            // // address BAT = 0x0D8775F648430679A709E98d2b0Cb6250d2887EF;
            // // address LINK = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
            // // address KNC = 0xdd974D5C2e2928deA5F71b9825b8b646686BD200;
            // // address ZRX = 0xE41d2489571d322189246DaFA5ebDe1F4699F498;
            // // address MKR = 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2;
            // // address WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
            // // address REP = 0x1985365e9f78359a9B6AD760e32412f4a445E862;
            // // address SNX = 0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F;
            // // address LEND = 0x80fB784B7eD66730e8b1DBd9820aFD29931aab03;

            // Kovan testnet addresses - COMMENT OUT WHEN DEPLOYING TO MAINNET
            tokenAddress['ETH'] = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
            tokenAddress['DAI'] = 0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD;
            tokenAddress['USDT'] = 0x13512979ADE267AB5100878E2e0f485B568328a4;
            tokenAddress['BAT'] = 0x2d12186Fbb9f9a8C28B3FfdD4c42920f8539D738;
            tokenAddress['LINK'] = 0xAD5ce863aE3E4E9394Ab43d4ba0D80f419F61789;
            tokenAddress['KNC'] = 0x3F80c39c0b96A0945f9F0E9f55d8A8891c5671A8;
            tokenAddress['ZRX'] = 0xD0d76886cF8D952ca26177EB7CfDf83bad08C00C;
            tokenAddress['MKR'] = 0x61e4CAE3DA7FD189e52a4879C7B8067D7C2Cc0FA;
            tokenAddress['WBTC'] = 0x3b92f58feD223E2cB1bCe4c286BD97e42f2A12EA;
            tokenAddress['REP'] = 0x260071C8D61DAf730758f8BD0d6370353956AE0E;
            tokenAddress['SNX'] = 0x7FDb81B0b8a010dd4FFc57C3fecbf145BA8Bd947;
            tokenAddress['LEND'] = 0x1BCe8A0757B7315b74bA1C7A731197295ca4747a;

            // // Mainnet addresses - COMMENT OUT WHEN DEPLOYING TO KOVAN TESTNET
            // tokenAddress['ETH'] = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
            // tokenAddress['DAI'] = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
            // tokenAddress['USDT'] = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
            // tokenAddress['BAT'] = 0x0D8775F648430679A709E98d2b0Cb6250d2887EF;
            // tokenAddress['LINK'] = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
            // tokenAddress['KNC'] = 0xdd974D5C2e2928deA5F71b9825b8b646686BD200;
            // tokenAddress['ZRX'] = 0xE41d2489571d322189246DaFA5ebDe1F4699F498;
            // tokenAddress['MKR'] = 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2;
            // tokenAddress['WBTC'] = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
            // tokenAddress['REP'] = 0x1985365e9f78359a9B6AD760e32412f4a445E862;
            // tokenAddress['SNX'] = 0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F;
            // tokenAddress['LEND'] = 0x80fB784B7eD66730e8b1DBd9820aFD29931aab03;

          }
}
