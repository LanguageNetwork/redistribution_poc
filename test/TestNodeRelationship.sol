pragma solidity ^0.4.19;

// Test library
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

// Our contract
import "../contracts/storage_patterns/NodeRelationship.sol";

// Type import


contract TestNodeRelationship {
    bytes32 testDataSetId = "test_dataset_id";
    bytes32 testRawDataId = "test_raw_data_id";

    event Logging(address asdf);

    function testTruffleTest() public {
        uint expected = 1000;

        Assert.equal(1000, expected, "Comparing Integer");
    }

    function testConstructor() public {
        NodeRelationship node = NodeRelationship(DeployedAddresses.NodeRelationship());
        address value = node.owner();
        address expected = tx.origin;

        Assert.equal(value, expected, "Constructor Testing");

    }

    function testGetDataSetCount() public {
        NodeRelationship node = new NodeRelationship();
        uint value = node.getDataSetCount();
        uint expected = 0;

        Assert.equal(value, expected, "getDataSetCount() should return 0 at start");
    }

    function testGetRawDataCount() public {
        NodeRelationship node = new NodeRelationship();
        uint value = node.getRawDataCount();
        uint expected = 0;

        Assert.equal(value, expected, "getRawDataCount() should return 0 at start");
    }

    function testAddDataSet() public {
        NodeRelationship node = new NodeRelationship();
        bool result;

        result = node.createDataSet(testDataSetId);
        Assert.equal(result, true, "createDataSet() should return true");

        result = node.isDataSet(testDataSetId);
        Assert.equal(result, true, "isDataSet() should return true with valid dataset id");

        result = node.isDataSet("wrong_dataset_id");
        Assert.equal(result, false, "isDataSet() should return false with invalid dataset id");
    }
    
    function testAddRawData() public {
        NodeRelationship node = new NodeRelationship();
        bool result;
        
        result = node.createRawData(testRawDataId);
        Assert.equal(result, true, "createRawData() should return true");

        result = node.isRawData(testRawDataId);
        Assert.equal(result, true, "isRawData() should return true with valid dataset id");

        result = node.isRawData("wrong_dataset_id");
        Assert.equal(result, false, "isRawData() should return false with invalid dataset id");
        
    }
}
