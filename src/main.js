import Vue from 'vue'
import {BCard, BCol, BRow, BButton, BForm, BFormGroup, BFormInput} from 'bootstrap-vue'
import App from './App.vue'

import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue/dist/bootstrap-vue.css'
require('./sass/app.scss')

window.Vue = Vue
Vue.component("b-card", BCard)
Vue.component("b-col", BCol)
Vue.component("b-row", BRow)
Vue.component("b-button", BButton)
Vue.component("b-form", BForm)
Vue.component("b-form-group", BFormGroup)
Vue.component("b-form-input", BFormInput)

Vue.config.productionTip = false

const Web3 = require('web3')

if (window.ethereum) {
    window.web3 = new Web3(window.ethereum)
    try {
        window.ethereum.enable()
    } catch (error) {
        console.error('Providers Error : ' + error)
    }
}

// Load all components
const files = require.context('./', true, /\.vue$/i)
files.keys().map(key => Vue.component(key.split('/').pop().split('.')[0].toLowerCase(), files(key).default))

new Vue({
    render: h => h(App)
}).$mount('#app')
