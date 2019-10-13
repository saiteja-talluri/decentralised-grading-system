pragma solidity ^0.4.26;

contract Grader {
    address public admin;
    bytes32[] public courseIDList;
    mapping(bytes32 => bool) courseIds;
    address[] public instructorsList;
    mapping(address => bool) instructors;
    mapping(bytes32 => address) courseInstructor;
    uint[8] gradeChart = [10, 9, 8, 7, 6, 5, 4, 0];

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
        address instructor;
        bytes32[] rollList;
        bool marksExist;
        mapping (bytes32 => bool) rollNoVer;
        mapping (address => bool) TAs;
        mapping (bytes32 => address) students;
        mapping (address => bool) studentAddrVer;
    }

    struct Marks {
        bytes32[] examIDList;
        uint[] weightageList;
        uint[] maxMarksList;
        uint[] gradeCutoffs;
        uint[] gradeList;
        uint[] totalMarksList;
        uint[][] marksList;
        mapping (bytes32 => bool) examIds;
        mapping (bytes32 => Exam) exams;
        mapping (bytes32 => uint) weightage;
        mapping (bytes32 => uint) totalMarks;
        mapping (bytes32 => uint) grades;
    }

    mapping(bytes32 => Course) courses;
    mapping(bytes32 => Marks) courseMarks;

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
        courseInstructor[courseID] = msg.sender;
        courseIds[courseID] = true;
        courseIDList.push(courseID);
        courses[courseID] = Course(courseID, courseName, msg.sender, rollList, false);
        for (uint i = 0; i < rollList.length; i++) {
            if (!courses[courseID].studentAddrVer[studAddr[i]]) {
                courses[courseID].students[rollList[i]] = studAddr[i];
                courses[courseID].studentAddrVer[studAddr[i]] = true;
            }
            if (!courses[courseID].rollNoVer[rollList[i]])
                courses[courseID].rollNoVer[rollList[i]] = true;
        }
        for (uint j = 0; j < TAs.length; j++)
                courses[courseID].TAs[TAs[j]] = true;
        added = true;
    }

    function addCourseMarks(bytes32 courseID) public returns (bool added) {
        require (courseIds[courseID] && ((courseInstructor[courseID] == msg.sender) || courses[courseID].TAs[msg.sender]), "addCourseMarks");
        bytes32[] memory examIDList;
        uint[] memory weightageList;
        uint[] memory maxMarksList;
        uint[] memory gradeCutoffs;
        uint[] memory gradeList;
        uint[] memory totalMarksList;
        uint[][] memory marksList;
        courseMarks[courseID] = Marks(examIDList, weightageList,maxMarksList,gradeCutoffs,gradeList,totalMarksList,marksList);
        courses[courseID].marksExist = true;
        added = true;
    }

    function addExam(bytes32 courseID, bytes32 examID, uint maxMarks, bytes32[] rollList, uint[] marksList) public returns (bool added) {
        require (courseIds[courseID] && ((courseInstructor[courseID] == msg.sender) || courses[courseID].TAs[msg.sender]), "addExam");
        require (marksList.length == rollList.length, "addExam");
        if (!courses[courseID].marksExist)
            addCourseMarks(courseID);
        require(!courseMarks[courseID].examIds[examID], "addExam");
        courseMarks[courseID].examIds[examID] = true;
        courseMarks[courseID].examIDList.push(examID);
        courseMarks[courseID].maxMarksList.push(maxMarks);
        courseMarks[courseID].exams[examID] = Exam(examID, maxMarks);
        for (uint i = 0; i < rollList.length; i++) {
            courseMarks[courseID].exams[examID].marks[rollList[i]] = marksList[i];
            courseMarks[courseID].marksList[i].push(marksList[i]);
        }
        added = true;
    }

    function updateMarks(bytes32 courseID, bytes32 examID, bytes32[] rollList, uint[] marksList) public returns (bool added) {
        require (courseIds[courseID] && ((courseInstructor[courseID] == msg.sender) || courses[courseID].TAs[msg.sender]) && courses[courseID].examIds[examID], "updateMarks");
        require (marksList.length == rollList.length, "updateMarks");
        for (uint i = 0; i < rollList.length; i++)
            courses[courseID].exams[examID].marks[rollList[i]] = marksList[i];
        added = true;
    }

    function setWeightages(bytes32 courseID, bytes32[] examIDList, uint[] weightageList) private returns (bool added) {
        require (courseIds[courseID] && (courseInstructor[courseID] == msg.sender), "setWeightages");
        require (examIDList.length == weightageList.length, "setWeightages");
        courses[courseID].weightageList = weightageList;
        for (uint i = 0; i < examIDList.length; i++)
            courses[courseID].weightage[examIDList[i]] = weightageList[i];
        added = true;
    }

    function setGradeCutoffs(bytes32 courseID, uint[] gradeCutoffs) private returns (bool added) {
        require (courseIds[courseID] && (courseInstructor[courseID] == msg.sender), "setGradeCutoffs");
        require (gradeCutoffs.length == (gradeChart.length - 1), "setGradeCutoffs");
        courses[courseID].gradeCutoffs = gradeCutoffs;
        added = true;
    }

    function calculateTotal (bytes32 courseID) private returns (bool added) {
        require (courseIds[courseID] && (courseInstructor[courseID] == msg.sender), "calculateTotal");
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
              courses[courseID].totalMarksList[k] = courses[courseID].totalMarks[courses[courseID].rollList[k]];
        }
        added = true;
    }

    function calculateGrades (bytes32 courseID, bytes32[] examIDList, uint[] weightageList, uint[] gradeCutoffs) public returns (bool added) {
        require (courseIds[courseID] && (courseInstructor[courseID] == msg.sender), "calculateGrades");
        setWeightages(courseID, examIDList, weightageList);
        setGradeCutoffs(courseID, gradeCutoffs);
        calculateTotal(courseID);
        for (uint i = 0; i < courses[courseID].rollList.length; i++) {
            for (uint j = 0; j < courses[courseID].gradeCutoffs.length; j++) {
                bytes32 roll_no = courses[courseID].rollList[i];
                if (courses[courseID].totalMarks[roll_no] >= courses[courseID].gradeCutoffs[j]) {
                    courses[courseID].gradeList.push(gradeChart[j]);
                    courses[courseID].grades[roll_no] = gradeChart[j];
                    break;
                }
            }
        }
        added = true;
    }

    function getProfExamWeightages (bytes32 courseID) public returns (bytes32[] examslist, uint[] weightages) {
        require (courseIds[courseID] && (courseInstructor[courseID] == msg.sender), "getProfExamWeightages");
        examslist = courses[courseID].examIDList;
        weightages = courses[courseID].weightageList;
    }

    function getProfCompleteScoreSheet (bytes32 courseID) public returns (bytes32[] rolllist, bytes32[] examslist, uint[] weightages, uint[] maxMarkslist, uint[][] markslist, uint[] totalmarks, uint[] grades) {
        require (courseIds[courseID] && (courseInstructor[courseID] == msg.sender), "getProfGrades");
        examslist = courses[courseID].examIDList;
        rolllist = courses[courseID].rollList;
        weightages = courses[courseID].weightageList;
        totalmarks = courses[courseID].totalMarksList;
        maxMarkslist = courses[courseID].maxMarksList;
        grades = courses[courseID].gradeList;
        markslist = courses[courseID].marksList;
    }

    function getStudentMarksGrades (bytes32 courseID, bytes32 rollNo) public returns (bytes32[] examslist, uint[] weightages, uint[] maxMarkslist, uint[] markslist, uint totalmarks, uint grade) {
        require (courseIds[courseID] && ((courseInstructor[courseID] == msg.sender) || courses[courseID].studentAddrVer[msg.sender]) && courses[courseID].rollNoVer[rollNo], "getStudentMarks");
        examslist = courses[courseID].examIDList;
        weightages = courses[courseID].weightageList;
        maxMarkslist = courses[courseID].maxMarksList;
        for (uint i = 0; i < courses[courseID].rollList.length; i++) {
            if (courses[courseID].rollList[i] == rollNo)
                markslist = courses[courseID].marksList[i];
        }
        totalmarks = courses[courseID].totalMarks[rollNo];
        grade = courses[courseID].grades[rollNo];
    }

    function getProfMarksGrades (bytes32 courseID) public returns (bytes32[] rolllist, uint[] totalmarks, uint[] gradelist) {
        require (courseIds[courseID] && (courseInstructor[courseID] == msg.sender), "getProfGrades");
        rolllist = courses[courseID].rollList;
        totalmarks = courses[courseID].totalMarksList;
        gradelist = courses[courseID].gradeList;
    }
}
