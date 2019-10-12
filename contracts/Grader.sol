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
        require(msg.sender == admin);
        selfdestruct(admin);
    }

    struct Exam {
        bytes32 examID;
        uint maxMarks;
        mapping (bytes32 => uint) marks;
    }

    struct Course {
        bytes32 courseID;
        string courseName;
        bytes32[] rollList;
        address instructor;
        bytes32[] examIDList;
        uint[] gradeCutoffs;
        mapping (bytes32 => address) students;
        mapping (address => bool) TAs;
        mapping (bytes32 => bool) examIds;
        mapping (bytes32 => Exam) exams;
        mapping (bytes32 => uint) weightage;
        mapping (bytes32 => uint) totalMarks;
        mapping (bytes32 => string) grades;
    }

    mapping(bytes32 => Course) courses;

    function addInstructor(address[] instrlist) public returns (bool added) {
        require (msg.sender == admin, "addInstructor");
        for (uint i = 0; i < instrlist.length; i++){
            if(!instructors[instrlist[i]]){
                instructorsList.push(instrlist[i]);
                instructors[instrlist[i]] = true;
            }
        }
        added = true;
    }

    function addCourse(bytes32 courseID, string courseName, bytes32[] rollList, address[] studAddr, address[] TAs) public returns (bool added) {
        require (instructors[msg.sender] && (!courseIds[courseID]), "addCourse");
        require (rollList.length == studAddr.length, "addCourse");
        bytes32[] memory examIDList;
        uint[] memory gradeCutoffs;
        courseInstructor[courseID] = msg.sender;
        courseIds[courseID] = true;
        courseIDList.push(courseID);
        courses[courseID] = Course(courseID, courseName, rollList, msg.sender, examIDList, gradeCutoffs);
        for (uint i = 0; i < rollList.length; i++)
                courses[courseID].students[rollList[i]] = studAddr[i]
        for (uint i = 0; i < TAs.length; i++)
                courses[courseID].TAs[TAs[i]] = true;
        added = true;
    }

    function addExam(bytes32 courseID, bytes32 examID, uint maxMarks, bytes32[] rollList, uint[] marksList) public returns (bool added) {
        require (courseIds[courseID] && (instructors[msg.sender] || courses[courseID].TAs[msg.sender]) && (!courses[courseID].examIds[examID]), "addExam");
        require (marksList.length == rollList.length, "addExam")
        courses[courseID].examIds[examID] = true;
        courses[courseID].examIDList.push(examID);
        courses[courseID].exams[examID] = Exam(examID, maxMarks);
        for (uint i = 0; i < rollList.length; i++)
            courses[courseID].exams[examID].marks[rollList[i]] = marksList[i];
        added = true;
    }

    function updateMarks(bytes32 courseID, bytes32 examID, bytes32[] rollList, uint[] marksList) public returns (bool added) {
        require (courseIds[courseID] && (instructors[msg.sender] || courses[courseID].TAs[msg.sender]) && courses[courseID].examIds[examID], "updateMarks");
        require (marksList.length == rollList.length, "updateMarks");
        for (uint i = 0; i < rollList.length; i++)
            courses[courseID].exams[examID].marks[rollList[i]] = marksList[i];
        added = true;
    }

    function setWeightages(bytes32 courseID, bytes32[] examIDList, uint[] weightageList) public returns (bool added) {
        require (courseIds[courseID] && instructors[msg.sender], "setWeightages");
        require (examIDList.length == weightageList.length, "setWeightages");
        for (uint i = 0; i < examIDList.length; i++)
            courses[courseID].weightage[examIDList[i]] = weightageList[i];
        added = true;
    }

    function setGradeCutoffs(bytes32 courseID, uint[] gradeCutoffs) public returns (bool added) {
        require (courseIds[courseID] && instructors[msg.sender], "setGradeCutoffs");
        string[8] memory gradeList = ["AA", "AB", "BB", "BC", "CC", "CD", "DD", "FR"];
        require (gradeCutoffs.length == (gradeList.length - 1), "setGradeCutoffs");
        courses[courseID].gradeCutoffs = gradeCutoffs;
        added = true;
    }

    function calculateTotal (bytes32 courseID) public returns (bool added) {
        require (courseIds[courseID] && instructors[msg.sender], "calculateTotal");
        uint pres = 1000;
        for (uint i = 0; i < courses[courseID].examIDList.length; i++) {
            bytes32 exam_id = courses[courseID].examIDList[i];
            uint maxmarks = courses[courseID].exams[exam_id].maxMarks;
            uint weightage = courses[courseID].weightage[exam_id];
            for (uint j = 0; j < courses[courseID].rollList.length; j++) {
                  bytes32 roll_no = courses[courseID].rollList[j];
                  courses[courseID].totalMarks[roll_no] += ((courses[courseID].exams[exam_id].marks[roll_no] * pres * weightage)/maxmarks);
            }
        }
        for (uint k = 0; k < courses[courseID].rollList.length; k++) {
              courses[courseID].totalMarks[courses[courseID].rollList[k]] = (courses[courseID].totalMarks[courses[courseID].rollList[k]]/pres);
        }
        added = true;
    }

    function calculateGrades (bytes32 courseID) public returns (bool added) {
        require (courseIds[courseID] && instructors[msg.sender], "calculateGrades");
        string[8] memory gradeList = ["AA", "AB", "BB", "BC", "CC", "CD", "DD", "FR"];
        for (uint i = 0; i < courses[courseID].rollList.length; i++) {
            for (uint j = 0; j < courses[courseID].gradeCutoffs.length; j++) {
                bytes32 roll_no = courses[courseID].rollList[i];
                if (courses[courseID].totalMarks[roll_no] >= courses[courseID].gradeCutoffs[j])
                    courses[courseID].grades[roll_no] = gradeList[j];
                    break;
            }
        }
        added = true;
    }
}
