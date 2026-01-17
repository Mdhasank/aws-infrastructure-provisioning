# AWS Infrastructure Provisioning

A comprehensive Infrastructure as Code (IaC) project to automate the provisioning of AWS resources using Terraform and Jenkins. This guide provides a step-by-step process to set up your **Master EC2 Instance (Fedora)** and configure the CI/CD pipeline.

---

## 🚀 Project Overview

This project automates the creation of a complete VPC environment, including:
- **VPC & Networking**: Subnets, Internet Gateway, and Route Tables.
- **Security**: Security Groups for SSH and HTTP access.
- **Compute**: EC2 instances provisioned via Terraform.
- **CI/CD**: Automated deployment using Jenkins.

---

## 🛠️ Step 1: Master EC2 Instance Setup

First, launch a Fedora Linux EC2 instance in your AWS Console to act as your **Master Node**.

1. **Launch Instance**: Select **Fedora** AMI (t3.micro or larger recommended).
2. **Security Group**: Ensure Port **22 (SSH)** and **8080 (Jenkins)** are open.
3. **Connect**: SSH into your instance:
   ```bash
   ssh -i your-key.pem fedora@<your-instance-ip>
   ```

---

## 📦 Step 2: Install Essential Tools

Once logged in, run the following commands to install the required tools.

### 1. Update System
```bash
sudo dnf update -y
```

### 2. Install Git
```bash
sudo dnf install git -y
```

### 3. Install Terraform
```bash
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
sudo dnf install terraform -y
```

### 4. Install AWS CLI & Configure
```bash
sudo dnf install awscli2 -y
# Configure your AWS credentials
aws configure
```
*Enter your Access Key, Secret Key, and default region (e.g., `us-east-1`).*

---

## 🏗️ Step 3: Jenkins Installation & Setup

### 1. Install Java (Required for Jenkins)
```bash
sudo dnf install java-17-openjdk -y
```

### 2. Add Jenkins Repository & Install
```bash
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo dnf install jenkins -y
```

### 3. Start and Enable Jenkins
```bash
sudo systemctl enable jenkins
sudo systemctl start jenkins
```

### 4. Configure Firewall
```bash
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
```

---

## ⚙️ Step 4: Initial Jenkins Configuration

1. **Access Jenkins**: Open your browser and go to `http://<your-ec2-ip>:8080`.
2. **Unlock Jenkins**: Get the admin password from your terminal:
   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```
3. **Install Plugins**: Choose **"Install Suggested Plugins"**.
4. **Create Admin User**: Follow the prompts to set up your admin account.

---

## 🔗 Step 5: Configure Jenkins Pipeline

### 1. Add AWS Credentials
- Go to **Manage Jenkins** → **Credentials** → **System** → **Global credentials**.
- Click **Add Credentials**.
- Kind: **Secret text** (or AWS Credentials plugin if installed).
- Create two credentials:
  - ID: `AWS_ACCESS_KEY_ID`
  - ID: `AWS_SECRET_ACCESS_KEY`

### 2. Create Pipeline Job
- Click **New Item** → Enter name (e.g., `AWS-Infra`) → Select **Pipeline**.
- In the **Pipeline** section:
  - Definition: **Pipeline script from SCM**.
  - SCM: **Git**.
  - Repository URL: `<your-repo-url>`.
  - Script Path: `Jenkinsfile`.

---

## 🚀 Step 6: Run the Provisioning

1. Click **Build Now** in your Jenkins job.
2. Jenkins will:
   - Clone the code.
   - Run `terraform init`.
   - Run `terraform plan`.
   - Run `terraform apply` (auto-approving the changes).

---

## 🧹 Cleanup

To avoid AWS charges, destroy the infrastructure when finished:
```bash
terraform destroy -auto-approve
```

---

## 📂 Project Structure
```text
├── provider.tf        # AWS Provider config
├── vpc.tf             # Networking setup
├── security_groups.tf # Firewall rules
├── ec2.tf             # Instance definition
├── variables.tf       # Input variables
├── outputs.tf         # Useful output data
└── Jenkinsfile        # CI/CD Pipeline
```
