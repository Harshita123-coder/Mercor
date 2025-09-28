variable "name_prefix" { 
  type = string 
}

variable "repo_name" { 
  type = string 
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
