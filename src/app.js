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

  // renderTasks: async () => {
  //   // Load the total task count from the blockchain
  //   const taskCount = await App.grader.taskCount()
  //   const $taskTemplate = $('.taskTemplate')

  //   // Render out each task with a new task template
  //   for (var i = 1; i <= taskCount; i++) {
  //     // Fetch the task data from the blockchain
  //     const task = await App.grader.tasks(i)
  //     const taskId = task[0].toNumber()
  //     const taskContent = task[1]
  //     const taskCompleted = task[2]

  //     // Create the html for the task
  //     const $newTaskTemplate = $taskTemplate.clone()
  //     $newTaskTemplate.find('.content').html(taskContent)
  //     $newTaskTemplate.find('input')
  //                     .prop('name', taskId)
  //                     .prop('checked', taskCompleted)
  //                     // .on('click', App.toggleCompleted)

  //     // Put the task in the correct list
  //     if (taskCompleted) {
  //       $('#completedTaskList').append($newTaskTemplate)
  //     } else {
  //       $('#taskList').append($newTaskTemplate)
  //     }

  //     // Show the task
  //     $newTaskTemplate.show()
  //   }
  // },

  addInstructorFun: async () => {
    const addresses = $('#addInstructorInp0').val()
    var adr_ar = addresses.split(",")
    await App.grader.addInstructor(adr_ar)
  },

  getInstructorsList: async () => {
    await App.grader.getInstructorsList().then(l => {
      console.log(l)
    })
  },

  addCourseFun: async () => {
    var course_id = web3.utils.asciiToHex($('#addCourseInp0').val())
    var course_name = $('#addCourseInp1').val()
    var roll_list = $('#addCourseInp2').val().split(",").map(i => web3.utils.asciiToHex(i))
    var stud_addr = $('#addCourseInp3').val().split(",")
    var ta_addr = $('#addCourseInp4').val().split(",")
    await App.grader.addCourse(course_id,course_name,roll_list,stud_addr,ta_addr)
  },

  addExamFun: async () => {
    var course_id = web3.utils.asciiToHex($('#addExamInp0').val())
    var exam_id = web3.utils.asciiToHex($('#addExamInp1').val())
    var max_marks = parseInt($('#addExamInp2').val())
    var roll_list = $('#addExamInp3').val().split(",").map(i => web3.utils.asciiToHex(i))
    var marks_list = $('#addExamInp4').val().split(",").map(i => parseInt(i))
    await App.grader.addExam(course_id,exam_id,max_marks,roll_list,marks_list)
  },

  updateMarksFun: async () => {
    var course_id = web3.utils.asciiToHex($('#updateMarksInp0').val())
    var exam_id = web3.utils.asciiToHex($('#updateMarksInp1').val())
    var roll_list = $('#updateMarks2').val().split(",").map(i => web3.utils.asciiToHex(i))
    var marks_list = $('#updateMarks3').val().split(",").map(i => parseInt(i))
    await App.grader.updateMarks(course_id,exam_id,roll_list,marks_list)
  },

  calculateGradesFun: async () => {
    var course_id = web3.utils.asciiToHex($('#calculateGradesInp0').val())
    var weightage_list = $('#calculateGradesInp1').val().split(",").map(i => parseInt(i))
    var grade_cutoffs = $('#calculateGradesInp2').val().split(",").map(i => parseInt(i))
    await App.grader.calculateGrades(course_id,weightage_list,grade_cutoffs)
  },

  processProfExamMarks: async (course_id,exam_id) => {
    await App.grader.getProfExamMarks(course_id,exam_id).then(roll_list,marks_list,maxmarks,weightage => {
      rl = roll_list.map(i => web3.utils.hexToAscii(i))
      console.log(rl)
      console.log(marks_list)
      console.log(maxmarks)
      console.log(weightage)
    })
  },

  getProfExamMarksFun: async () => {
    var course_id = web3.utils.asciiToHex($('#getProfExamMarksInp0').val())
    var exam_id = web3.utils.asciiToHex($('#getProfExamMarksInp1').val())
    await App.grader.getInverseMarks(course_id).then(processProfExamMarks(course_id,exam_id))
  },

  getProfExamWeightagesFun: async () => {
    var course_id = web3.utils.asciiToHex($('#getProfExamWeightagesInp0').val())
    await App.grader.getProfExamWeightages(course_id).then(exams,maxmarks,weightages => {
      exams_list = exams.map(i => web3.utils.hexToAscii(i))
      console.log(exams_list)
      console.log(maxmarks)
      console.log(weightages)
    })
  },

  getProfMarksGrades: async () => {
    var course_id = web3.utils.asciiToHex($('#getProfMarksGradesInp0').val())
    await App.grader.getProfMarksGrades(course_id).then(roll_list,totalmarks,grades => {
      rl = roll_list.map(i => web3.utils.hexToAscii(i))
      console.log(rl)
      console.log(maxmarks)
      console.log(weightages)
    })
  },

  getStudentMarksGrades: async () => {
    var course_id = web3.utils.asciiToHex($('#getStudentMarksGradesInp0').val())
    var roll_no = web3.utils.asciiToHex($('#getStudentMarksGradesInp1').val())
    await App.grader.getStudentMarksGrades(course_id, roll_no).then(el,wl,mml,ml,tm,gr => {
      exams_list = el.map(i => web3.utils.hexToAscii(i))
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
