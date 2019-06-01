import Vue from 'vue'
import BootstrapVue from 'bootstrap-vue'
import App from './App.vue'
import AccountManager from './AccountManager.js'

import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue/dist/bootstrap-vue.css'
require('./sass/app.scss')

window.Vue = Vue
Vue.use(BootstrapVue)

Vue.config.productionTip = false

window.accountManager = new AccountManager()

const Web3 = require('web3')
window.Web3 = Web3

if (window.ethereum) {
    window.web3 = new Web3(window.ethereum)
    try {
        window.ethereum.enable()
    } catch (error) {
        console.error('Providers Error : ' + error)
    }
} else {
    window.web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'))
}

window.web3.eth.getAccounts()
.then((accounts) => {
    const temp = []
    for (let key in accounts) {
        const account = accounts[key]
        temp.push(account)
    }
    if (window.accountManager.accounts.length === 0) {
        window.accountManager.selectedAccount = 0
    }
    window.accountManager.accounts = temp
})
.catch((error) => {
    console.error("Couldn't fetch accounts: " + error.message)
})

// Load all components
const files = require.context('./', true, /\.vue$/i)
files.keys().map(key => Vue.component(key.split('/').pop().split('.')[0].toLowerCase(), files(key).default))

new Vue({
    render: h => h(App)
}).$mount('#app')
