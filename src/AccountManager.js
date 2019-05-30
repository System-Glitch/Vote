class AccountManager {
    constructor () {
        this.accounts = []
        this.selectedAccount = -1
    }

    accounts () {
        return this.accounts
    }

    selectedAccount () {
        return this.selectedAccount
    }

    getActiveAccount () {
        return this.accounts[this.selectedAccount]
    }
}

export default AccountManager
