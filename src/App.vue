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
                <standform v-if="state >= 0" @submit="refresh" @refresh="refresh"/>

                <hr>
                <candidates v-if="state >= 0" :disabled="state != 1" :showResults="state > 1" ref="candidates"/>
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
                state: 0
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
                                this.$refs.candidates.refresh(candidates => this.refreshWinner(candidates))
                            }
                        })
                    })
                    .catch(error => {
                        this.state = -1
                        console.error(error)
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
