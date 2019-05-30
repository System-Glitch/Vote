<template>
    <div class="vote-form">
        <b-row align-v="center">
            <b-col>
                <b-form-group
                label="Votre nom"
                label-for="input-stand-name">
                    <b-form-input
                    v-model="name"
                    id="input-stand-name"
                    required
                    placeholder="Nom"
                    :disabled="stood"
                    />
                </b-form-group>
            </b-col>

            <b-col>
                <b-button variant="success" class="mt-3" @click="submit" :disabled="stood">Se présenter</b-button>
            </b-col>
            <b-col>
                <b-button variant="primary" class="mt-3" @click="$emit('refresh')">Rafraichir</b-button>
            </b-col>
        </b-row>
    </div>
</template>

<script>
    export default {
        name: 'StandForm',
        props: {
            disabled: { type: Boolean, default: false }
        },
        data () {
            return {
                name: '',
                stood: false
            }
        },
        methods: {
            submit: function () {
                window.contract.methods.add_candidate(this.name).send({ value: 0, from: window.accountManager.getActiveAccount(), gas: 4700000 }, result => {
                    if (result instanceof Error) {
                        console.error(result)
                    } else {
                        this.stood = true
                        this.$emit('submit')
                    }
                })
            }
        }
    }
</script>

<style lang="scss">
</style>
