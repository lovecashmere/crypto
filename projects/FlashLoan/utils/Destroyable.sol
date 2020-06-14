pragma solidity ^0.6.6;

import "https://github.com/lovecashmere/crypto/projects/FlashLoan/utils/Owned.sol";

contract Destroyable {

    modifier OwnerOnly {
          require(msg.sender == Owner, "Only the owner can call this function.");
          _;
    }

    // Withdraw funds to the owner before destroying the contract!
    function destroyContract() public OwnerOnly {
        Owner.transfer(address(this).balance);
        selfdestruct(Owner);
    }
}
