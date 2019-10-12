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
        mapping (bytes32 => uint256) totalMarks;
        mapping (bytes32 => string) grades;
    }

    mapping(bytes32 => Course) public courses;

    function addInstructor(address[] instructorsList) public returns (bool added) {
        if (msg.sender == admin) {
            for (uint256 i = 0; i < instructorsList.length; i++)
                instructors[instructorsList[i]] = true;
            return true;
        }
        else
            return false;
    }

    function addCourse(bytes32 courseID, bytes32 courseName, bytes32[] rollList, address[] TAs) public returns (bool added) {
        if (instructors[msg.sender] && (!courseIds[courseID])) {
            bytes32[] memory examIDList;
            uint256[] memory gradeCutoffs;
            courseInstructor[courseID] = msg.sender;
            courseIds[courseID] = true;
            courseIDList.push(courseID);
            courses[courseID] = Course(courseID, courseName, rollList, msg.sender, examIDList, gradeCutoffs);
            for (uint256 i = 0; i < TAs.length; i++)
                    courses[courseID].TAs[TAs[i]] = true;
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

    function setWeightages(bytes32 courseID, mapping (bytes32 => uint256) weightage) public returns (bool added)  {
        if (courseIds[courseID] && instructors[msg.sender]) {
            courses[courseID].weightage = weightage;
            return true;
        }
        else
            return false;
    }

    function setGradeCutoffs (bytes32 courseID, uint256[] gradeCutoffs) public returns (bool added) {
        if (courseIds[courseID] && instructors[msg.sender]) {
            string[8] memory gradeList = ["AA", "AB", "BB", "BC", "CC", "CD", "DD", "FR"];
            if (gradeCutoffs.length != (gradeList.length - 1))
                return false;
            courses[courseID].gradeCutoffs = gradeCutoffs;
            return true;
        }
        else
            return false;
    }

    function calculateTotal (bytes32 courseID, uint16 precision) public returns (bool added) {
        if (courseIds[courseID] && instructors[msg.sender]) {
            uint256 pres = 10**precision;
            for (uint256 i = 0; i < courses[courseID].examIDList.length; i++) {
                bytes32 exam_id = courses[courseID].examIDList[i];
                uint256 maxmarks = courses[courseID].exams[exam_id].maxMarks;
                uint256 weightage = courses[courseID].weightage[exam_id];
                for (uint256 j = 0; j < courses[courseID].rollList.length; j++) {
                      bytes32 roll_no = courses[courseID].rollList[j];
                      courses[courseID].totalMarks[roll_no] += ((courses[courseID].exams[exam_id].marks[roll_no] * pres * weightage)/maxmarks);
                }
            }
            for (uint256 k = 0; k < courses[courseID].rollList.length; k++) {
                  courses[courseID].totalMarks[courses[courseID].rollList[k]] = (courses[courseID].totalMarks[courses[courseID].rollList[k]]/pres);
            }
            return true;
        }
        else
            return false;
    }

    function calculateGrades (bytes32 courseID) public returns (bool added) {
      if (courseIds[courseID] && instructors[msg.sender]) {
          string[8] memory gradeList = ["AA", "AB", "BB", "BC", "CC", "CD", "DD", "FR"];
          for (uint256 i = 0; i < courses[courseID].rollList.length; i++) {
              for (uint256 j = 0; j < courses[courseID].gradeCutoffs.length; j++) {
                    bytes32 roll_no = courses[courseID].rollList[i];
                    if (courses[courseID].totalMarks[roll_no] >= courses[courseID].gradeCutoffs[j])
                        courses[courseID].grades[roll_no] = gradeList[j];
                        break;
              }
          }
          return true;
      }
      else
          return false;
    }
}
