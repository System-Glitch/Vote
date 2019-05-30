<template>
    <div class="vote-form">
        <b-row align-v="center">
            <b-col>
                <table class="table table-striped table-hover">
                    <thead class="thead-dark">
                        <tr>
                            <th scope="col">Nom</th>
                            <th scope="col">Adresse</th>
                            <th scope="col" v-if="showResults"></th>
                            <th scope="col"></th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="candidate in candidates" :key="candidate.address">
                            <td>{{ candidate.name }}</td>
                            <td>{{ candidate.address }}</td>
                            <td v-if="showResults">{{ candidate.voteCount }}%</td>
                            <td>
                                <b-button
                                variant="success"
                                :disabled="voted || disabled"
                                @click="vote($event, candidate)">Voter</b-button>
                            </td>
                        </tr>
                    </tbody>
                </table>
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
            firstRound: { type: Boolean, default: true }
        },
        data () {
            return {
                candidates: [],
                voted: false
            }
        },
        methods: {
            vote: function (e, candidate) {
                window.contract.methods.vote_to(candidate.address).send({ value: 0, from: window.accountManager.getActiveAccount(), gas: 4700000 }, result => {
                    if (result instanceof Error) {
                        console.error(result)
                    } else {
                        e.target.textContent = 'A voté !'
                        this.voted = true
                    }
                })
            },
            refresh: function (callback) {
                window.contract.methods.get_candidates(this.firstRound).call()
                .then(result => {
                    const candidates = []

                    for (let key in result) {
                        const c = result[key]
                        candidates.push({ address: c[0], voteCount: parseInt(c[1]), name: c[2] })
                    }

                    let total = 0
                    for (let key in candidates) {
                        total += candidates[key].voteCount
                    }

                    for (let key in candidates) {
                        const candidate = candidates[key]
                        candidate.voteCount = candidate.voteCount / total * 100
                    }

                    this.candidates = candidates

                    if (callback !== undefined) {
                        callback(candidates)
                    }
                })
                .catch(error => {
                    this.candidates = []
                    console.error(error)
                })
            }
        },
        mounted () {
            this.refresh()
        }
    }
</script>

<style lang="scss">
.table td {
    vertical-align: unset;
}
</style>
