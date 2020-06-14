pragma solidity ^0.6.6;

interface IFlashLoanReceiver {
    function executeOperation(address _reserve, uint256 _amount, uint256 _fee, bytes calldata _params, string calldata fromToken, string calldata toToken, address assetBorrow, address assetExchange) external;
}
