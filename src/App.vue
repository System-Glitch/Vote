<template>
    <section class="container">
        <b-card id="app">
            <template #header>
                <h1 class="logo-header">
                    <img src="~@/assets/logo.png" class="logo">
                    <span>Vote</span>
                </h1>
            </template>

            <voteform :disabled="state >= 0" @submit="refresh"/>
            <template v-if="state >= 0">
                <b-row v-if="account === owner && account !== null" class="mb-3">
                    <b-col>
                        <b-button variant="success" @click="startVote" :disabled="state !== 0">Démarrer le vote</b-button>
                    </b-col>
                    <b-col>
                        <b-button variant="success" @click="endVote" :disabled="state !== 1">Arrêter le vote</b-button>
                    </b-col>
                </b-row>
                <standform v-if="state >= 0" @submit="refresh" @refresh="refresh"/>

                <hr>
                <candidates v-if="state >= 0" :disabled="state != 1" :state="state" ref="candidates"/>
                <b-row v-if="winner && state > 1">
                    <b-col>
                        <h4 class="text-center">Élu : <b>{{ winner.name }}</b> avec <b>{{ winner.score }}</b> points.</h4>
                    </b-col>
                </b-row>
            </template>
        </b-card>
    </section>
</template>

<script>
    export default {
        name: 'app',
        data () {
            return {
                winner: null,
                account: null,
                owner: null,
                state: -1
            }
        },
        methods: {
            refresh: function () {
                if (window.contract) {
                    window.web3.eth.getAccounts().then((accounts) => {
                        this.account = accounts[0]
                        window.contract.methods.owner().call({from: this.account}, (error, result) => {
                            if (error) {
                                this.owner = null
                                console.error(error)
                            } else {
                                this.owner = result
                            }
                        })
                        window.contract.methods.get_vote_state().call({from: this.account}, (error, result) => {
                            if (error) {
                                this.state = -1
                                console.error(error)
                            } else {
                                this.state = parseInt(result)
    
                                this.$nextTick(() => {
                                    if (this.state >= 0) {
                                        this.$refs.candidates.refresh(candidates => this.refreshWinner(candidates))
                                    }
                                })
                            }
                        })
                    })
                }
            },
            refreshWinner: function (candidates) {
                let max = 0
                let maxCandidate = null
                for (let key in candidates) {
                    const candidate = candidates[key]
                    if (candidate.score > max) {
                        max = candidate.score
                        maxCandidate = candidate
                    }
                }

                this.winner = maxCandidate
            },
            startVote() {
                window.contract.methods.start_vote().send({ value: 0, from: this.account, gas: 4700000 }, result => {
                    if (result instanceof Error) {
                        console.error(result)
                    }
                })
            },
            endVote() {
                window.contract.methods.end_vote().send({ value: 0, from: this.account, gas: 4700000 }, result => {
                    if (result instanceof Error) {
                        console.error(result)
                    }
                })
            }
        },
        mounted () {
            this.intervalID = setInterval(() => {
                this.$nextTick(() => {
                    this.refresh()
                })
            }, 5000)
        },
        beforeUnmount () {
            clearInterval(this.intervalID)
        }
    }
</script>

<style lang="scss">
#app {
    font-family: 'Avenir', Helvetica, Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    color: #2c3e50;
    margin-top: 60px;
    margin-bottom: 60px;
}

.logo-header {
    span {
        vertical-align: middle;
    }

    .logo {
        width: 85px;
        height: 85px;
        margin-right: 15px;
        vertical-align: middle;
    }
}

</style>
