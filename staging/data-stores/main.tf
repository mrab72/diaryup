module "db" {
  source      = "../../modules/data-stores"

  # Variables
  db_password = "test_password"
}
