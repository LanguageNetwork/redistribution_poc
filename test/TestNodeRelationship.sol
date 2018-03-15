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

    function testTruffleTest() public {
        uint expected = 1000;

        Assert.equal(1000, expected, "Comparing Integer");
    }

    function testConstructor() public {
        NodeRelationship node = NodeRelationship(DeployedAddresses.NodeRelationship());

        Assert.equal(node.owner(), tx.origin, "Constructor Testing");
    }

    function testGetDataSetCount() public {
        NodeRelationship node = new NodeRelationship();

        Assert.equal(node.getDataSetCount(), 0, "getDataSetCount() should return 0 at start");
    }

    function testGetRawDataCount() public {
        NodeRelationship node = new NodeRelationship();

        Assert.equal(node.getRawDataCount(), 0, "getRawDataCount() should return 0 at start");
    }

    function testAddDataSet() public {
        NodeRelationship node = new NodeRelationship();

        Assert.equal(node.createDataSet(testDataSetId), true, "createDataSet() should return true");
        Assert.equal(node.isDataSet(testDataSetId), true, "isDataSet() should return true with valid dataset id");
        Assert.equal(node.isDataSet("wrong_dataset_id"), false, "isDataSet() should return false with invalid dataset id");
    }

    function testAddRawData() public {
        NodeRelationship node = new NodeRelationship();

        Assert.equal(node.createRawData(testRawDataId), true, "createRawData() should return true");
        Assert.equal(node.isRawData(testRawDataId), true, "isRawData() should return true with valid dataset id");
        Assert.equal(node.isRawData("wrong_dataset_id"), false, "isRawData() should return false with invalid dataset id");
    }

    function testCreateDeleteDataSet() public {
        NodeRelationship node = new NodeRelationship();

        // Dataset creation
        Assert.equal(node.createDataSet(testDataSetId), true, "createDataSet() should return true");
        Assert.equal(node.getDataSetCount(), 1, "After creation, dataset length should return 1");

        Assert.equal(node.deleteDataSet(testDataSetId), true, "deleteDataSet() should return true");
        Assert.equal(node.getDataSetCount(), 0, "After deletion, dataset length should return 0");
    }

    function testCreateDeleteRawData() public {
        NodeRelationship node = new NodeRelationship();

        // RawData creation
        Assert.equal(node.createRawData(testRawDataId), true, "createRawData() should return true");
        Assert.equal(node.getRawDataCount(), 1, "After creation, raw data length should return 1");

        Assert.equal(node.deleteRawData(testRawDataId), true, "deleteRawData() should return true");
        Assert.equal(node.getRawDataCount(), 0, "After deletion, raw data length should return 0");
    }

    function testRelationshipCreateDelete() public {
        NodeRelationship node = new NodeRelationship();

        // Raw data creation
        node.createRawData(testRawDataId);
        Assert.equal(node.getRawDataCount(), 1, "After raw data creation, raw data length should return 1");

        // Raw data creation
        node.createDataSet(testDataSetId);
        Assert.equal(node.getDataSetCount(), 1, "After dataset creation, data set length should return 1");


        // Before create
        Assert.equal(node.getChildRawDataCount(testDataSetId), 0, "Before make relationship, getChildRawDataCount() should return 0");
        Assert.equal(node.getChildDataSetCount(testRawDataId), 0, "Before make relationship, getChildDataSetCount() should return 0");

        node.makeRelation(testDataSetId, testRawDataId);

        // Before create
        Assert.equal(node.getChildRawDataCount(testDataSetId), 1, "After make relationship, getChildRawDataCount() should return 1");
        Assert.equal(node.getChildDataSetCount(testRawDataId), 1, "After make relationship, getChildDataSetCount() should return 1");
    }
}
