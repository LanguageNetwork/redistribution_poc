// Reference
// https://medium.com/@robhitchens/enforcing-referential-integrity-in-ethereum-smart-contracts-a9ab1427ff42

pragma solidity ^0.4.11;


contract Owned {
    address public owner;
    modifier onlyOwner {require(msg.sender == owner);_;}
    function Owned() internal {owner=msg.sender;}
}

contract NodeRelationship is Owned {

    // Dataset struct
    struct DataSet {
        uint DataSetPointer;
        bytes32[] rawDataIds;
        mapping(bytes32 => uint) rawDataIdPointers;
    }

    mapping(bytes32 => DataSet) public dataSetStructs;
    bytes32[] public dataSetList;


    // Raw data struct
    struct RawDataStruct {
        uint rawDataListPointer;
        bytes32 dataSetId;
        mapping(bytes32 => uint) dataSetIdPointers;
    }

    mapping(bytes32 => RawDataStruct) public rawDataStructs;
    bytes32[] public rawDataList;

    // Log & DApp
    event LogNewDataSet(address sender, bytes32 dataSetId);
    event LogNewRawData(address sender, bytes32 rawDataId, bytes32 dataSetId);
    event LogDataSetDeleted(address sender, bytes32 dataSetId);
    event LogRawDataDeleted(address sender, bytes32 rawDataId);

    function getDataSetCount()  public constant returns(uint dataSetCount) {return dataSetList.length;}
    function getRawDataCount() public constant returns(uint rawDataCount){return rawDataList.length;}

    function isDataSet(bytes32 dataSetId) public view returns(bool isIndeed) {
        if(dataSetList.length==0) return false;
        return dataSetList[dataSetStructs[dataSetId].DataSetPointer]==dataSetId;
    }

    function isRawData(bytes32 rawDataId) public view returns(bool isIndeed) {
        if(rawDataList.length==0) return false;
        return rawDataList[rawDataStructs[rawDataId].rawDataListPointer]==rawDataId;
    }


    function getDataSetRawDataIdCount(bytes32 dataSetId) public constant returns(uint rawDataCount) {
        require(isDataSet(dataSetId));
        return dataSetStructs[dataSetId].rawDataIds.length;
    }

    function getDataSetRawDataIdAtIndex(bytes32 dataSetId, uint row) public constant returns(bytes32 rawDataKey) {
        require(isDataSet(dataSetId));
        return dataSetStructs[dataSetId].rawDataIds[row];
    }

    // Insert

    function createDataSet(bytes32 dataSetId) public returns(bool success) {
        require(isDataSet(dataSetId));
        dataSetStructs[dataSetId].DataSetPointer = dataSetList.push(dataSetId)-1;
        emit LogNewDataSet(msg.sender, dataSetId);
        return true;
    }

    function createRawData(bytes32 rawDataId, bytes32 dataSetId) public returns(bool success) {
        require(isDataSet(dataSetId));
        require(!isRawData(rawDataId));

        rawDataStructs[rawDataId].rawDataListPointer = rawDataList.push(rawDataId)-1;
        rawDataStructs[rawDataId].dataSetId = dataSetId;
        dataSetStructs[dataSetId].rawDataIdPointers[rawDataId] = dataSetStructs[dataSetId].rawDataIds.push(rawDataId) - 1;
        emit LogNewRawData(msg.sender, rawDataId, dataSetId);
        return true;
    }

    // Delete

    function deleteDataSet(bytes32 dataSetId) public returns(bool succes) {
        require(isDataSet(dataSetId));
        require(!(dataSetStructs[dataSetId].rawDataIds.length>0));

        uint rowToDelete = dataSetStructs[dataSetId].DataSetPointer;
        bytes32 keyToMove = dataSetList[dataSetList.length-1];
        dataSetList[rowToDelete] = keyToMove;
        dataSetStructs[keyToMove].DataSetPointer = rowToDelete;
        dataSetList.length--;
        emit LogDataSetDeleted(msg.sender, dataSetId);
        return true;
    }

    function deleteRawData(bytes32 rawDataId) public returns(bool success) {
        require(isRawData(rawDataId));

        // delete from the RawData table
        uint rowToDelete = rawDataStructs[rawDataId].rawDataListPointer;
        bytes32 keyToMove = rawDataList[rawDataList.length-1];
        rawDataList[rowToDelete] = keyToMove;
        rawDataStructs[rawDataId].rawDataListPointer = rowToDelete;
        rawDataList.length--;

        // we ALSO have to delete this key from the list in the ONE that was joined to this RawData
        bytes32 dataSetId = rawDataStructs[rawDataId].dataSetId; // it's still there, just not dropped from index
        rowToDelete = dataSetStructs[dataSetId].rawDataIdPointers[rawDataId];
        keyToMove = dataSetStructs[dataSetId].rawDataIds[dataSetStructs[dataSetId].rawDataIds.length-1];
        dataSetStructs[dataSetId].rawDataIds[rowToDelete] = keyToMove;
        dataSetStructs[dataSetId].rawDataIdPointers[keyToMove] = rowToDelete;
        dataSetStructs[dataSetId].rawDataIds.length--;
        emit LogRawDataDeleted(msg.sender, rawDataId);
        return true;
    }

}

