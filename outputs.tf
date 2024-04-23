output "group2_users_keybase_password_decrypt_command" {
  value = values(module.users_group2).*.keybase_password_decrypt_command
}

output "group1_users_keybase_secret_key_decrypt_command" {
  value = values(module.users_group2).*.keybase_secret_key_decrypt_command
}

output "group1_users_key_id" {
  value = values(module.users_group2).*.iam_access_key_id
}
