variable "name" {
    type =  string
    description = "short name, used in tags. Example : app "

}

variable "cidr" {
    type = string
    description = "VPC CIDR. Example: 10.1.0.0/16"

}

variable "subnets" {
    type = map(object ({
        cidr = string
        az = string 
        public = bool
    }))
    description = "subnet table: name. -> cidr, az, public"
}