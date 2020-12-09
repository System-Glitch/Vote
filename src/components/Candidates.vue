<template>
    <div class="vote-form">
        <b-row align-v="center">
            <b-col>
                <table class="table table-striped table-hover">
                    <thead class="thead-dark">
                        <tr>
                            <th scope="col" class="selection-btn-container">Sélection</th>
                            <th scope="col">Nom</th>
                            <th scope="col">Adresse</th>
                            <th scope="col" v-if="state > 1">Score</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="(candidate, index) in displayCandidates" :key="candidate.address">
                            <td class="d-flex flex-column">
                                <b-button variant="outline-primary" :disabled="index === 0" @click="up(index)">↑</b-button>
                                <b-button variant="outline-primary" :disabled="index === candidates.length - 1" @click="down(index)">↓</b-button>
                            </td>
                            <td>{{ candidate.name }}</td>
                            <td>{{ candidate.address }}</td>
                            <td v-if="state > 1">{{ candidate.score }}</td>
                        </tr>
                    </tbody>
                </table>
            </b-col>
        </b-row>
        <b-row>
            <b-col class="d-flex justify-content-center">
                <b-button variant="success" @click="vote" :disabled="voted || state != 1">{{ voteBtnText }}</b-button>
            </b-col>
        </b-row>
    </div>
</template>

<script>
    export default {
        name: 'Candidates',
        props: {
            disabled: { type: Boolean, default: false },
            state: { type: Number, required: true },
        },
        data () {
            return {
                candidates: [],
                voted: false,
                voteBtnText: "Voter !"
            }
        },
        computed: {
            displayCandidates() {
                return this.state == 2 ? this.candidates.slice().sort(this.byScore) : this.candidates
            }
        },
        methods: {
            up(index) {
                const current = this.candidates[index]
                const previous = this.candidates[index-1]
                this.$set(this.candidates, index-1, current)
                this.$set(this.candidates, index, previous)
            },
            down(index) {
                const current = this.candidates[index]
                const next = this.candidates[index+1]
                this.$set(this.candidates, index+1, current)
                this.$set(this.candidates, index, next)
            },
            vote() {
                window.web3.eth.getAccounts().then((accounts) => {
                    window.contract.methods.vote_to(this.candidates.map(c => c.address)).send({ value: 0, from: accounts[0], gas: 4700000 }, result => {
                        if (result instanceof Error) {
                            console.error(result)
                        } else {
                            this.voteBtnText = 'A voté !'
                            this.voted = true
                        }
                    })
                })
            },
            refresh(callback) {
                window.web3.eth.getAccounts().then((accounts) => {
                    window.contract.methods.get_candidates().call({from: accounts[0]}, (error, result) => {
                        if (error) {
                            this.candidates = []
                            console.error(error)
                        } else {
                            const candidates = []
        
                            for (let key in result) {
                                const c = result[key]
                                candidates.push({ address: c[0], score: parseInt(c[1]), name: c[2] })
                            }
        
                            candidates.forEach(c => {
                                const candidate = this.candidates.find(cc => c.address === cc.address)
                                if(!candidate) {
                                    this.candidates.push(c)
                                } else {
                                    candidate.score = c.score
                                }
                            })

                            if (callback !== undefined) {
                                callback(this.candidates)
                            }
                        }
                    })
                })
            },
            byScore(a, b) {
                if(a.score === b.score) {
                    return 0
                }

                return a.score > b.score ? -1 : 1
            }
        },
        mounted () {
            this.refresh()
        }
    }
</script>

<style lang="scss" scoped>
.table td {
    vertical-align: middle;
}

.selection-btn-container {
    width: 1px;
}
</style>
