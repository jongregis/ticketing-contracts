// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin/token/ERC1155/ERC1155.sol";
import "openzeppelin/access/Ownable.sol";
import "openzeppelin/utils/Counters.sol";

contract Event is ERC1155, Ownable {
    using Counters for Counters.Counter;
    address public manager;
    Counters.Counter private _tokenIds;

    mapping(uint256 => uint256) ticket_prices;

    constructor(address creator, string[] memory tickets, uint256[] memory amounts, string memory _uri, uint256[] memory prices) ERC1155(_uri) {
        manager = creator;
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

    function addTicket(string memory name, uint256 amount) public onlyOwner {
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

    // Need to figure out permissions, avoid people minting all tickets!
    function transferTicket(
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) public {
        _safeTransferFrom(from, to, id, amount, "0x0");

    }

    function getTotalTicketTypes() public returns(uint256) {
        return _tokenIds.current();
    }

    function sweep() public onlyOwner {
        uint256 _balance = address(this).balance;
        payable(manager).transfer(_balance);
    }
}
