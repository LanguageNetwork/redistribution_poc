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

    function testCheckDataSet() public {
        NodeRelationship node = new NodeRelationship();

        Assert.equal(node.createDataSet(testDataSetId), true, "createDataSet() should return true");
        Assert.equal(node.isDataSet(testDataSetId), true, "isDataSet() should return true with valid dataset id");
        Assert.equal(node.isDataSet("wrong_dataset_id"), false, "isDataSet() should return false with invalid dataset id");
    }

    function testCheckRawData() public {
        NodeRelationship node = new NodeRelationship();

        Assert.equal(node.createRawData(testRawDataId), true, "createRawData() should return true");
        Assert.equal(node.isRawData(testRawDataId), true, "isRawData() should return true with valid dataset id");
        Assert.equal(node.isRawData("wrong_dataset_id"), false, "isRawData() should return false with invalid dataset id");
    }

    function testDataSet() public {
        NodeRelationship node = new NodeRelationship();

        // Dataset creation
        Assert.equal(node.createDataSet(testDataSetId), true, "createDataSet() should return true");
        Assert.equal(node.getDataSetCount(), 1, "After creation, dataset length should return 1");

        Assert.equal(node.deleteDataSet(testDataSetId), true, "deleteDataSet() should return true");
        Assert.equal(node.getDataSetCount(), 0, "After deletion, dataset length should return 0");
    }

    function testRawData() public {
        NodeRelationship node = new NodeRelationship();

        // RawData creation
        Assert.equal(node.createRawData(testRawDataId), true, "createRawData() should return true");
        Assert.equal(node.getRawDataCount(), 1, "After creation, raw data length should return 1");

        Assert.equal(node.deleteRawData(testRawDataId), true, "deleteRawData() should return true");
        Assert.equal(node.getRawDataCount(), 0, "After deletion, raw data length should return 0");
    }

    function testRelationship() public {
        NodeRelationship node = new NodeRelationship();

        // Raw data creation
        node.createRawData(testRawDataId);
        Assert.equal(node.getRawDataCount(), 1, "After raw data creation, raw data length should return 1");

        // Dataset creation
        node.createDataSet(testDataSetId);
        Assert.equal(node.getDataSetCount(), 1, "After dataset creation, data set length should return 1");


        // Before relationship creation
        Assert.equal(node.getChildRawDataCount(testDataSetId), 0, "Before make relationship, getChildRawDataCount() should return 0");
        Assert.equal(node.getChildDataSetCount(testRawDataId), 0, "Before make relationship, getChildDataSetCount() should return 0");

        node.makeRelation(testDataSetId, testRawDataId);

        // After relationship creation
        Assert.equal(node.getChildRawDataCount(testDataSetId), 1, "After make relationship, getChildRawDataCount() should return 1");
        Assert.equal(node.getChildDataSetCount(testRawDataId), 1, "After make relationship, getChildDataSetCount() should return 1");

        // Delete Child
        Assert.equal(node.deleteRawData(testRawDataId), true, "deleteRawData() should return true");
        Assert.equal(node.getChildRawDataCount(testDataSetId), 0, "After delete child node, getChildRawDataCount() should return 0");
    }

    function testRedistribution() public {
        NodeRelationship node = new NodeRelationship();
        //  NodeRelationship deployed_node = NodeRelationship(DeployedAddresses.NodeRelationship());


        bytes32 extraRawDataId = "extra_test_raw_data_id";

        // Raw data creation
        node.createRawData(testRawDataId);
        Assert.equal(node.getRawDataCount(), 1, "After raw data creation, raw data length should return 1");

        node.createRawData(extraRawDataId);
        Assert.equal(node.getRawDataCount(), 2, "After extra raw data creation, raw data length should return 2");

        // Dataset creation
        node.createDataSet(testDataSetId);
        Assert.equal(node.getDataSetCount(), 1, "After dataset creation, data set length should return 1");


        node.makeRelation(testDataSetId, testRawDataId);

        // After relationship creation
        Assert.equal(node.getChildRawDataCount(testDataSetId), 1, "After make relationship, getChildRawDataCount() should return 1");
        Assert.equal(node.getChildDataSetCount(testRawDataId), 1, "After make relationship, getChildDataSetCount() should return 1");

        node.makeRelation(testDataSetId, extraRawDataId);

        // After relationship creation
        Assert.equal(node.getChildRawDataCount(testDataSetId), 2, "After make relationship with extra raw data, getChildRawDataCount() should return 2");
        Assert.equal(node.getChildDataSetCount(extraRawDataId), 1, "After make relationship, getChildDataSetCount() should return 1");


        // Make revenue to dataset
        node.addDataSetRevenue(testDataSetId, 100);

        Assert.equal(node.getRevenueOfDataSet(testDataSetId), 100, "After addDataSetRevenue(), balance should be increased");

        Assert.equal(node.viewRevenues(testRawDataId), 50, "Expected 50");
        Assert.equal(node.claimRevenues(testRawDataId), true, "Expected true");

        Assert.equal(node.viewRevenues(testRawDataId), 0, "Expected 0");
        Assert.equal(node.claimRevenues(testRawDataId), false, "Expected false");
    }
}
