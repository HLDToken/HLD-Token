pragma solidity ^0.4.24;

/**
名称：HLD Token
缩写：HLD
总量：10000亿
官网：https://www.hld.pw
HLD Token是基于HECO 火币生态链的去中心化数字资产，链上每笔转账交易都将自动销毁每笔交易的千分之一以进行通货紧缩。

*/

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}




contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}




contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}




contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}




contract HLD is ERC20Interface, Owned {
    using SafeMath for uint;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;




    constructor() public {
        symbol = "HLD";
        name = "HLD Token";
        decimals = 18;
        _totalSupply = 1000000000000 * 10**uint(decimals);
        balances[address(0x2cc50C691D1Bec9C564e80719C4130e34e4C256e)] = _totalSupply;
        emit Transfer(address(0), address(0x2cc50C691D1Bec9C564e80719C4130e34e4C256e), _totalSupply);
    }




    function totalSupply() public view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }




    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }




    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        uint toBlackHole = tokens.div(1000);
        address blackHole = 0x0000000000000000000000000000000000000000;
        balances[blackHole] = balances[blackHole].add(toBlackHole);
        balances[to] = balances[to].add(tokens.sub(toBlackHole));
        emit Transfer(msg.sender, blackHole, toBlackHole);
        emit Transfer(msg.sender, to, tokens.sub(toBlackHole));
        return true;
    }



    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }



    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        uint toBlackHole = tokens.div(1000);
        address blackHole = 0x0000000000000000000000000000000000000000;
        balances[blackHole] = balances[blackHole].add(toBlackHole);
        balances[to] = balances[to].add(tokens.sub(toBlackHole));
        emit Transfer(from, blackHole, toBlackHole);
        emit Transfer(from, to, tokens.sub(toBlackHole));
        return true;
    }




    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }




    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }



    function () public payable {
        revert();
    }



    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}