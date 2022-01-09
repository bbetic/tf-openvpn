terraform {
  backend "http" {
    
  }
  experiments = [module_variable_optional_attrs]

}
provider "aws" {
  region = "us-east-1"
}