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
    $('.formClass').trigger('reset')
    const addresses = $('#addInstructorInp0').val()
    var adr_ar = addresses.split(",")
    await App.grader.addInstructor(adr_ar)
  },

  getInstructorsListFun: async () => {
    $('.formClass').trigger('reset')
    await App.grader.getInstructorsList().then(l => {
      $('#getInstructorsListResult').text(l)
      console.log(l)
    })
  },

  addCourseFun: async () => {
    $('.formClass').trigger('reset')
    var course_id = web3.toHex($('#addCourseInp0').val())
    var course_name = $('#addCourseInp1').val()
    var roll_list = $('#addCourseInp2').val().split(",").map(i => web3.toHex(i))
    var stud_addr = $('#addCourseInp3').val().split(",")
    var ta_addr = $('#addCourseInp4').val().split(",")
    await App.grader.addCourse(course_id,course_name,roll_list,stud_addr,ta_addr)
  },

  addExamFun: async () => {
    $('.formClass').trigger('reset')
    var course_id = web3.toHex($('#addExamInp0').val())
    var exam_id = web3.toHex($('#addExamInp1').val())
    var max_marks = parseInt($('#addExamInp2').val())
    var roll_list = $('#addExamInp3').val().split(",").map(i => web3.toHex(i))
    var marks_list = $('#addExamInp4').val().split(",").map(i => parseInt(i))
    await App.grader.addExam(course_id,exam_id,max_marks,roll_list,marks_list)
  },

  updateMarksFun: async () => {
    $('.formClass').trigger('reset')
    var course_id = web3.toHex($('#updateMarksInp0').val())
    var exam_id = web3.toHex($('#updateMarksInp1').val())
    var roll_list = $('#updateMarksInp2').val().split(",").map(i => web3.toHex(i))
    var marks_list = $('#updateMarksInp3').val().split(",").map(i => parseInt(i))
    await App.grader.updateMarks(course_id,exam_id,roll_list,marks_list)
  },

  calculateGradesFun: async () => {
    var course_id = web3.toHex($('#calculateGradesInp0').val())
    var weightage_list = $('#calculateGradesInp1').val().split(",").map(i => parseInt(i))
    var grade_cutoffs = $('#calculateGradesInp2').val().split(",").map(i => parseInt(i))
    await App.grader.calculateGrades(course_id,weightage_list,grade_cutoffs)
  },

  getProfExamMarksFun: async () => {
    $('.formClass').trigger('reset')
    var course_id = web3.toHex($('#getProfExamMarksInp0').val())
    var exam_id = web3.toHex($('#getProfExamMarksInp1').val())
    await App.grader.getProfExamMarks(course_id,exam_id).then(output => {
      rl = output[0].map(i => web3.toAscii(i.toString()).toString())
      console.log(rl.toString())
      console.log(output[1].toString())
      console.log(output[2].toString())
      console.log(output[3].toString())
    })
  },

  getProfExamWeightagesFun: async () => {
    $('.formClass').trigger('reset')
    var course_id = web3.toHex($('#getProfExamWeightagesInp0').val())
    await App.grader.getProfExamWeightages(course_id).then((exams,maxmarks,weightages) => {
      exams_list = exams.map(i => web3.toAscii("$i"))
      console.log(exams_list)
      console.log(maxmarks)
      console.log(weightages)
    })
  },

  getProfMarksGradesFun: async () => {
    $('.formClass').trigger('reset')
    var course_id = web3.toHex($('#getProfMarksGradesInp0').val())
    await App.grader.getProfMarksGrades(course_id).then((roll_list,totalmarks,grades) => {
      rl = roll_list.map(i => web3.toAscii(i))
      console.log(rl)
      console.log(maxmarks)
      console.log(weightages)
    })
  },

  getStudentMarksGradesFun: async () => {
    $('.formClass').trigger('reset')
    var course_id = web3.toHex($('#getStudentMarksGradesInp0').val())
    var roll_no = web3.toHex($('#getStudentMarksGradesInp1').val())
    await App.grader.getStudentMarksGrades(course_id, roll_no).then((el,wl,mml,ml,tm,gr) => {
      exams_list = el.map(i => web3.toAscii(i))
      console.log(exams_list)
      console.log(wl)
      console.log(mml)
      console.log(ml)
      console.log(tm)
      console.log(gr)
    })
  }
}

$(() => {
  $(window).load(() => {
    App.load()
  })
})
