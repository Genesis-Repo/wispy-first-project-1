// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import ERC721Enumerable from the OpenZeppelin Contracts library.
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
// Import Ownable from the OpenZeppelin Contracts library for ownership control.
import "@openzeppelin/contracts/access/Ownable.sol";
// Import Counters from the OpenZeppelin Contracts library to handle incrementing and decrementing of integers.
import "@openzeppelin/contracts/utils/Counters.sol";

contract FriendTech is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdTracker;
    
    // Mapping to store the price of shares set by each user.
    mapping(address => uint256) private sharePrice;
    // Mapping to store the total supply of shares set by each user.
    mapping(address => uint256) private shareSupply;
    // Mapping to store the shares bought/sold/transferred between users.
    mapping(address => mapping(address => uint256)) private userShares;

    event SharePriceSet(address indexed user, uint256 price);
    event ShareSupplySet(address indexed user, uint256 supply);
    event ShareBought(address buyer, address seller, uint256 sharesBought);
    event ShareSold(address seller, address buyer, uint256 sharesSold);
    event ShareTransferred(address from, address to, uint256 sharesTransferred);

    constructor() ERC721("FriendTech Token", "FTT") {}

    // Set the price of the user's share
    function setSharePrice(uint256 _price) external {
        sharePrice[msg.sender] = _price;
        emit SharePriceSet(msg.sender, _price);
    }

    // Set the total supply of the user's shares
    function setShareSupply(uint256 _supply) external {
        shareSupply[msg.sender] = _supply;
        emit ShareSupplySet(msg.sender, _supply);
    }

    // Buy shares from a user
    function buyShares(address _user, uint256 _amount) external payable {
        require(sharePrice[_user] > 0, "User has not set share price");
        require(msg.value >= sharePrice[_user] * _amount, "Insufficient payment");
        
        userShares[_user][msg.sender] += _amount;
        emit ShareBought(msg.sender, _user, _amount);
    }

    // Sell shares to a user
    function sellShares(address _user, uint256 _amount) external {
        require(userShares[_user][msg.sender] >= _amount, "Insufficient shares");
        
        uint256 payment = sharePrice[_user] * _amount;
        payable(msg.sender).transfer(payment);
        userShares[_user][msg.sender] -= _amount;
        emit ShareSold(msg.sender, _user, _amount);
    }

    // Transfer shares to another user
    function transferShares(address _to, uint256 _amount) external {
        require(userShares[msg.sender][_to] >= _amount, "Insufficient shares");
        
        userShares[msg.sender][_to] -= _amount;
        userShares[_to][msg.sender] += _amount;
        emit ShareTransferred(msg.sender, _to, _amount);
    }

    // Function to distribute rewards to users based on their share ownership
    function distributeRewards() external {
        // You can add the logic here to distribute rewards to users based on their share ownership.
        // For example, calculate the total reward amount and distribute it among users proportionally to their share ownership.
    }
}