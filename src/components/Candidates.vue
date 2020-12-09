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
                            <th scope="col" v-if="showResults">Score</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="(candidate, index) in candidates" :key="candidate.address">
                            <td class="d-flex flex-column">
                                <b-button variant="outline-primary" :disabled="index === 0" @click="up(index)">↑</b-button>
                                <b-button variant="outline-primary" :disabled="index === candidates.length - 1" @click="down(index)">↓</b-button>
                            </td>
                            <td>{{ candidate.name }}</td>
                            <td>{{ candidate.address }}</td>
                            <td v-if="showResults">{{ candidate.voteCount }}</td>
                        </tr>
                    </tbody>
                </table>
            </b-col>
        </b-row>
        <b-row>
            <b-col class="d-flex justify-content-center">
                <b-button variant="success" @click="vote" :disabled="voted">{{ voteBtnText }}</b-button>
            </b-col>
        </b-row>
    </div>
</template>

<script>
    export default {
        name: 'Candidates',
        props: {
            disabled: { type: Boolean, default: false },
            showResults: { type: Boolean, default: false },
        },
        data () {
            return {
                candidates: [
                    {name: "Jean-Marie Le Pen", address: "ausekour"},
                    {name: "Jean-Luc Mélanchon", address: "larepubliquecmoi"},
                    {name: "Emmanuel Macron", address: "parcequecestnotreprojet"},
                ],
                voted: false,
                voteBtnText: "Voter !"
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
                const adresses = []
                for(let i in this.candidates) {
                    adresses.push(this.candidates[i].address)
                }
                // TODO update this
                window.contract.methods.vote_to(this.candidates.map(c => c.address)).send({ value: 0, from: window.accountManager.getActiveAccount(), gas: 4700000 }, result => {
                    if (result instanceof Error) {
                        console.error(result)
                    } else {
                        this.voteBtnText = 'A voté !'
                        this.voted = true
                    }
                })
            },
            refresh() {
                // TODO update this
                // window.contract.methods.get_candidates(this.firstRound).call()
                // .then(result => {
                //     const candidates = []

                //     for (let key in result) {
                //         const c = result[key]
                //         candidates.push({ address: c[0], voteCount: parseInt(c[1]), name: c[2] })
                //     }

                //     let total = 0
                //     for (let key in candidates) {
                //         total += candidates[key].voteCount
                //     }

                //     for (let key in candidates) {
                //         const candidate = candidates[key]
                //         candidate.voteCount = candidate.voteCount / total * 100
                //     }

                //     this.candidates = candidates

                //     if (callback !== undefined) {
                //         callback(candidates)
                //     }
                // })
                // .catch(error => {
                //     this.candidates = []
                //     console.error(error)
                // })
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
