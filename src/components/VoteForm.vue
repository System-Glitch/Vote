<template>
    <div class="vote-form">
        <b-row align-v="center">
            <b-col>
                <b-form-group
                label="Adresse du Smart Contract"
                label-for="input-contract-address">
                    <b-form-input
                    v-model="contractAddress"
                    :disabled="disabled"
                    id="input-contract-address"
                    required
                    placeholder="Adresse"
                    />
                </b-form-group>
            </b-col>

            <b-col>
                <b-form-group
                label="Numéro de compte"
                label-for="input-contract-account">
                    <b-form-input
                    v-model="account"
                    :disabled="disabled"
                    type="number"
                    required
                    placeholder="Compte"
                    />
                </b-form-group>
            </b-col>

            <b-col>
                <b-button variant="success" @click="submit" :disabled="disabled" class="mt-3">Valider</b-button>
            </b-col>
        </b-row>
    </div>
</template>

<script>
    export default {
        name: 'VoteForm',
        props: {
            disabled: { type: Boolean, default: false }
        },
        data () {
            return {
                contractAddress: '',
                account: 0
            }
        },
        methods: {
            setAddress: function () {
                const abi = require('../abi.json')
                window.contract = new window.web3.eth.Contract(abi, this.contractAddress)
            },
            setAccount: function () {
                window.accountManager.selectedAccount = this.account
            },
            submit: function () {
                this.setAddress()
                this.setAccount()
                this.$emit('submit')
            }
        }
    }
</script>

<style lang="scss">
</style>
