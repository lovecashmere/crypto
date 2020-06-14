pragma solidity ^0.6.6;

contract Owned {

    constructor() public {
        address payable public Owner;
        Owner = msg.sender;

        modifier OwnerOnly {
            require(msg.sender == Owner, "Only the owner can call this function.");
            _;
        }
    }
}
