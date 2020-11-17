<template>
    <section class="container">
        <b-card id="app">
            <h1 class="logo-header" slot="header"><img src="~@/assets/logo.png" class="logo"><span>Vote</span></h1>

            <voteform :disabled="state >= 0" @submit="refresh"/>
            <template v-if="state >= 0">
                <standform v-if="state >= 0" @submit="refresh" @refresh="refresh"/>

                <hr>
                <h3>Premier tour</h3>
                <candidates v-if="state >= 0" :disabled="state != 1" :showResults="state > 1" ref="candidates"/>
                <b-row v-if="winnerFirstRound && state > 1">
                    <b-col>
                        <h4 class="text-center">Élu au premier tour : <b>{{ winnerFirstRound.name }}</b> avec <b>{{ winnerFirstRound.voteCount }}%</b> des voix.</h4>
                    </b-col>
                </b-row>
            </template>
            <template v-if="state > 1">
                <hr>
                <h3>Second tour</h3>
                <candidates :disabled="state > 2" :showResults="state > 2" :firstRound="false" ref="candidatesRound2"/>
                <b-row v-if="winnerSecondRound && state > 2">
                    <b-col>
                        <h4 class="text-center">Élu au scond tour : <b>{{ winnerSecondRound.name }}</b> avec <b>{{ winnerSecondRound.voteCount }}%</b> des voix.</h4>
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
                winnerFirstRound: null,
                winnerSecondRound: null,
                state: -1
            }
        },
        methods: {
            refresh: function () {
                if (window.contract) {
                    window.contract.methods.get_vote_state.call()
                    .then(result => {
                        this.state = result

                        this.$nextTick(() => {
                            if (this.state >= 0) {
                                this.$refs.candidates.refresh(candidates => this.refreshWinner(true, candidates))
                            }

                            if (this.state > 2) {
                                this.$refs.candidatesRound2.refresh(candidates => this.refreshWinner(false, candidates))
                            }
                        })
                    })
                    .catch(error => {
                        this.state = -1
                        console.error(error)
                    })
                }
            },
            refreshWinner: function (firstRound, candidates) {
                let max = 0
                let maxCandidate = null
                for (let key in candidates) {
                    const candidate = candidates[key]
                    if (candidate.voteCount > max) {
                        max = candidate.voteCount
                        maxCandidate = candidate
                    }
                }

                if (firstRound) {
                    this.winnerFirstRound = maxCandidate
                } else {
                    this.winnerSecondRound = maxCandidate
                }
            }
        },
        mounted() {
            this.intervalID = setInterval(() => {
                this.$nextTick(() => {
                    this.refresh()
                })
            }, 5000)
        },
        beforeDestroy() {
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
