#call ec2-module
module "servers" {
  source = "github.com/Priyadarshini916/infrastructure-as-code.git/modules/ec2"
 
  image_id = var.image_id 
  instance_type = var.instance_type
  key_name =   var.key_name
  vpc_id =  var.vpc_id
  vpc_zone_identifier = var.vpc_zone_identifier
  
}