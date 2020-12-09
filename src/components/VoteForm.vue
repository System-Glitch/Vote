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
                <b-button variant="success" @click="submit" :disabled="disabled" class="mt-3">Valider</b-button>
            </b-col>
            <b-col>
                <b-button variant="success" @click="deploy" :disabled="disabled" class="mt-3">Créer un nouveau vote</b-button>
            </b-col>
        </b-row>
    </div>
</template>

<script>
import abi from "../abi.json"
import bytecode from "../bytecode.json"

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
        setAddress() {
            window.contract = new window.web3.eth.Contract(abi, this.contractAddress)
        },
        submit() {
            this.setAddress()
            this.$emit('submit')
        },
        deploy() {
            window.web3.eth.getAccounts().then((accounts) => {
                const contract = new window.web3.eth.Contract(abi, undefined, {transactionConfirmationBlocks: 1});
                contract.deploy({data: bytecode.object}).send({ value: 0, from: accounts[0], gas: 4700000 })
                .then(contract => {
                    this.contractAddress = contract.options.address
                    this.submit()
                })
                .catch(error => console.err(error))
            })
        }
    }
}
</script>
