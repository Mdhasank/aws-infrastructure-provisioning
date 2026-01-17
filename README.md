# ☁️ AWS Infrastructure Provisioning with Terraform & Jenkins

[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Jenkins](https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=jenkins&logoColor=white)](https://www.jenkins.io/)

A professional-grade Infrastructure as Code (IaC) solution for automated AWS resource provisioning. This project leverages **Terraform** for declarative infrastructure management and **Jenkins** for robust CI/CD pipeline automation.

---

## 🏗️ Architecture Overview

This project automates the deployment of a secure, scalable AWS environment:

- **Virtual Private Cloud (VPC)**: Custom networking layer with a public subnet.
- **Connectivity**: Internet Gateway and optimized Route Tables for external access.
- **Security**: Granular Security Groups allowing controlled SSH and HTTP traffic.
- **Compute**: Elastic Compute Cloud (EC2) instances provisioned with dynamic configurations.
- **CI/CD**: Fully automated delivery pipeline using Jenkins for seamless infrastructure updates.

---

## 🛠️ Tech Stack

- **Provisioning**: Terraform v1.0+
- **Cloud Provider**: Amazon Web Services (AWS)
- **CI/CD Orchestration**: Jenkins
- **Operating System**: Fedora/Amazon Linux
- **Language**: HashiCorp Configuration Language (HCL)

---

## � Project Structure

```bash
aws-infrastructure-provisioning/
├── 📄 Jenkinsfile          # Multi-stage CI/CD pipeline definition
├── 📄 provider.tf          # AWS provider and region configuration
├── 📄 vpc.tf               # VPC, Subnet, IGW, and Route Table logic
├── 📄 security_groups.tf    # Firewall and network access rules
├── 📄 ec2.tf                # Compute instance definitions
├── 📄 variables.tf         # Parameterized input variables
├── 📄 outputs.tf           # Exported infrastructure metadata
└── 📄 backend.tf           # Remote state management (S3/Local)
```

---

## � Quick Start

### 1. Prerequisites
- [AWS Account](https://aws.amazon.com/) with IAM credentials.
- [Terraform](https://developer.hashicorp.com/terraform/downloads) installed locally.
- [AWS CLI](https://aws.amazon.com/cli/) configured (`aws configure`).

### 2. Manual Deployment
```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply infrastructure
terraform apply -auto-approve
```

---

## � In-Depth Documentation

For detailed setup instructions, including Jenkins installation, AWS credential management, and step-by-step pipeline configuration, please refer to our:

👉 **[Detailed Deployment Guide](DEPLOYMENT_GUIDE.md)**

---

## 🧹 Cleanup

To prevent unnecessary AWS costs, destroy the provisioned resources when no longer needed:
```bash
terraform destroy -auto-approve
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📄 License

This project is licensed under the MIT License.
