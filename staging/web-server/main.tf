
module "web_server" {
  source = "../../modules/web-server"

  # Variables
  cluster_name           = "web_server-prod"
  db_remote_state_bucket = "terraform-up-and-running-state-for-maryam"
  db_remote_state_key    = "staging/data-stores/terraform.tfstate"
}
