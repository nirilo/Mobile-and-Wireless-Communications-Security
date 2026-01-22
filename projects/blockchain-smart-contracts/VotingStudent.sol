pragma solidity ^0.8.0;

contract PresidentialElection {

    struct Student {
        address candidateAddress;
        string name;
        string surname;
        uint age;
        uint voteCount;
        bool registered;
    }

    address public owner;
    mapping(address => Student) public candidates;

    address[] public candidateList;

    // votes only one time.
    mapping(address => bool) public hasVoted;
    uint public votedCount;
    //    uint public totalEligibleVoters;

    event CandidateRegistered(address candidate);
    event VoteCast(address voter, address candidate);

    constructor() {
        owner = msg.sender;
    }

    // @notice εγγραφή υποψηφίου από τον ίδιο τον υποψήφιο.
    function registerCandidateBySelf(string memory _name, string memory _surname, uint _age) public {
        require(!candidates[msg.sender].registered, "Candidate already registered.");

        candidates[msg.sender] = Student({
            candidateAddress: msg.sender,
            name: _name,
            surname: _surname,
            age: _age,
            voteCount: 0,
            registered: true
        });
        candidateList.push(msg.sender);
        emit CandidateRegistered(msg.sender);
    }

    // @notice εγγραφή υποψηφίου από τον owner του contract.
    function registerCandidateByOwner(address _candidateAddress, string memory _name, string memory _surname, uint _age) public {
        require(msg.sender == owner, "Only owner can register a candidate for others.");
        require(!candidates[_candidateAddress].registered, "Candidate already registered.");

        candidates[_candidateAddress] = Student({
            candidateAddress: _candidateAddress,
            name: _name,
            surname: _surname,
            age: _age,
            voteCount: 0,
            registered: true
        });
        candidateList.push(_candidateAddress);
        emit CandidateRegistered(_candidateAddress);
    }

    function vote(address _candidateAddress) public {
        require(candidates[_candidateAddress].registered, "Candidate's not registered.");
        require(!hasVoted[msg.sender], "You've already voted.");

        candidates[_candidateAddress].voteCount++;
        hasVoted[msg.sender] = true;
        votedCount++;
        emit VoteCast(msg.sender, _candidateAddress);
    }

    function getVoteCount(address _candidateAddress) public view returns (uint) {
        require(candidates[_candidateAddress].registered, "Candidate's not registered.");
        return candidates[_candidateAddress].voteCount;
    }

    function getCandidatesCount() public view returns (uint) {
        return candidateList.length;
    }

    // @notice επιστρέφει τα στοιχεία ενός υποψηφίου με βάση τη θέση του πίνακα.
    function getCandidate(uint index) public view returns (Student memory) {
        require(index < candidateList.length, "Index out of range");
        return candidates[candidateList[index]];
    }

    function winnerCandidate() public view returns (Student memory) {
        require(candidateList.length > 0, "No candidates registered.");

        Student memory winner = candidates[candidateList[0]];
        for (uint i = 1; i < candidateList.length; i++) {
            if (candidates[candidateList[i]].voteCount > winner.voteCount) {
                winner = candidates[candidateList[i]];
            }
        }
        return winner;
    }

    function getVotingSummary() public view returns (uint voted, uint notVoted) {
        voted = votedCount;
        notVoted = candidateList.length - votedCount;
    }

//    function setTotalEligibleVoters(uint _total) public {
//        require(msg.sender == owner, "Only owner can set total eligible voters");
//        totalEligibleVoters = _total;
//    }

}