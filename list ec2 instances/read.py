import json

# Load the Terraform JSON output into a Python object
with open('terraform.tfstate') as file:
    data = json.load(file)

# Extract the list of instance IDs
instance_ids = list(data["outputs"]["stopped_instances"]["value"])

print(len(instance_ids))
print(instance_ids[12])