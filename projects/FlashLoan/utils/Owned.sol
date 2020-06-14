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
