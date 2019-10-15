App = {
  loading: false,
  contracts: {},

  load: async () => {
    await App.loadWeb3()
    await App.loadAccount()
    await App.loadContract()
  },

  // https://medium.com/metamask/https-medium-com-metamask-breaking-change-injecting-web3-7722797916a8
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

  getInstructorsList: async () => {
    await App.grader.instructorsList(0).then(l => {
      console.log(l)
    })
  },

  addInstructorFun: async () => {
    const addresses = $('#addInstructorInp0').val()
    var adr_ar = addresses.split(",")
    console.log(web3.eth.accounts[0])
    await App.grader.addInstructor(adr_ar).then(App.getInstructorsList())
  }
}

$(() => {
  $(window).load(() => {
    App.load()
  })
})