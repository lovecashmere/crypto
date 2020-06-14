pragma solidity ^0.6.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Destroyable is Owned {

    // Withdraw funds to the owner before destroying the contract!
    function destroyContract() public onlyOwner {
        msg.sender.transfer(address(this).balance);
        selfdestruct(msg.sender);
    }
}
