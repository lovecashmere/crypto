pragma solidity ^0.6.6;

//store these files in own GitHub & amend FlashloanReceiverBase.sol @openzeppelin to ./

import "https://github.com/lovecashmere/crypto/projects/flashloan/aave/base/FlashLoanReceiverBase.sol"
import "https://github.com/lovecashmere/crypto/projects/flashloan/aave/interfaces/IFlashLoanReceiver.sol"
import "https://github.com/lovecashmere/crypto/projects/flashloan/aave/interfaces/ILendingPool.sol"
import "https://github.com/lovecashmere/crypto/projects/flashloan/aave/interfaces/ILendingPoolAddressesProvider.sol"
import "https://github.com/lovecashmere/crypto/projects/flashloan/utils/Addresses.sol"
import "https://github.com/lovecashmere/crypto/projects/flashloan/utils/Destroyable.sol"
import "https://github.com/lovecashmere/crypto/projects/flashloan/utils/Owned.sol"
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol"
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol"
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol"
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol"
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/SafeERC20.sol"

contract Withdrawable is Ownable {
    using SafeERC20 for ERC20;
    address constant ETHER = address(0);

    event LogWithdraw(
        address indexed _from,
        address indexed _assetAddress,
        uint amount
    );

    /**
     * @dev Withdraw asset.
     * @param _assetAddress Asset to be withdrawn.
     */
    function withdraw(address _assetAddress) public onlyOwner {
        uint assetBalance;
        if (_assetAddress == ETHER) {
            address self = address(this); // workaround for a possible solidity bug
            assetBalance = self.balance;
            msg.sender.transfer(assetBalance);
        } else {
            assetBalance = ERC20(_assetAddress).balanceOf(address(this));
            ERC20(_assetAddress).safeTransfer(msg.sender, assetBalance);
        }
        emit LogWithdraw(msg.sender, _assetAddress, assetBalance);
    }
}

interface IFlashLoanReceiver {
    function executeOperation(address _reserve, uint256 _amount, uint256 _fee, bytes calldata _params, string calldata fromToken, string calldata toToken, address assetBorrow, address assetExchange) external;
}

interface ILendingPoolAddressesProvider {
    function getLendingPoolCore() external view returns (address payable);
    function getLendingPool() external view returns (address);
}

interface ILendingPool {
  function addressesProvider () external view returns ( address );
  function deposit ( address _reserve, uint256 _amount, uint16 _referralCode ) external payable;
  function redeemUnderlying ( address _reserve, address _user, uint256 _amount ) external;
  function borrow ( address _reserve, uint256 _amount, uint256 _interestRateMode, uint16 _referralCode ) external;
  function repay ( address _reserve, uint256 _amount, address _onBehalfOf ) external payable;
  function swapBorrowRateMode ( address _reserve ) external;
  function rebalanceFixedBorrowRate ( address _reserve, address _user ) external;
  function setUserUseReserveAsCollateral ( address _reserve, bool _useAsCollateral ) external;
  function liquidationCall ( address _collateral, address _reserve, address _user, uint256 _purchaseAmount, bool _receiveAToken ) external payable;
  function flashLoan ( address _receiver, address _reserve, uint256 _amount, bytes calldata _params ) external;
  function getReserveConfigurationData ( address _reserve ) external view returns ( uint256 ltv, uint256 liquidationThreshold, uint256 liquidationDiscount, address interestRateStrategyAddress, bool usageAsCollateralEnabled, bool borrowingEnabled, bool fixedBorrowRateEnabled, bool isActive );
  function getReserveData ( address _reserve ) external view returns ( uint256 totalLiquidity, uint256 availableLiquidity, uint256 totalBorrowsFixed, uint256 totalBorrowsVariable, uint256 liquidityRate, uint256 variableBorrowRate, uint256 fixedBorrowRate, uint256 averageFixedBorrowRate, uint256 utilizationRate, uint256 liquidityIndex, uint256 variableBorrowIndex, address aTokenAddress, uint40 lastUpdateTimestamp );
  function getUserAccountData ( address _user ) external view returns ( uint256 totalLiquidityETH, uint256 totalCollateralETH, uint256 totalBorrowsETH, uint256 availableBorrowsETH, uint256 currentLiquidationThreshold, uint256 ltv, uint256 healthFactor );
  function getUserReserveData ( address _reserve, address _user ) external view returns ( uint256 currentATokenBalance, uint256 currentUnderlyingBalance, uint256 currentBorrowBalance, uint256 principalBorrowBalance, uint256 borrowRateMode, uint256 borrowRate, uint256 liquidityRate, uint256 originationFee, uint256 variableBorrowIndex, uint256 lastUpdateTimestamp, bool usageAsCollateralEnabled );
  function getReserves () external view;
}

