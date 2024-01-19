// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

// To use the following imports:
// In your truffle project folder, open a terminal and type:
// $ npm install @openzeppelin/contracts
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Ejercicio3 is ERC20, Ownable {
    
    bytes32 private _proseHash;
    uint256 private _userTokens;
    
    uint256 private _inTime;
    uint256 private _configTime;
    uint256 private _tradeLocker;
    uint256 private _configLocker;

    address payable _owner;
    uint256 private _initialSupply;
    string private _name;
    string private _symbol;

    mapping (address => bool) private acceptedConditions;
    
    struct Article {
        uint256 id;
        uint256 price;
        address creator;
        address owner;
        State status;
    }
    
    enum State {None, OnSale, Sold}
    uint256 private _totalArticles;
    mapping (uint => Article) public articles;
        
    // modifier inTime()
    modifier inTime() {
        require((block.timestamp - _tradeLocker) < _inTime);
        _;
    }
    
    // modifier inConfigTime()
    modifier inConfigTime() {
        require((block.timestamp - _configLocker) < _configTime);
        _;
    }
    
    constructor(string memory name, string memory symbol, uint256 initialSupply, bytes32 proseHash, uint256 userTokens, uint256 inTimeValue, uint256 configTimeValue)
        ERC20(name, symbol) {
            _proseHash = proseHash;
            _userTokens = userTokens;
            _inTime = inTimeValue;
            _configTime = configTimeValue;
            _configLocker = block.timestamp;
            _tradeLocker = block.timestamp;
            _mint(address(this), initialSupply);

            _owner = payable(msg.sender);
            _initialSupply = initialSupply;
            _name = name;
            _symbol = symbol;

    }

    // sha completat la capsalera
    function acceptConditions() public inConfigTime returns(bool) {
        require(acceptedConditions[msg.sender] == false);
        
        acceptedConditions[msg.sender] = true;
        _transfer(address(this), msg.sender, _userTokens);
        
        return true;
    }

    function publishArticle(uint256 _price) external {
        require(acceptedConditions[msg.sender] == true);
        require(articles[_totalArticles].status == State.None);
        
        articles[_totalArticles].status = State.OnSale;
        articles[_totalArticles].id = _totalArticles;
        articles[_totalArticles].price = _price;
        articles[_totalArticles].creator = msg.sender;
        articles[_totalArticles].owner = msg.sender;
        
        _totalArticles += 1;
    }

    // sha completat la capsalera
    function buyArticle(uint256 _id) public inTime {
        require(acceptedConditions[msg.sender] == true);
        require(articles[_id].status == State.OnSale);
        require(transfer(articles[_id].owner, articles[_id].price));
        
        articles[_id].status = State.Sold;
        articles[_id].owner = msg.sender;
    }
    
    // nova funcio
    function openSale() public {
        require(msg.sender == _owner);
        _tradeLocker = block.timestamp;
    }
    
}
