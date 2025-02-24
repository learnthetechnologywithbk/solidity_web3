// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; // Specifies the Solidity version (0.8.0 or later)

// Contract definition
contract Voting {

    // Structure to store candidate details
    struct Candidate {
        string name;        // Name of the candidate
        uint256 voteCount;  // Number of votes received
    }

    // Structure to store voter details
    struct Voter {
        bool hasVoted;              // Checks if voter has already voted
        uint256 votedCandidateId;   // Stores the ID of the voted candidate    
    }

    // Address of the contract admin (deployer)
    address public admin;

    // Mapping to store voter details (tracks whether an address has voted)
    mapping(address => Voter) public voters;

    // Dynamic array to store the list of candidates
    Candidate[] public candidates;

    // Event triggered when a new candidate is registered
    event CandidateRegistered(string name, uint256 candidateId);

    // Event triggered when a vote is cast
    event Voted(address indexed voter, uint256 candidateId);
    
    // Modifier to restrict certain actions to only the admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    // Modifier to ensure a voter hasn't already voted
    modifier hasNotVoted() {
        require(!voters[msg.sender].hasVoted, "You have already voted");
        _;
    }

    // Constructor function - Runs once when contract is deployed
    constructor() {
        admin = msg.sender; // Assigns the deployer as the admin
    }

    /**
    * @dev Allows the admin to register a new candidate
    * @param _name The name of the candidate to be added
    */
    function registerCandidate(string memory _name) public onlyAdmin {
        candidates.push(Candidate({ name: _name, voteCount: 0})); // Add candidate to the aarray
        emit CandidateRegistered(_name, candidates.length - 1); // Emit event for candidate registration   
    }

    /**
    * @dev Allows a user to vote for a candidate
    * @param _candidateId The ID of the candidate the user wants to vote for
    */
    function vote(uint256 _candidateId) public hasNotVoted {
        require(_candidateId < candidates.length, "Invalid candidate ID"); //Ensure candidate exists

        // Mark voter as having voted and store their choice
        voters[msg.sender] = Voter({ hasVoted: true, votedCandidateId: _candidateId});

        // Increase the candidate's vote count
        candidates[_candidateId].voteCount += 1;

        // Emit event for voting
        emit Voted(msg.sender, _candidateId);
    }

    /**
    * @dev Fetches details of a specific candidate
    * @param _candidateId The ID of the candidate to retrieve
    * @return name The candidate's name
    * @return voteCount The number of votes the candidate has received
    */
    function getCandidate(uint256 _candidateId) public view returns (string memory name, uint256 voteCount) {
        require(_candidateId < candidates.length, "Invalid candidate ID"); // Ensure valid candidate ID

        Candidate storage candidate = candidates[_candidateId]; // Fetch candidate details
        return (candidate.name, candidate.voteCount);        
    }

    /**
    * @dev Returns all registered candidates
    * @return An array of Candidate structures
    */
    function getAllCandidates() public view returns (Candidate[] memory) {
        return candidates;
    }

    /**
    * @dev Determines the winner based on votec ount
    * @return winnerName The name of the winning candidate
    * @return winnerVotes The number of votes received by the winner
    */
    function getWinner() public view returns (string memory winnerName, uint256 winnerVotes) {
        require(candidates.length > 0, "No candidates registered"); // Ensure at least one candidate exists

        uint256 maxVotes = 0;
        uint256 winnerIndex = 0;

        // Iterate through candidates to find the one with the highest votes
        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winnerIndex = i;
            }
        }

        return (candidates[winnerIndex].name, candidates[winnerIndex].voteCount);
    }

}