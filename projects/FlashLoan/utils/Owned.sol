pragma solidity ^0.6.6;

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
