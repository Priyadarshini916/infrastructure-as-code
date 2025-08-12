vpc_cidr_block = "10.81.0.0/16"
pub_rt = "0.0.0.0/0"
pvt_rt = "0.0.0.0/0" 
availability_zones = [ "us-east-1a", "us-east-1b", "us-east-1c" ]
private_subnet_cidrs = [ "10.81.7.0/24", "10.81.8.0/24"]
public_subnet_cidrs = ["10.81.6.0/24", "10.81.5.0/24"]

#to add different routes for different users

user_routes = {
    
    "rtb-046926e5e86f8af4d" ={
    
    destination_cidr_block = "0.0.0.0/0"
    gateway_id            = "igw-027198fb4883d1606"
    nat_gateway_id = null
    }
    
    }
   
    




