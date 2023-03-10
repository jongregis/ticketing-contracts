// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin-upgrades/contracts/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin-upgrades/contracts/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin-upgrades/contracts/proxy/utils/Initializable.sol";
import {Utils} from "./utils/Utils.sol";

contract Event is Initializable, ERC1155Upgradeable, OwnableUpgradeable, Utils {
    using Counters for Counters.Counter;
    address public manager;
    Counters.Counter private _tokenIds;
    string public name;
    string public description;
    uint256 public start;
    uint256 public finish;
    string public location;
    string public thumbnail;

    mapping(uint256 => uint256) ticket_prices;
    mapping(address => bool) public hasBought;

    // / @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address creator,
        string[] calldata tickets,
        uint256[] calldata amounts,
        string memory _uri,
        uint256[] memory prices,
        EventDetails calldata details
    ) public initializer {
        __ERC1155_init(_uri);
        __Ownable_init();
        manager = creator;
        name = details._name;
        description = details._description;
        location = details._location;
        start = details._start;
        finish = details._end;
        thumbnail = details._thumbnail;
        transferOwnership(manager);
        for (uint256 i = 0; i < tickets.length; i++) {
            _tokenIds.increment();
            uint256 newTokenId = _tokenIds.current();
            _mint(manager, newTokenId, amounts[i], "");
            ticket_prices[i] = prices[i];
        }
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function addTicket(uint256 amount) public onlyOwner {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _mint(manager, newTokenId, amount, "");
    }

    function hasTicket(address user) public view returns (int256) {
        for (int256 i = 0; i < int256(_tokenIds.current()); i++) {
            if (balanceOf(user, uint256(i)) > 0) {
                return i;
            }
        }
        return -1;
    }

    function buyTicket(uint256 ticket, uint256 amount) external payable {
        require(
            balanceOf(manager, ticket) >= amount,
            "Not enough tickets left!"
        );
        require(
            msg.value >= ticket_prices[ticket] * amount,
            "Not enough to buy tickets!"
        );

        _safeTransferFrom(manager, msg.sender, ticket, amount, "0x0");
    }

    // Need to figure out permissions, avoid people minting all tickets!
    function transferTicket(
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) public {
        _safeTransferFrom(from, to, id, amount, "0x0");
    }

    function getTotalTicketTypes() public view returns (uint256) {
        return _tokenIds.current();
    }

    function sweep() public onlyOwner {
        uint256 _balance = address(this).balance;
        payable(manager).transfer(_balance);
    }
}
