// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

contract DudleTokenRVVoteAddNewOwners {
  string public constant name = "DudleTokenRV";
    string public constant symbol = "DTV";
    uint8 public constant decimals = 18;
    uint256 public startTime = block.timestamp + 5 minutes;
    uint256 public totalSupply;
    address[] public owners;
    
    struct vote {
        address voterAddress;
        bool choice;
    }
    
    struct voter {
        string voterName;
        bool voted;
    }
    
    mapping (address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping(address => bool) ownership;
    mapping(uint256 => vote) private votes;
    mapping(address => voter) public voterRegister;
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _from, address indexed _to, uint256 _value);
    event Burned(address indexed _from ,uint256 _amount);
    
    uint256 private countResult = 0;
    uint256 public finalResult = 0;
    uint256 public totalVoter = 0;
    uint256 public totalVote = 0;
    
    address public ballotOfficialAddress;      
    
    enum State { Created, Voting, Ended }
    State public state;
    
    constructor () public {
        ballotOfficialAddress = msg.sender;
        ownership[msg.sender] = true;
        owners.push(msg.sender);
        state = State.Created;
    }
    
    function mint (address _to, uint256 _value) public {
        require(totalSupply + _value >= totalSupply && balances[_to] + _value >= balances[_to]);
        balances[_to] += _value;
        totalSupply += _value;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }
    
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
    
    function transfer(address _to, uint256 _value) public {
        require(balances[msg.sender] >= _value && balances[_to] + _value >= balances[_to] && _value > 0);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
    }
    
    function transferFrom (address _from, address _to, uint256 _value) public {
        require(balances[_from] >= _value && balances[_to] + _value >= balances[_to] && allowed[_from][msg.sender] >= _value && _value > 0);
        balances[_from] -= _value;
        balances[_to] += _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
    }
    
    function approve (address _spender, uint256 _value) public {
        require(_value > 0);
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
    }
    
    function burn(uint256 _value) public {
    	require(balances[msg.sender] >= _value && _value > 0);
    	if (block.timestamp > startTime) {
    	   balances[msg.sender] -= _value;
    	   totalSupply -= _value;
    	   Burned(msg.sender ,_value);
    	}
    }
    
    function addVoter(address _voterAddress, string memory _voterName)
        public
        inState(State.Created)
        onlyOfficial
        onlyOwners
    {
        voter memory vtr;
        vtr.voterName = _voterName;
        vtr.voted = false;
        voterRegister[_voterAddress] = vtr;
        totalVoter++;
    }
    
    modifier inState(State _state) {
        require(state == _state);
        _;
    }
    
    modifier onlyOfficial() {
        require(msg.sender == ballotOfficialAddress);
        _;
    }
    
    modifier onlyOwners() {
        require(ownership[msg.sender] == true);
        _;
    }
    
    function startVote()
        public
        inState(State.Created)
        onlyOfficial
    {
        state = State.Voting;
    }
    
    function doVote(bool _choice)
        public
        inState(State.Voting)
        onlyOwners
        returns (bool voted)
    {
        bool found;
        
        if (bytes(voterRegister[msg.sender].voterName).length != 0 
        && !voterRegister[msg.sender].voted){
            voterRegister[msg.sender].voted = true;
            vote memory vt;
            vt.voterAddress = msg.sender;
            vt.choice = _choice;
            if (_choice){
                countResult++;
            }
            votes[totalVote] = vt;
            totalVote++;
            found = true;
        }
        return found;
    }
    
    function endVote()
        public
        inState(State.Voting)
        onlyOfficial
    {
        state = State.Ended;
        finalResult = countResult;
    }
    
    function addNewOwners (address _newOwner) public onlyOwners {
        if (finalResult % 2 == 0) {
            require(finalResult == totalVoter || finalResult % totalVoter > totalVoter / 2);
        } else {
            require(finalResult == totalVoter || finalResult % totalVoter >= (totalVoter+1) / 2);
        }
        bool noMatches;
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] != _newOwner && i == owners.length - 1) {
                noMatches = true;
            }
        }
        if (noMatches) {
            owners.push(_newOwner);
            ownership[_newOwner] = true;
            noMatches = false;
        }
        
        state = State.Created;
    }
    function showOwners()public view returns(uint256) {
        return owners.length; 
    }
}
