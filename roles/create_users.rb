name        "create_users"
description "create users configuration"

run_list    "recipe[user]",
            "recipe[sudo]",
            "recipe[openssh]",
            "recipe[create_working_user]"

default_attributes(
  "authorization" => {
    "sudo" => {
      "users" => [ "john" ],   
      "passwordless" => true
    }
  },
  "openssh" => {
    "server" => {
      "permit_root_login" => "no", 
      "password_authentication" => "no"
    }
  }
)
