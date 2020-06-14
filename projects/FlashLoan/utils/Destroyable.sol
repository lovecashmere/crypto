pragma solidity ^0.6.6;

contract Destroyable is Owned {

    // Withdraw funds to the owner before destroying the contract!
    function destroyContract() public OwnerOnly {
        Owner.transfer(address(this).balance);
        selfdestruct(Owner);
    }
}
