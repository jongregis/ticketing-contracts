// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/AccessControl.sol";

import {Event} from "./Event.sol";

contract EventFactory {
    address[] public deployedEvents;
    address public manager;

    constructor(address creator) {
        manager = creator;
    }

    function createEvent(string[] memory tickets, uint256[] memory amounts, string memory uri) public {
        //deploys events and returns address
        address newEvent = address(new Event(msg.sender, tickets, amounts, uri));
        deployedEvents.push(newEvent);
    }

    // Returns the first found token type if user has one.  -1 if no tickets.
    function hasTicket(address user, uint256 eventId) public view returns (int256) {
        require(user != address(0), "EventFactory: address zero is not a valid owner");

        Event deployedEvent = Event(deployedEvents[eventId]);

        return deployedEvent.hasTicket(user);
    }

    function transferTicket(uint256 eventId, address to, uint256 token, uint256 amount) public {
        Event deployedEvent = Event(deployedEvents[eventId]);

        deployedEvent.transferTicket(manager, to, token, amount);
    }

    function getDeployedEvents() public view returns (address[] memory) {
        return deployedEvents;
    }
}
