# Terraform Deployment: Reverse IP Flask App

This guide explains how to deploy a Docker image App using Terraform in the EC2 instance. 

## Prerequisites

1. AWS account with permissions to create resources.
2. Terraform installed on your local machine.
3. A key pair for EC2 access.
4. Docker installed locally for testing the container.

## Project Structure

```
project-folder/
├── main.tf              # Terraform configuration
├── variables.tf         # Terraform variables
├── outputs.tf           # Terraform outputs
└── README.md            # Project documentation
```

## Steps to Deploy

### 1. Clone the Repository

```bash
git clone <repository-url>
cd project-folder
```


### 2. Initialize Terraform

Run the following command to initialize Terraform:

```bash
terraform init
```

### 3. Validate and Apply Terraform Configuration

To validate the configuration:

```bash
terraform validate
```

To apply the configuration:

```bash
terraform apply
```

Provide `yes` when prompted to create the resources.

### 4. Verify Deployment

1. SSH into the EC2 instance using the public IP and your key pair:
   ```bash
   ssh -i my-key.pem ec2-user@<ec2-public-ip>
   ```

2. Check that the Docker container is running:
   ```bash
   docker ps
   ```

3. Test the Docker app:
   ```bash
   curl http://<elb_dns_name>

   Get elb_dns_name from terraform apply output and chekckout application is working or not
   ```

The app should respond with a reversed IP.

### 5. Clean Up Resources

To destroy the resources and avoid incurring costs:

```bash
terraform destroy
```

## How It Works

1. **Terraform** provisions the infrastructure:
   - A VPC with public and private subnets.
   - An EC2 instance to host the Flask app.
   - An RDS MySQL database for storing reversed IPs.

2. **Docker** ensures the app runs in a consistent environment.


