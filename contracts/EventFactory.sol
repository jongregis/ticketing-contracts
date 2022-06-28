// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Event} from "./Event.sol";

contract EventFactory {
    address[] public deployedEvents;

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

    function getDeployedEvents() public view returns (address[] memory) {
        return deployedEvents;
    }
}
