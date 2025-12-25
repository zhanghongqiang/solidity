// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyToken{
    string public name;
    string public symbol;
    uint8 public decimal;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    address public owner;

    event Transfer(address indexed from,address indexed to, uint256 amount);

    event Approval(address indexed owner,address indexed spender,uint256 amount);

    modifier onlyOwner(){
        require(owner == msg.sender,"Only owner");
        _;
    }

    constructor(string memory _name,string memory _symbol,uint8 _decimal,uint256 _totalSupply){
        name = _name;
        symbol = _symbol;
        decimal = _decimal;
        totalSupply = _totalSupply * 10 ** _decimal;
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;

        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address to,uint256 amount) public returns(bool){
        require(to != address(0),"Insufficient address");
        require(balanceOf[msg.sender] >= amount,"Insufficient balance");

        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender,uint256 amount) public returns(bool){
        require(spender != address(0),"Insufficient address");
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender,amount);
        return true;
    }

    function transferFrom(address from,address to,uint256 amount) public returns(bool){
            require(from != address(0),"Insufficient address");
            require(to != address(0),"Insufficient address");
            require(balanceOf[from] >= amount,"Insufficient balance");
            require(allowance[from][msg.sender] >= amount,"Insufficient allowance");

            balanceOf[from] -= amount;
            balanceOf[to] += amount;
            allowance[from][msg.sender] -= amount;

            emit Transfer(from, to, amount);
            return true;
    }

    function mint(address to,uint256 amount) public onlyOwner{
        require(to != address(0),"Insufficient address");

        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function burn(uint256 amount) public{
        require(balanceOf[msg.sender] >= amount,"Insufficient balance");
        totalSupply -= amount;
        balanceOf[msg.sender] -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

}