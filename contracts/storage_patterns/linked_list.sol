contract LinkedList {

  event AddEntry(bytes32 head,uint number,bytes32 name,bytes32 next);

  uint public length = 0;  //also used as nonce

  struct Object{
    bytes32 next;
    uint number;
    bytes32 name;
  }

  bytes32 public head;
  mapping (bytes32 => Object) public objects;

  function LinkedList(){}

  function addEntry(uint _number,bytes32 _name) public returns (bool){
    Object memory object = Object(head,_number,_name);
    bytes32 id = sha3(object.number,object.name,now,length);
    objects[id] = object;
    head = id;
    length = length+1;
    AddEntry(head,object.number,object.name,object.next);
  }

  //needed for external contract access to struct
  function getEntry(bytes32 _id) public returns (bytes32,uint,bytes32){
    return (objects[_id].next,objects[_id].number,objects[_id].name);
  }


  //------------------ totalling stuff to explore list mechanics

  function total() public constant returns (uint) {
    bytes32 current = head;
    uint totalCount = 0;
    while( current != 0 ){
      totalCount = totalCount + objects[current].number;
      current = objects[current].next;
    }
    return totalCount;
  }

  function setTotal() public returns (bool) {
    writtenTotal = total();
    return true;
  }

  function resetTotal() public returns (bool) {
    writtenTotal = 0;
    return true;
  }

  uint public writtenTotal;

}