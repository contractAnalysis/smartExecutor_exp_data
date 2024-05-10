pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;



contract Graph3 {
    
    event Node(
        string indexed _id,
        string indexed _class,
        string indexed _subclass
    );
    
    
    event Prop(
        string indexed _id,
        string indexed _prop,
        string indexed _value
    );
    
    
    event Link(
        string indexed _from,
        string indexed _to,
        string indexed _class
    );

    event Batch(
        uint256[] _events,
        string[3][] _args,
        bytes32[] _sig
    );
    
    
    function node(string memory _id, string memory _class, string memory _subclass) public {
        emit Node(_id, _class, _subclass);
    }
    
    
    function prop(string memory _id, string memory _prop, string memory _value) public {
        emit Prop(_id, _prop, _value);
    }
    
    
    function link(string memory _from, string memory _to, string memory _class) public {
        emit Link(_from, _to, _class);
    }
    
    
    function batch(uint256[] memory _events, string[3][] memory _args, bytes32[] memory _sig) public {
        emit Batch(_events, _args, _sig);
    }
}