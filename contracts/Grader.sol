pragma solidity ^0.4.20;

contract Grader {
    address public admin;
    string message;
    bytes32[] courseIDList;
    mapping(bytes32 => bool) public courseIds;
    mapping(address => bool) public instructors;
    mapping(bytes32 => address) public courseInstructor;

    function Grader() public {
        admin = msg.sender;
        message = 'Welcome to the Decentralised Grading System designed by Saiteja Talluri and Pavan Bhargav !!';
    }

    function kill() public {
        if(msg.sender == admin) {
            selfdestruct(admin);
        }
    }

    struct Exam {
        bytes32 examID;
        uint256 maxMarks;
        mapping (bytes32 => uint256) marks;
    }

    struct Course {
        bytes32 courseID;
        bytes32 courseName;
        bytes32[] rollList;
        address instructor;
        bytes32[] examIDList;
        uint256[] gradeCutoffs;
        mapping (address => bool) TAs;
        mapping (bytes32 => bool) examIds;
        mapping (bytes32 => Exam) exams;
        mapping (bytes32 => uint256) weightage;
    }

    mapping(bytes32 => Course) public courses;

    function convertToMapping(address[] arr) public return (mapping (address => bool) mapArr) {
        mapping (address => bool) mapArr;
        for (uint256 i = 0; i < arr.length; i++) {
            mapArr[arr[i]] = true;
        }
        return mapArr;
    }

    function addInstructor(mapping(address => bool) instructorsList) public returns (bool added) {
        if (msg.sender == admin) {
            instructors = instructorsList;
            return true;
        }
        else
            return false;
    }

    function addCourse(bytes32 courseID, bytes32 courseName, bytes32[] rollList, mapping (address => bool) TAs) public returns (bool added) {
        if (instructors[msg.sender] && (!courseIds[courseID])) {
          courseInstructor[courseID] = msg.sender;
          courseIds[courseID] = true;
          courseIDList.push(courseID);
          courses[courseID] = Course(courseID, courseName, rollList[], msg.sender);
          courses[courseID].TAs = TAs;
          return true;
        }
        else
          return false;
    }

    function addExam(bytes32 courseID, bytes32 examID, uint256 maxMarks, mapping (bytes32 => uint256) marks) public returns (bool added) {
        if (courseIds[courseID] && (instructors[msg.sender] || courses[courseID].TAs[msg.sender])) {
            courses[courseID].examIds[examID] = true;
            courses[courseID].examIDList.push(examID);
            courses[courseID].exams[examID] = Exam(examID, maxMarks, marks);
            return true;
        }
        else
            return false;
    }

    function updateMarks(bytes32 courseID, bytes32 examID, mapping (bytes32 => uint256) marks) public returns (bool added) {
        if (courseIds[courseID] && (instructors[msg.sender] || courses[courseID].TAs[msg.sender]) && courses[courseID].examIds[examID]) {
            courses[courseID].exams[examID].marks = marks;
            return true;
        }
        else
            return false;
    }

    function setWeightages(bytes32 courseID, mapping (bytes32 => uint256) weightage) {
      if (courseIds[courseID] && instructors[msg.sender]) {
          courses[courseID].weightage = weightage;
          return true;
      }
      else
          return false;
    }

    function setGradeCutoffs (bytes32 courseID, uint256[] gradeCutoffs) {
      if (courseIds[courseID] && instructors[msg.sender]) {
          courses[courseID].gradeCutoffs = gradeCutoffs;
          return true;
      }
      else
          return false;
    }

    function cal
}
