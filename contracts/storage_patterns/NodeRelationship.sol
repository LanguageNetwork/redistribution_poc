// Reference
// https://medium.com/@robhitchens/enforcing-referential-integrity-in-ethereum-smart-contracts-a9ab1427ff42

// TODO: translate comment to English

pragma solidity ^0.4.19;


contract NodeRelationship {
    // Admin stuff

    address public owner;

    function NodeRelationship() public {// constructor
        owner = msg.sender;
    }

    // For zero_state comparison
    bytes32 zero_state;


    // Dataset struct
    struct DataSet {
        uint DataSetPointer;
        bytes32[] rawDataIds;
        mapping(bytes32 => uint) rawDataIdPointers;
    }

    mapping(bytes32 => DataSet) public dataSetStructs;
    bytes32[] public dataSetList;


    // Raw data struct
    struct RawData {
        uint rawDataListPointer;
        bytes32[] dataSetIds;
        mapping(bytes32 => uint) dataSetIdPointers;
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


    function getDataSetCount() public view returns (uint dataSetCount) {return dataSetList.length;}

    function getRawDataCount() public view returns (uint rawDataCount){return rawDataList.length;}

    function isDataSet(bytes32 dataSetId) public view returns (bool isIndeed) {
        if (dataSetList.length == 0) return false;
        return dataSetList[dataSetStructs[dataSetId].DataSetPointer] == dataSetId;
    }

    function isRawData(bytes32 rawDataId) public view returns (bool isIndeed) {
        if (rawDataList.length == 0) return false;
        return rawDataList[rawDataStructs[rawDataId].rawDataListPointer] == rawDataId;
    }


    function getDataSetRawDataIdCount(bytes32 dataSetId) public view returns (uint rawDataCount) {
        require(isDataSet(dataSetId));
        return dataSetStructs[dataSetId].rawDataIds.length;
    }

    function getRawDataDataSetIdCount(bytes32 rawDataId) public view returns (uint dataSetCount) {
        require(isRawData(rawDataId));
        return rawDataStructs[rawDataId].dataSetIds.length;
    }

    // Insert

    function createDataSet(bytes32 dataSetId) public returns (bool success) {
        require(!isDataSet(dataSetId));
        dataSetStructs[dataSetId].DataSetPointer = dataSetList.push(dataSetId) - 1;
        LogNewDataSet(msg.sender, dataSetId);
        return true;
    }

    function createRawData(bytes32 rawDataId) public returns (bool success) {
        require(!isRawData(rawDataId));
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
        require(!(dataSetStructs[dataSetId].rawDataIds.length > 0));
        // 남은 relationship 이 있을 경우 revert

        uint rowToDelete = dataSetStructs[dataSetId].DataSetPointer;
        // DataSet list 의 포인터. dataset struct 들어있음
        bytes32 keyToMove = dataSetList[dataSetList.length - 1];
        // 가장 마지막 dataset struct
        dataSetList[rowToDelete] = keyToMove;
        // 삭제하고 싶은 raw 의 데이터를 가장 마지막 struct 로 덮어씀
        dataSetStructs[keyToMove].DataSetPointer = rowToDelete;
        // 가장 마지막 struct 의 포인터를 덮여진 위치로 덮어씀
        dataSetList.length--;
        // datasetList 길이를 1만큼 감소시킴


        bytes32[] rawDataIds = dataSetStructs[dataSetId].rawDataIds;

        // TODO: Should be refac. Too much gas consumption.
        for (uint i = 0; i < rawDataIds.length; i++) {
            bytes32 iterRawDataId = rawDataIds[i];

            rowToDelete = rawDataStructs[iterRawDataId].dataSetIdPointers[dataSetId];

            // Temporary point for rawDataIds
            bytes32[] dataSetIds = rawDataStructs[iterRawDataId].dataSetIds;
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
        require(!(rawDataStructs[rawDataId].dataSetIds.length > 0));
        // 남은 relationship 이 있을 경우 revert

        uint rowToDelete = rawDataStructs[rawDataId].rawDataListPointer;
        // Raw Data list 의 포인터. raw data struct 들어있음
        bytes32 keyToMove = rawDataList[rawDataList.length - 1];
        // 가장 마지막 raw data struct
        rawDataList[rowToDelete] = keyToMove;
        // struct 덮어쓰기
        rawDataStructs[rawDataId].rawDataListPointer = rowToDelete;
        // 포인터 덮어쓰기
        rawDataList.length--;
        // 마지막 element 삭제

        // raw data struct 에서 데이터셋 아이디 리스트 가져옴
        bytes32[] dataSetIds = rawDataStructs[rawDataId].dataSetIds;

        // TODO: Should be refac. Too much gas consumption.
        for (uint i = 0; i < dataSetIds.length; i++) {
            bytes32 iterDataSetId = dataSetIds[i];
            // dataset struct 에서 지울 raw data 의 id pointer 가져옴
            rowToDelete = dataSetStructs[iterDataSetId].rawDataIdPointers[rawDataId];

            // Temporary point for rawDataIds
            bytes32[] rawDataIds = dataSetStructs[iterDataSetId].rawDataIds;
            keyToMove = rawDataIds[rawDataIds.length - 1];

            dataSetStructs[iterDataSetId].rawDataIds[rowToDelete] = keyToMove;
            dataSetStructs[iterDataSetId].rawDataIdPointers[keyToMove] = rowToDelete;
            dataSetStructs[iterDataSetId].rawDataIds.length--;

            LogRawDataRelationshipDeleted(msg.sender, rawDataId, iterDataSetId);
        }

        LogRawDataDeleted(msg.sender, rawDataId);

        return true;
    }

}

