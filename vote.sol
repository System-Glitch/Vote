// SPDX-License-Identifier: UNLICENSED;

pragma solidity ^0.7.5;
pragma experimental ABIEncoderV2;


contract vote {

    Candidate[] candidates;
    address payable public owner;
    mapping (address => uint) indexByAddress;
    mapping (address => uint) indexByAddress2;
    mapping (address => bool) votedByAddress;
    mapping (address => bool) votedByAddress2;
    mapping (address => bool) isCandidateByAddress;
    uint vote_state;
    uint nb_candidate;

    struct Candidate {
        address myAddress;
        uint voteScore;
        string myName;
    }

    constructor() {
        owner = msg.sender;
        vote_state = 0;
        nb_candidate = 0;
    }

    function get_vote_state() public view returns(uint) {
        return vote_state;
    }

    function start_vote() public {
        require(nb_candidate >= 2);
        require(vote_state == 0);
        require(msg.sender == owner);
        
        vote_state = 1;
    }

    function get_candidates() public view returns(Candidate[] memory) {
        return candidates;
    }
    
    function add_candidate (string memory myName) public {
        require (vote_state == 0);
        require (isCandidateByAddress[msg.sender] == false);
        require (bytes(myName).length > 1);

        uint length = candidates.length;
        candidates.push(Candidate(msg.sender, 0, myName));
        isCandidateByAddress[msg.sender] = true;
        indexByAddress[msg.sender] = length;
        nb_candidate++;
    }

    function vote_to(address[] memory vote_candidates) public {
        require (vote_state == 1 && votedByAddress[msg.sender] == false);
        require (vote_candidates.length == candidates.length);
        
        for (uint i = 0; i < vote_candidates.length; i++) {
            require (isCandidateByAddress[vote_candidates[i]]);
        }
        
        votedByAddress[msg.sender] = true;
        
        for (uint y = 0; y < vote_candidates.length; y++) {
            uint current_candidate_index = indexByAddress[vote_candidates[y]];
            
            candidates[current_candidate_index].voteScore += candidates.length - y;
        }
        
    }

    function end_vote() public {
        require(vote_state == 1);
        require(msg.sender == owner);

        vote_state++;
    }
}
