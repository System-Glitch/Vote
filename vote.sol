// SPDX-License-Identifier: UNLICENSED;

pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;


contract vote {

    Candidate[] candidates;
    Candidate[] candidates2;
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
        uint voteCount;
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

    function get_candidates(bool firstRound) public view returns(Candidate[] memory) {
        return firstRound ? candidates : candidates2;
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

    function vote_to(address candidate) public {
        require (vote_state == 1 && votedByAddress[msg.sender] == false || vote_state == 2 && votedByAddress2[msg.sender] == false );
        if(vote_state == 1) {
            votedByAddress[msg.sender] = true;
            candidates[indexByAddress[candidate]].voteCount++;
        } else {
            votedByAddress2[msg.sender] = true;
            candidates2[indexByAddress2[candidate]].voteCount++;
        }
    }

    function end_turn() public {
        require(vote_state == 1 || vote_state == 2);
        require(msg.sender == owner);
        uint save_i1 = 0;
        uint save_i2 = 0;
        if (vote_state == 1) {
	        for(uint i = 0 ; i < nb_candidate ; i++) {
                if (candidates[i].voteCount > candidates[save_i2].voteCount){
		            if (candidates[i].voteCount > candidates[save_i1].voteCount){
					    save_i2 = save_i1;
 					    save_i1 = i;
				    } else {
					    save_i2 = i;
 			        }
			    }
   	 	    }
   	 	    
   	 	    candidates2.push(Candidate(candidates[save_i1].myAddress, 0, candidates[save_i1].myName));
   	 	    indexByAddress2[candidates[save_i1].myAddress] = 0;

   	 	    candidates2.push(Candidate(candidates[save_i2].myAddress, 0, candidates[save_i2].myName));
   	 	    indexByAddress2[candidates[save_i2].myAddress] = 1;
        }

        vote_state++;
    }
}