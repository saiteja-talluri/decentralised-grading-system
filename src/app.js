App = {
  loading: false,
  contracts: {},

  load: async () => {
    await App.loadWeb3()
    await App.loadAccount()
    await App.loadContract()
  },

  loadWeb3: async () => {
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider
      web3 = new Web3(web3.currentProvider)
    } else {
      window.alert("Please connect to Metamask.")
    }
    // Modern dapp browsers...
    if (window.ethereum) {
      window.web3 = new Web3(ethereum)
      try {
        // Request account access if needed
        await ethereum.enable()
        // Acccounts now exposed
        web3.eth.sendTransaction({/* ... */})
      } catch (error) {
        // User denied account access...
      }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
      App.web3Provider = web3.currentProvider
      window.web3 = new Web3(web3.currentProvider)
      // Acccounts always exposed
      web3.eth.sendTransaction({/* ... */})
    }
    // Non-dapp browsers...
    else {
      console.log('Non-Ethereum browser detected. You should consider trying MetaMask!')
    }
  },

  loadAccount: async () => {
    // Set the current blockchain account
    App.account = web3.eth.accounts[0]
  },

  loadContract: async () => {
    // Create a JavaScript version of the smart contract
    const grader = await $.getJSON('Grader.json')
    App.contracts.Grader = TruffleContract(grader)
    App.contracts.Grader.setProvider(App.web3Provider)

    // Hydrate the smart contract with values from the blockchain
    App.grader = await App.contracts.Grader.deployed()
  },

  addInstructorFun: async () => {
    const addresses = $('#addInstructorInp0').val()
    var adr_ar = addresses.split(",")
    await App.grader.addInstructor(adr_ar)
    $('.formClass').trigger('reset')
  },

  getInstructorsListFun: async () => {
    await App.grader.getInstructorsList().then(l => {
      var log = ""
      for (index = 0; index < l.length; index++){
        log += l[index] + "\n"
      }
      $('#getInstructorsListResult').text(log)
      console.log(log)
    })
    $('.formClass').trigger('reset')
  },

  addCourseFun: async () => {
    var course_id = web3.fromAscii($('#addCourseInp0').val())
    var course_name = $('#addCourseInp1').val()
    var roll_list = $('#addCourseInp2').val().split(",").map(i => web3.fromAscii(i))
    console.log(roll_list)
    var stud_addr = $('#addCourseInp3').val().split(",")
    var ta_addr = $('#addCourseInp4').val().split(",")
    $('.formClass').trigger('reset')
    await App.grader.addCourse(course_id,course_name,roll_list,stud_addr,ta_addr)
  },

  addExamFun: async () => {
    var course_id = web3.fromAscii($('#addExamInp0').val())
    var exam_id = web3.fromAscii($('#addExamInp1').val())
    var max_marks = parseInt($('#addExamInp2').val())
    var roll_list = $('#addExamInp3').val().split(",").map(i => web3.fromAscii(i))
    var marks_list = $('#addExamInp4').val().split(",").map(i => parseInt(i))
    $('.formClass').trigger('reset')
    await App.grader.addExam(course_id,exam_id,max_marks,roll_list,marks_list)
  },

  updateMarksFun: async () => {
    var course_id = web3.fromAscii($('#updateMarksInp0').val())
    var exam_id = web3.fromAscii($('#updateMarksInp1').val())
    var roll_list = $('#updateMarksInp2').val().split(",").map(i => web3.fromAscii(i))
    var marks_list = $('#updateMarksInp3').val().split(",").map(i => parseInt(i))
    $('.formClass').trigger('reset')
    await App.grader.updateMarks(course_id,exam_id,roll_list,marks_list)
  },

  calculateGradesFun: async () => {
    var course_id = web3.fromAscii($('#calculateGradesInp0').val())
    var weightage_list = $('#calculateGradesInp1').val().split(",").map(i => parseInt(i))
    var grade_cutoffs = $('#calculateGradesInp2').val().split(",").map(i => parseInt(i))
    $('.formClass').trigger('reset')
    await App.grader.calculateGrades(course_id,weightage_list,grade_cutoffs)
  },

  getProfExamMarksFun: async () => {
    var course_id = web3.fromAscii($('#getProfExamMarksInp0').val())
    var exam_id = web3.fromAscii($('#getProfExamMarksInp1').val())
    await App.grader.getProfExamMarks(course_id,exam_id).then(output => {
      console.log(output)
      var log = "Max Marks = " + output[2].toString() + " \nWeightage = " + output[3].toString() + "\n"
      for (index = 0; index < output[0].length; index++) {
        log += web3.toUtf8(output[0][index]) + " - " + output[1][index] + "\n"
      }
      $('#getProfExamMarksResult').text(log)
      console.log(log)
    })
    $('.formClass').trigger('reset')
  },

  getProfExamWeightagesFun: async () => {
    var course_id = web3.fromAscii($('#getProfExamWeightagesInp0').val())
    await App.grader.getProfExamWeightages(course_id).then(output => {
      if (output[0].length > 0)
        exams_list = web3.toUtf8(output[0][0])
      for (index = 1; index < output[0].length; index++) {
        exams_list += ","
        exams_list += web3.toUtf8(output[0][index])
      }
      var log = "Exams List = " + exams_list + " \nMax Marks = " + output[1].toString() + " \nWeightages = " + output[2].toString()
      $('#getProfExamWeightagesResult').text(log)
      console.log(log)
    })
    $('.formClass').trigger('reset')
  },

  getProfMarksGradesFun: async () => {
    var course_id = web3.fromAscii($('#getProfMarksGradesInp0').val())
    await App.grader.getProfMarksGrades(course_id).then(output => {
      var log = ""
      for (index = 0; index < output[0].length; index++) {
        log += web3.toUtf8(output[0][index]) + " - " + output[1][index] + " - " + output[2][index] + "\n"
      }
      $('#getProfMarksGradesFormResult').text(log)
      console.log(log)
    })
    $('.formClass').trigger('reset')
  },

  getStudentMarksGradesFun: async () => {
    var course_id = web3.fromAscii($('#getStudentMarksGradesInp0').val())
    var roll_no = web3.fromAscii($('#getStudentMarksGradesInp1').val())
    await App.grader.getStudentMarksGrades(course_id, roll_no).then(output => {
      if (output[0].length > 0)
        exams_list = web3.toUtf8(output[0][0])
      for (index = 1; index < output[0].length; index++) {
        exams_list += ","
        exams_list += web3.toUtf8(output[0][index])
      }
      var log = "Exams List = " + exams_list + " \nMax Marks = " + output[1].toString() + " \nWeightages = " + output[2].toString() + "\n"
      log += "Marks = " + output[3].toString() + "\nTotal Marks = " + output[4].toString() + "\nGrade = " + output[5].toString()
      $('#getStudentMarksGradesResult').text(log)
      console.log(log)
    })
    $('.formClass').trigger('reset')
  }
}

$(() => {
  $(window).load(() => {
    App.load()
  })
})
