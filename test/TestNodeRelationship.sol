pragma solidity ^0.4.19;

// Test library
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

// Our contract
import "../contracts/storage_patterns/NodeRelationship.sol";


contract TestNodeRelationship {
    event Logging(address asdf);

    function testTruffleTest() public {
        uint expected = 1000;

        Assert.equal(1000, expected, "Comparing Integer");
    }

    function testInitialWallet() public {
        NodeRelationship node = NodeRelationship(DeployedAddresses.NodeRelationship());

    }

}