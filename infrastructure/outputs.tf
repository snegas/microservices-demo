output "account_status" {
    value = data.digitalocean_account.current.status
    description = "Status of the current account"
}