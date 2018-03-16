// Reference
// https://medium.com/@robhitchens/enforcing-referential-integrity-in-ethereum-smart-contracts-a9ab1427ff42

pragma solidity ^0.4.19;


contract NodeRelationship {
    // Admin stuff

    address public owner;

    // For manage account and balance
    mapping(address => uint) account;

    function myBalance() public view returns (uint) {
        return account[msg.sender];
    }


    function NodeRelationship() public {// constructor
        owner = msg.sender;
    }

    // Dataset struct
    struct DataSet {
        address owner;
        uint DataSetPointer;
        bytes32[] rawDataIds;
        mapping(bytes32 => uint) rawDataIdPointers;

        uint revenue;
    }

    mapping(bytes32 => DataSet) public dataSetStructs;
    bytes32[] public dataSetList;

    // Raw data struct
    struct RawData {
        address owner;
        uint rawDataListPointer;
        bytes32[] dataSetIds;
        mapping(bytes32 => uint) dataSetIdPointers;

        // distribution
        uint revenue;
        mapping(bytes32 => uint) withdrawn;
    }

    mapping(bytes32 => RawData) public rawDataStructs;
    bytes32[] public rawDataList;

    // Event
    event LogNewDataSet(address sender, bytes32 dataSetId);
    event LogNewRawData(address sender, bytes32 rawDataId);
    event LogDataSetDeleted(address sender, bytes32 dataSetId);
    event LogRawDataDeleted(address sender, bytes32 rawDataId);
    event LogDataSetRelationshipDeleted(address sender, bytes32 dataSetId, bytes32 rawDataId);
    event LogRawDataRelationshipDeleted(address sender, bytes32 rawDataId, bytes32 dataSetId);


    function getRevenueOfDataSet(bytes32 dataSetId) external view returns (uint) {return dataSetStructs[dataSetId].revenue;}

    function getRevenueOfRawData(bytes32 rawDataId) external view returns (uint) {return rawDataStructs[rawDataId].revenue;}


    function getDataSetCount() public view returns (uint) {return dataSetList.length;}

    function getRawDataCount() public view returns (uint) {return rawDataList.length;}

    function isDataSet(bytes32 dataSetId) public view returns (bool isIndeed) {
        if (dataSetList.length == 0) return false;
        return dataSetList[dataSetStructs[dataSetId].DataSetPointer] == dataSetId;
    }

    function isRawData(bytes32 rawDataId) public view returns (bool isIndeed) {
        if (rawDataList.length == 0) return false;
        return rawDataList[rawDataStructs[rawDataId].rawDataListPointer] == rawDataId;
    }

    function getOwnerOfDataSet(bytes32 dataSetId) public view returns (address) {
        require(isDataSet(dataSetId));
        return dataSetStructs[dataSetId].owner;
    }

    function getOwnerOfRawData(bytes32 rawDataId) public view returns (address) {
        require(isRawData(rawDataId));
        return rawDataStructs[rawDataId].owner;
    }


    function getChildRawDataCount(bytes32 dataSetId) public view returns (uint rawDataCount) {
        require(isDataSet(dataSetId));
        return dataSetStructs[dataSetId].rawDataIds.length;
    }

    function getChildDataSetCount(bytes32 rawDataId) public view returns (uint dataSetCount) {
        require(isRawData(rawDataId));
        return rawDataStructs[rawDataId].dataSetIds.length;
    }

    // Insert

    function createDataSet(bytes32 dataSetId) public returns (bool success) {
        require(!isDataSet(dataSetId));
        dataSetStructs[dataSetId].owner = msg.sender;
        dataSetStructs[dataSetId].DataSetPointer = dataSetList.push(dataSetId) - 1;
        LogNewDataSet(msg.sender, dataSetId);
        return true;
    }

    function createRawData(bytes32 rawDataId) public returns (bool success) {
        require(!isRawData(rawDataId));
        rawDataStructs[rawDataId].owner = msg.sender;
        rawDataStructs[rawDataId].rawDataListPointer = rawDataList.push(rawDataId) - 1;
        LogNewRawData(msg.sender, rawDataId);
        return true;

        // How to make relationship
        // rawDataStructs[rawDataId].dataSetId = dataSetId;
        // dataSetStructs[dataSetId].rawDataIdPointers[rawDataId] = dataSetStructs[dataSetId].rawDataIds.push(rawDataId) - 1;
    }

    function makeRelation(bytes32 dataSetId, bytes32 rawDataId) public returns (bool success) {
        // Add relationship between raw data and dataset
        require(isDataSet(dataSetId));
        require(isRawData(rawDataId));

        rawDataStructs[rawDataId].dataSetIdPointers[dataSetId] = rawDataStructs[rawDataId].dataSetIds.push(dataSetId) - 1;
        dataSetStructs[dataSetId].rawDataIdPointers[rawDataId] = dataSetStructs[dataSetId].rawDataIds.push(rawDataId) - 1;
        return true;
    }

    // Delete

    function deleteDataSet(bytes32 dataSetId) public returns (bool success) {
        require(isDataSet(dataSetId));

        uint rowToDelete = dataSetStructs[dataSetId].DataSetPointer;
        bytes32 keyToMove = dataSetList[dataSetList.length - 1];

        dataSetList[rowToDelete] = keyToMove;
        dataSetStructs[keyToMove].DataSetPointer = rowToDelete;
        dataSetList.length--;


        bytes32[] memory rawDataIds = dataSetStructs[dataSetId].rawDataIds;

        // TODO: Should be refac. Too much gas consumption.
        for (uint i = 0; i < rawDataIds.length; i++) {
            bytes32 iterRawDataId = rawDataIds[i];

            rowToDelete = rawDataStructs[iterRawDataId].dataSetIdPointers[dataSetId];

            // Temporary point for rawDataIds
            bytes32[] memory dataSetIds = rawDataStructs[iterRawDataId].dataSetIds;
            keyToMove = dataSetIds[dataSetIds.length - 1];

            rawDataStructs[iterRawDataId].dataSetIds[rowToDelete] = keyToMove;
            rawDataStructs[iterRawDataId].dataSetIdPointers[keyToMove] = rowToDelete;
            rawDataStructs[iterRawDataId].dataSetIds.length--;

            LogDataSetRelationshipDeleted(msg.sender, dataSetId, iterRawDataId);
        }

        LogDataSetDeleted(msg.sender, dataSetId);
        return true;
    }

    function deleteRawData(bytes32 rawDataId) public returns (bool success) {
        require(isRawData(rawDataId));

        uint rowToDelete = rawDataStructs[rawDataId].rawDataListPointer;
        bytes32 keyToMove = rawDataList[rawDataList.length - 1];
        rawDataList[rowToDelete] = keyToMove;
        rawDataStructs[rawDataId].rawDataListPointer = rowToDelete;
        rawDataList.length--;

        bytes32[] memory dataSetIds = rawDataStructs[rawDataId].dataSetIds;

        // TODO: Should be refac. Too much gas consumption.
        for (uint i = 0; i < dataSetIds.length; i++) {
            bytes32 iterDataSetId = dataSetIds[i];
            rowToDelete = dataSetStructs[iterDataSetId].rawDataIdPointers[rawDataId];

            // Temporary point for rawDataIds
            bytes32[] memory rawDataIds = dataSetStructs[iterDataSetId].rawDataIds;
            keyToMove = rawDataIds[rawDataIds.length - 1];

            dataSetStructs[iterDataSetId].rawDataIds[rowToDelete] = keyToMove;
            dataSetStructs[iterDataSetId].rawDataIdPointers[keyToMove] = rowToDelete;
            dataSetStructs[iterDataSetId].rawDataIds.length--;

            LogRawDataRelationshipDeleted(msg.sender, rawDataId, iterDataSetId);
        }

        LogRawDataDeleted(msg.sender, rawDataId);

        return true;
    }


    // Functions for distribution
    function addDataSetRevenue(bytes32 dataSetId, uint amount) public returns (bool) {
        require(isDataSet(dataSetId));
        dataSetStructs[dataSetId].revenue += amount;

        return true;
    }

    function claimRevenues(bytes32 rawDataId) public returns (bool isUpdated) {
        // returns true or false depending on whether balance has been updated

        require(isRawData(rawDataId) && rawDataStructs[rawDataId].owner == msg.sender);

        RawData storage data = rawDataStructs[rawDataId];
        uint beforeBalance = account[data.owner];
        uint sumAmount;

        for (uint i = 0; i < data.dataSetIds.length; i++) {
            // Temporary save dataset id
            bytes32 dsId = data.dataSetIds[i];

            sumAmount = (dataSetStructs[dsId].revenue / getChildRawDataCount(dsId) - data.withdrawn[dsId]);

            account[data.owner] += sumAmount;
            data.withdrawn[dsId] += sumAmount;
        }
        return !(beforeBalance == account[data.owner]);
    }

    function viewRevenues(bytes32 rawDataId) public view returns (uint) {
        require(isRawData(rawDataId) && rawDataStructs[rawDataId].owner == msg.sender);

        RawData storage data = rawDataStructs[rawDataId];
        uint sumAmount;

        for (uint i = 0; i < data.dataSetIds.length; i++) {
            // Temporary save dataset id
            bytes32 dsId = data.dataSetIds[i];

            sumAmount += (dataSetStructs[dsId].revenue / getChildRawDataCount(dsId) - data.withdrawn[dsId]);
        }
        return sumAmount;
    }

    function claimRevenue(bytes32 rawDataId, bytes32 dataSetId) public returns (bool isUpdated) {
        // returns true or false depending on whether balance has been updated

        require(isRawData(rawDataId) && rawDataStructs[rawDataId].owner == msg.sender);

        RawData storage data = rawDataStructs[rawDataId];
        uint beforeBalance = account[data.owner];
        uint sumAmount;

        sumAmount = (dataSetStructs[dataSetId].revenue / getChildRawDataCount(dataSetId) - data.withdrawn[dataSetId]);
        account[data.owner] += sumAmount;
        data.withdrawn[dataSetId] += sumAmount;

        return !(beforeBalance == account[data.owner]);
    }

    function viewRevenue(bytes32 rawDataId, bytes32 dataSetId) public view returns (uint) {
        require(isRawData(rawDataId) && rawDataStructs[rawDataId].owner == msg.sender);

        return (dataSetStructs[dataSetId].revenue / getChildRawDataCount(dataSetId) - rawDataStructs[rawDataId].withdrawn[dataSetId]);
    }
}