pragma solidity ^0.4.26;

contract Grader {
    address public admin;
    bytes32[] public courseIDList;
    address[] public instructorsList;
    mapping(bytes32 => bool) courseIds;
    mapping(address => bool) instructors;
    mapping(bytes32 => address) courseInstructor;

    constructor() public {
        admin = msg.sender;
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
        string courseName;
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

    mapping(bytes32 => Course) courses;

    function addInstructor(address[] instrlist) public returns (bool added) {
        if (msg.sender == admin) {
            for (uint256 i = 0; i < instrlist.length; i++)
                instructorsList.push(instrlist[i]);
                instructors[instrlist[i]] = true;
            return true;
        }
        else
            return false;
    }

    function addCourse(bytes32 courseID, string courseName, bytes32[] rollList, address[] TAs) public returns (bool added) {
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

    function addExam(bytes32 courseID, bytes32 examID, uint256 maxMarks, bytes32[] rollList, uint256[] marksList) public returns (bool added) {
        if (courseIds[courseID] && (instructors[msg.sender] || courses[courseID].TAs[msg.sender])) {
            if (marksList.length != rollList.length)
                return false;
            courses[courseID].examIds[examID] = true;
            courses[courseID].examIDList.push(examID);
            courses[courseID].exams[examID] = Exam(examID, maxMarks);
            for (uint256 i = 0; i < rollList.length; i++)
                courses[courseID].exams[examID].marks[rollList[i]] = marksList[i];
            return true;
        }
        else
            return false;
    }

    function updateMarks(bytes32 courseID, bytes32 examID, bytes32[] rollList, uint256[] marksList) public returns (bool added) {
        if (courseIds[courseID] && (instructors[msg.sender] || courses[courseID].TAs[msg.sender]) && courses[courseID].examIds[examID]) {
            if (marksList.length != rollList.length)
                return false;
            for (uint256 i = 0; i < rollList.length; i++)
                courses[courseID].exams[examID].marks[rollList[i]] = marksList[i];
            return true;
        }
        else
            return false;
    }

    function setWeightages(bytes32 courseID, bytes32[] examIDList, uint256[] weightageList) public returns (bool added)  {
        if (courseIds[courseID] && instructors[msg.sender]) {
            if (examIDList.length != weightageList.length)
                return false;
            for (uint256 i = 0; i < examIDList.length; i++)
                courses[courseID].weightage[examIDList[i]] = weightageList[i];
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

    function calculateTotal (bytes32 courseID) public returns (bool added) {
        if (courseIds[courseID] && instructors[msg.sender]) {
            uint pres = 1000;
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
