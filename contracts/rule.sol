// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract TownlandOwnerRule {
    enum Rule {
        UNDEFINED, // 0
        ROOT, // 1
        ADMIN // 2
    }

    struct Database {
        address[] OwnersAddress; // list of owners' address
        mapping(address=>Rule) Owners; // map of owners with thier rule
    }

    struct Owner {
        Rule rule;
        address user;
    }

    Rule[] Admin = [Rule.ROOT, Rule.ADMIN];

    Database database;

    constructor() {
        database.OwnersAddress.push(msg.sender);
        database.Owners[msg.sender] = Rule.ROOT;
    }

    modifier OnlyOwnerWithRule(Rule[] memory rules) {
        address user = address(msg.sender);

        require(database.Owners[user] != Rule.UNDEFINED, "Who are you ?");

        bool has = false;

        for(uint i = 0; i < rules.length; i++) {
            if(database.Owners[user] == rules[i]) {
                has = true;
            }
        }

        if(has) {
            _;
        } else {
            revert("Dear owner you don't have permission.");
        }
    }

    function AddOwner(address user, Rule rule) public OnlyOwnerWithRule(Admin) {
        require(rule != Rule.ROOT, "Just one root.");
        database.OwnersAddress.push(user);
        SetOwnerRule(user, rule);
    }

    function SetOwnerRule(address user, Rule rule) public OnlyOwnerWithRule(Admin) {
        database.Owners[user] = rule;
    }

    function GetOwner(address user) public view returns (Owner memory) {
        Owner memory owner;

        owner.user = user;
        owner.rule = database.Owners[user];

        return owner;
    }

    function GetOwners() public view returns (Owner[] memory) {
        Owner[] memory owners = new Owner[](database.OwnersAddress.length);

        for(uint i = 0 ; i < database.OwnersAddress.length; i++) {
            owners[i] = GetOwner(database.OwnersAddress[i]);
        }

        return owners;
    }

    function IsOwner(address user) public view returns (bool) {
        return database.Owners[user] != Rule.UNDEFINED;
    }
}