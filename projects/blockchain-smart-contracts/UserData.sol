pragma solidity ^0.8.0;

enum Occupation {None, Student, Teacher}

contract UserData {
    struct User {
        address userAddress;
        string name;
        string surname;
        uint age;
        uint grade;
        Occupation occupation;
        mapping(address => bool) allowedAccess;
    }

    mapping(address => User) public users;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized: owner only");
        _;
    }
    modifier onlyTeacher() {
        require(users[msg.sender].occupation == Occupation.Teacher, "Not authorized: teacher only");
        _;
    }

    event UserRegistered(address user, string name, string surname);
    event GradeUpdated(address indexed student, uint newGrade);
    event AccessGranted(address indexed user, address indexed grantee);
    event AccessRevoked(address indexed user, address indexed grantee);

    function registerTeacher(address _teacher, string memory _name, string memory _surname,uint _age) external onlyOwner {
        require(_teacher != address(0), "Invalid address");
        User storage user = users[_teacher];
        user.userAddress = _teacher;
        user.name = _name;
        user.surname = _surname;
        user.age = _age;
        user.grade = 0;
        user.occupation = Occupation.Teacher;

        emit UserRegistered(_teacher, _name, _surname);
    }

    function registerStudent(address _student,string memory _name,string memory _surname,uint _age) external {
        require(_student != address(0), "Invalid address");
        require(
            users[msg.sender].occupation == Occupation.Teacher || msg.sender == _student,
            "Not authorized to register this student"
        );
        require(users[_student].occupation == Occupation.None, "User already registered");

        if (msg.sender == _student) {
            require(msg.sender == _student, "You can only register yourself");
        }

        User storage user = users[_student];
        user.userAddress = _student;
        user.name = _name;
        user.surname = _surname;
        user.age = _age;
        user.grade = 0;
        user.occupation = Occupation.Student;

        emit UserRegistered(_student, _name, _surname);
    }

    function grantAccess(address _grantee) public {
		require(users[_grantee].userAddress != address(0), "Grantee does not exist");
		
        users[msg.sender].allowedAccess[_grantee] = true;
        emit AccessGranted(msg.sender, _grantee);
    }


    function revokeAccess(address _grantee) public {
		require(users[_grantee].userAddress != address(0), "Grantee does not exist");
	
        users[msg.sender].allowedAccess[_grantee] = false;
        emit AccessRevoked(msg.sender, _grantee);
    }


    function updateGrade(address _student, uint _newGrade) public onlyTeacher {
        require(users[_student].occupation == Occupation.Student, "Not a student");
        require(_newGrade <= 20, "Grade out of bounds (0 - 20).");
        users[_student].grade = _newGrade;
        emit GradeUpdated(_student, _newGrade);
    }

    function isAllowed(address _user, address _requester) public view returns (bool) {
        if (_user == _requester) return true;
        return users[_user].allowedAccess[_requester];
    }

    function getUserGrade(address _user) public view returns (uint) {
        require(
            msg.sender == _user
            ||
            users[msg.sender].occupation == Occupation.Teacher
            ||
            isAllowed(_user, msg.sender),
            "Not authorized to view grade"
        );
        return users[_user].grade;
    }

    function getUserOccupation(address _user) public view returns (string memory) {
        if (users[_user].occupation == Occupation.Student) {
            return "Student";
        } else if (users[_user].occupation == Occupation.Teacher) {
            return "Teacher";
        }
        return "None";
    }

    function getUserData(address _user) public view returns (
        address userAddress,
        string memory name,
        string memory surname,
        uint age,
        uint grade,
        string memory occupationStr
    ) {
        require(users[_user].userAddress != address(0), "User does not exist");

        if (_user == owner) {
            require(msg.sender == owner, "Not authorized to view owner data");
        } else {
            require(
                msg.sender == _user ||
                msg.sender == owner ||
                users[msg.sender].occupation == Occupation.Teacher ||
                isAllowed(_user, msg.sender),
                "Not authorized to view user data"
            );
        }

        User storage u = users[_user];
        occupationStr = getUserOccupation(_user);
        return (u.userAddress, u.name, u.surname, u.age, u.grade, occupationStr);
    }

}