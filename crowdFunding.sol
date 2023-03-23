//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;
contract CF{
    mapping (address=>uint) public  contributors;
    uint  public  minCon;
    uint public deadline;
    uint public target;
    uint public raisedAmt;
    uint public noOfCon;
    address public manager;

    struct Request{
        string desc;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool)voters;
    }
   mapping(uint=>Request)public requests;
   uint public numRequests;
    constructor(uint _target,uint _deadline){
     target=_target;
     deadline=block.timestamp+_deadline;
     minCon=100 wei;
     manager=msg.sender;
    }

    function sendEth() public payable{
    require(block.timestamp < deadline,"time exceeded");
    require(msg.value>=minCon ,"not even reached minimum comtribution");
    if(contributors[msg.sender]==0){
    noOfCon++;
    }
    contributors[msg.sender]=contributors[msg.sender]+msg.value;
    raisedAmt+=msg.value;
    }
    
    function  getBal()public view returns(uint){
     return address(this).balance;
    }
  
     function refund() public {
         require(block.timestamp>deadline,"You are not eligible");
         require(contributors[msg.sender]>0);
         address payable user=payable(msg.sender);
         user.transfer(contributors[msg.sender]);
         contributors[msg.sender]=0;
     }
   
     modifier onlyMan(){
         require(msg.sender==manager,"only manager can call");
         _;
     }
   
    function createRequests(string memory _desc,address payable _rec,uint _value)public onlyMan{
    Request storage newReq=requests[numRequests];
    numRequests++;
    newReq.desc=_desc;
    newReq.recipient=_rec;
    newReq.value=_value;
    newReq.completed=false;
    newReq.noOfVoters=0;
    }

    function voteReq(uint _reqNo)public {
    require(contributors[msg.sender]>0,"You must be a contributor");
    Request storage thisReq=requests[_reqNo];
    require(thisReq.voters[msg.sender]==false,"already voted");
    thisReq.voters[msg.sender]=true;
    thisReq.noOfVoters++;
    }

   function makePayment(uint _reqNo)public onlyMan{
    require(raisedAmt>=target);
    Request storage thisReq=requests[_reqNo];
    require(thisReq.completed==false);
    require(thisReq.noOfVoters>noOfCon/2);
    thisReq.recipient.transfer(thisReq.value);
    thisReq.completed=true;
   }

}
