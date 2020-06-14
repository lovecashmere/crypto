pragma solidity ^0.6.6;

import "https://github.com/lovecashmere/crypto/projects/FlashLoan/aave/base/FlashLoanReceiverBase.sol";
import "https://github.com/lovecashmere/crypto/projects/FlashLoan/aave/interfaces/IFlashLoanReceiver.sol";
import "https://github.com/lovecashmere/crypto/projects/FlashLoan/aave/interfaces/ILendingPool.sol";
import "https://github.com/lovecashmere/crypto/projects/FlashLoan/aave/interfaces/ILendingPoolAddressesProvider.sol";
import "https://github.com/lovecashmere/crypto/projects/FlashLoan/utils/Addresses.sol";
import "https://github.com/lovecashmere/crypto/projects/FlashLoan/utils/Owned.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC20/SafeERC20.sol";


// The following is the Kovan Testnet address for the LendingPoolAddressProvider. Get the correct address for your network from: https://docs.aave.com/developers/developing-on-aave/deployed-contract-instances
contract MyFlashloanContract is Addresses, Owned, FlashLoanReceiverBase {

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
