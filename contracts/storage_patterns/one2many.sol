pragma solidity ^0.4.6;

// One-to-Many refential integrity maintenance and enforcement
// DOC: https://medium.com/@robhitchens/enforcing-referential-integrity-in-ethereum-smart-contracts-a9ab1427ff42

contract Owned {
    address public owner;
    modifier onlyOwner {if(msg.sender != owner) throw;_;}
    function Owned() {owner=msg.sender;}
}

contract OneToMany is Owned {

    // first entity is called a "One"

    struct OneStruct {
        // needed to delete a "One"
        uint oneListPointer;
        // One has many "Many"
        bytes32[] manyIds;
        mapping(bytes32 => uint) manyIdPointers;
        // more app data
    }

    mapping(bytes32 => DataSet) public oneStructs;
    bytes32[] public oneList;

    // other entity is called a "Many"

    struct ManyStruct {
        // needed to delete a "Many"
        uint manyListPointer;
        // many has exactly one "One"
        bytes32 oneId;
        // add app fields
    }

    mapping(bytes32 => ManyStruct) public manyStructs;
    bytes32[] public manyList;

    event LogNewOne(address sender, bytes32 oneId);
    event LogNewMany(address sender, bytes32 manyId, bytes32 oneId);
    event LogOneDeleted(address sender, bytes32 oneId);
    event LogManyDeleted(address sender, bytes32 manyId);

    function getOneCount()  public constant returns(uint oneCount) {return oneList.length;}
    function getManyCount() public constant returns(uint manyCount){return manyList.length;}

    function isOne(bytes32 oneId) public constant returns(bool isIndeed) {
        if(oneList.length==0) return false;
        return oneList[oneStructs[oneId].DataSetPointer]==oneId;
    }

    function isMany(bytes32 manyId) public constant returns(bool isIndeed) {
        if(manyList.length==0) return false;
        return manyList[manyStructs[manyId].manyListPointer]==manyId;
    }

    // Iterate over a One's Many keys

    function getOneManyIdCount(bytes32 oneId) public constant returns(uint manyCount) {
        if(!isOne(oneId)) throw;
        return oneStructs[oneId].manyIds.length;
    }

    function getOneManyIdAtIndex(bytes32 oneId, uint row) public constant returns(bytes32 manyKey) {
        if(!isOne(oneId)) throw;
        return oneStructs[oneId].manyIds[row];
    }

    // Insert

    function createOne(bytes32 oneId) onlyOwner returns(bool success) {
        if(isOne(oneId)) throw; // duplicate key prohibited
        oneStructs[oneId].DataSetPointer = oneList.push(oneId)-1;
        LogNewOne(msg.sender, oneId);
        return true;
    }

    function createMany(bytes32 manyId, bytes32 oneId) onlyOwner returns(bool success) {
        if(!isOne(oneId)) throw;
        if(isMany(manyId)) throw; // duplicate key prohibited
        manyStructs[manyId].manyListPointer = manyList.push(manyId)-1;
        manyStructs[manyId].oneId = oneId; // each many has exactly one "One", so this is mandatory
        // We also maintain a list of "Many" that refer to the "One", so ...
        oneStructs[oneId].manyIdPointers[manyId] = oneStructs[oneId].manyIds.push(manyId) - 1;
        LogNewMany(msg.sender, manyId, oneId);
        return true;
    }

    // Delete

    function deleteOne(bytes32 oneId) onlyOwner returns(bool succes) {
        if(!isOne(oneId)) throw;
        if(oneStructs[oneId].manyIds.length>0) throw; // this would break referential integrity
        uint rowToDelete = oneStructs[oneId].DataSetPointer;
        bytes32 keyToMove = oneList[oneList.length-1];
        oneList[rowToDelete] = keyToMove;
        oneStructs[keyToMove].DataSetPointer = rowToDelete;
        oneList.length--;
        LogOneDeleted(msg.sender, oneId);
        return true;
    }

    function deleteMany(bytes32 manyId) onlyOwner returns(bool success) {
        if(!isMany(manyId)) throw; // non-existant key

        // delete from the Many table
        uint rowToDelete = manyStructs[manyId].manyListPointer;
        bytes32 keyToMove = manyList[manyList.length-1];
        manyList[rowToDelete] = keyToMove;
        manyStructs[manyId].manyListPointer = rowToDelete;
        manyList.length--;

        // we ALSO have to delete this key from the list in the ONE that was joined to this Many
        bytes32 oneId = manyStructs[manyId].oneId; // it's still there, just not dropped from index
        rowToDelete = oneStructs[oneId].manyIdPointers[manyId];
        keyToMove = oneStructs[oneId].manyIds[oneStructs[oneId].manyIds.length-1];
        oneStructs[oneId].manyIds[rowToDelete] = keyToMove;
        oneStructs[oneId].manyIdPointers[keyToMove] = rowToDelete;
        oneStructs[oneId].manyIds.length--;
        LogManyDeleted(msg.sender, manyId);
        return true;
    }

}

