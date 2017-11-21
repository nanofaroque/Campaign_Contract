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
    * @constructor
    */
    function Campaign(uint duration, uint lgoal){
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
            if (msg.value == 0) throw;
            fundsRaised += msg.value;
            FundersStruct memory newFunder;
            newFunder.funder = msg.sender;
            newFunder.amount = msg.value;
            funderStructs.push(newFunder);
        return true;

    }

    function withdrawFunds()
        public
        returns (bool success){
            if (msg.sender != owner) {
                throw;
            }
            if (!isSuccess()) throw;
            // todo: check the Campaign
            // balance is a property of fund stored in the contract
            uint amount = this.balance;
            // send to the owner
            owner.send(amount);
        return true;

    }

    function sendRefunds()
        public
        returns (bool success){
            if (!hasFailed()) throw;
            if (msg.sender != owner) throw;
            uint funderCount = funderStructs.length;
            for (uint i = 0; i < funderCount; i++) {
                funderStructs[i].funder.send(funderStructs[i].amount);
            }
        return true;
    }
}