abstract contract FlashLoanReceiverBase is IFlashLoanReceiver, Withdrawable {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address constant ethAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    ILendingPoolAddressesProvider public addressesProvider;

    constructor(address _addressProvider) public {
        addressesProvider = ILendingPoolAddressesProvider(_addressProvider);
    }

    receive() payable external {}

    function transferFundsBackToPoolInternal(address _reserve, uint256 _amount) internal {
        address payable core = addressesProvider.getLendingPoolCore();
        transferInternal(core, _reserve, _amount);
    }

    function transferInternal(address payable _destination, address _reserve, uint256 _amount) internal {
        if(_reserve == ethAddress) {
            (bool success, ) = _destination.call{value: _amount}("");
            require(success == true, "Couldn't transfer ETH");
            return;
        }
        IERC20(_reserve).safeTransfer(_destination, _amount);
    }

    function getBalanceInternal(address _target, address _reserve) internal view returns(uint256) {
        if(_reserve == ethAddress) {
            return _target.balance;
        }
        return IERC20(_reserve).balanceOf(_target);
    }
}

contract Owned {

    address payable public Owner;

    constructor() public {
        Owner = msg.sender;
    }

    modifier OwnerOnly {
        require(msg.sender == Owner, "Only the owner can call this function.");
        _;
    }
}

contract Destroyable is Owned {

    // Withdraw funds to the owner before destroying the contract!
    function destroyContract() public OwnerOnly {
        Owner.transfer(address(this).balance);
        selfdestruct(Owner);
    }
}

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


// The following is the Kovan Testnet address for the LendingPoolAddressProvider. Get the correct address for your network from: https://docs.aave.com/developers/developing-on-aave/deployed-contract-instances
contract MyFlashloanContract is Addresses, Owned, Destroyable, FlashLoanReceiverBase {

    // Kovan testnet address - COMMENT OUT WHEN DEPLOYING TO MAINNET
    constructor(address _addressProvider) FlashLoanReceiverBase(0x506B0B2CF20FAA8f38a4E2B524EE43e1f4458Cc5) public {}

    // // Mainnet address - COMMENT OUT WHEN DEPLOYING TO KOVAN TESTNET
    // constructor(address _addressProvider) FlashLoanReceiverBase(0x24a42fD28C976A61Df5D00D0599C34c4f90748c8) public {}

    event Profit(uint256 profitAmount);
    event FlashLoanSuccess(string message, string fromAsset, string toAsset);
    event WithdrawSuccess(string message);

    // Carry out flash loan  -  this then calls function executeOperation
    function flashloan(uint256 LoanAmount, string memory fromToken, string memory toToken) public OwnerOnly {
        bytes memory data = "";
        uint amount = LoanAmount;
        address assetBorrow = getAddress(fromToken);
        address assetExchange = getAddress(toToken);

        ILendingPool lendingPool = ILendingPool(addressesProvider.getLendingPool());
        lendingPool.flashLoan(address(this), assetBorrow, amount, data);
    }

    // Called by function flashloan
    function executeOperation (
        address _reserve,
        uint256 _amount,
        uint256 _fee,
        bytes calldata _params,
        string calldata fromToken,
        string calldata toToken,
        address assetBorrow,
        address assetExchange
    )
        external
        override
    {
        require(_amount <= getBalanceInternal(address(this), _reserve), "Invalid balance, was the flashLoan successful?");

        ERC20 erc20_fromToken = ERC20(assetBorrow);
        ERC20 erc20_toToken = ERC20(assetExchange);

            // if (keccak256(bytes(fromToken)) != keccak256(bytes("ETH"))){
            //     ERC20 erc20_fromToken = ERC20(assetBorrow);
            // }
            // else{
            //     erc20_fromToken = assetBorrow;
            // }

            // if (keccak256(bytes(toToken)) != keccak256(bytes("ETH"))){
            //     ERC20 erc20_toToken = ERC20(assetExchange);
            // }
            // else{
            //     address erc20_toToken = assetExchange;
            // }

        //
        // do your thing here
        //


        // Any left over amount of token is considered profit
        uint256 profitAmount = erc20_fromToken.balanceOf(address(this));
        emit Profit(profitAmount);

        // // Sending back the profits
        // require(erc20_fromToken.transfer(Owner, profitAmount), "Could not transfer back the profit");


        // Transfer the funds back to liqidity pool
        uint totalDebt = _amount.add(_fee);
        transferFundsBackToPoolInternal(_reserve, totalDebt);

        emit FlashLoanSuccess("The flash loan was succesful!", fromToken, toToken);
    }


    //Withdraw funds
    function WithdrawFunds() public payable OwnerOnly{
        Owner.transfer(address(this).balance);

        emit WithdrawSuccess("Withdraw funds successful.");
    }

    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

    //Get the relevant token address mapping
    function getAddress(string memory _Token) public view returns (address) {
        return tokenAddress[_Token];
    }

}
