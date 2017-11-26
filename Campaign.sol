pragma solidity ^0.4.6;


contract Campaign {
    address public owner;

    uint    public deadline;

    uint    public goal;

    uint    public fundsRaised;

    // Funder object. Each of the funder will have thier address and amount
    struct FundersStruct {
    address funder;
    uint amount;
    }
    // All the funders list
    FundersStruct[] public funderStructs;
    /**
    * Creating Events
    */
    event LogContribution(address sender, uint amount);
    event LogRefundSent(address funder, uint amount);
    event LogWithdrawal(address beneficiary, uint amount);

    /**
    * constructor
    */
    function Campaign(uint duration, uint lgoal) public{
        owner = msg.sender;
        deadline = block.number + duration;
        goal = lgoal;
    }

    // constant function executes locally, it wont run on block chain
    function isSuccess()
    public
    constant
    returns (bool isIndeed){
        return (fundsRaised >= goal);

    }

    function hasFailed()
    public
    constant
    returns (bool hasIndeed){
        return (fundsRaised < goal && block.number > deadline);
    }

    // payable--> it accepts wei
    //memory tells solidity to create a chunk of space for the variable at method runtime, guaranteeing its size and structure for future use in that method.
    function contribute()
    public
    payable
    returns (bool success){
        require(msg.value != 0);
        fundsRaised += msg.value;
        FundersStruct memory newFunder;
        newFunder.funder = msg.sender;
        newFunder.amount = msg.value;
        funderStructs.push(newFunder);
        LogContribution(msg.sender,msg.value);
        return true;

    }

    function withdrawFunds()
    public
    returns (bool success){
        require(msg.sender == owner) ;
        require(isSuccess());
        // todo: check the Campaign
        // balance is a property of fund stored in the contract
        uint amount = this.balance;
        // send to the owner
        require(owner.send(amount));
        LogWithdrawal(owner,this.balance);
        return true;

    }

    function sendRefunds()
    public
    returns (bool success){
        require(hasFailed());
        require(msg.sender == owner);
        uint funderCount = funderStructs.length;
        for (uint i = 0; i < funderCount; i++) {
            require(funderStructs[i].funder.send(funderStructs[i].amount));
            LogRefundSent(funderStructs[i].funder,funderStructs[i].amount);
        }
        return true;
    }
}