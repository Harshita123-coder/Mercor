variable "name_prefix" { 
  type = string 
}

variable "vpc_id" { 
  type = string 
}

variable "subnet_ids" { 
  type = list(string) 
}

variable "port" { 
  type = number 
}

variable "health_path" { 
  type = string 
}
