# 📖 Comprehensive Deployment Guide

This guide provides a detailed, step-by-step walkthrough to deploy the AWS Infrastructure using both manual Terraform commands and an automated Jenkins CI/CD pipeline.

---

## 📑 Table of Contents
1. [Prerequisites](#1-prerequisites)
2. [Generating AWS Access Keys](#2-generating-aws-access-keys)
3. [Master Instance Setup (Proctor Node)](#3-master-instance-setup-proctor-node)
4. [Environment Configuration](#4-environment-configuration)
5. [Manual Local Deployment](#5-manual-local-deployment)
6. [Automated CI/CD with Jenkins](#6-automated-cicd-with-jenkins)
7. [Security Best Practices](#7-security-best-practices)
8. [Troubleshooting](#8-troubleshooting)

---

## 1. Prerequisites

Before starting, ensure you have:
- An **AWS Account** with administrative access.
- **IAM User** with `AdministratorAccess` (for initial setup) and programmatic access keys.
- **Key Pair** (.pem) created in your AWS region (e.g., `us-east-1`).

---

## 2. Generating AWS Access Keys

### ❓ Why do you need this?
Terraform and Jenkins need these keys to act as your "digital identity." Without them, AWS will reject any request to create servers, networks, or S3 buckets.

### 🛠️ Step-by-Step Instructions:
1. **Log in** to your [AWS Management Console](https://aws.amazon.com/console/).
2. Search for **IAM** in the top search bar and click it.
3. In the left sidebar, click **Users** and then click the **Create user** button.
4. **User details**: Give it a name (e.g., `terraform-jenkins-user`) and click **Next**.
5. **Set permissions**:
   - Select **Attach policies directly**.
   - Search for and check **AdministratorAccess** (Note: In production, you should use more restrictive roles).
   - Click **Next** and then **Create user**.
6. **Generate Keys**:
   - Click on the the name of the user you just created.
   - Go to the **Security credentials** tab.
   - Scroll down to **Access keys** and click **Create access key**.
   - Select **Command Line Interface (CLI)** as the use case.
   - Check the box for "I understand..." and click **Next**.
   - (Optional) Give it a tag and click **Create access key**.
7. **⚠️ CRITICAL**: You will see your **Access Key ID** and **Secret Access Key**. 
   - Click **Download .csv file** immediately. 
   - **You will never see the Secret Key again after leaving this page!**

---

## 3. Master Instance Setup (Proctor Node)

We recommend using a dedicated EC2 instance to manage your infrastructure deployments.

### 🚀 Step 1: Launch the Master Node
1. **AMI**: AWS Marketplace -> **Fedora Linux 38/39** (or Amazon Linux 2023).
2. **Instance Type**: `t3.micro` (Free Tier eligible).
3. **Security Group Settings**:
   - SSH (Port 22): My IP
   - HTTP (Port 8080): Anywhere (for Jenkins UI)

### 💻 Step 2: System Preparation
SSH into your instance:
```bash
ssh -i your-key.pem fedora@<MASTER_IP>
```

Update system packages:
```bash
sudo yum update -y
```

---

## 3. Environment Configuration

### 🛠️ Install Tooling

#### 1. Install Git
```bash
sudo yum install git -y
```

#### 2. Install Terraform
```bash
sudo yum install -y yum-utils shadow-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum install terraform -y
```

#### 3. Install AWS CLI
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo yum install unzip -y
unzip awscliv2.zip
sudo ./aws/install
```

### 🔐 Configure Credentials
```bash
aws configure
# Enter your Access Key ID
# Enter your Secret Access Key
# Default region: us-east-1
# Default output format: json
```

---

## 4. Manual Local Deployment

If you want to test the infrastructure without Jenkins:

1. **Clone the Repository**:
   ```bash
   git clone <your-repository-url>
   cd aws-infrastructure-provisioning
   ```

2. **Initialize Workspace**:
   ```bash
   terraform init
   ```

3. **Validation & Planning**:
   ```bash
   terraform validate
   terraform plan -out=tfplan
   ```

4. **Execution**:
   ```bash
   terraform apply tfplan
   ```

---

## 5. Automated CI/CD with Jenkins

### 🏗️ Step 1: Jenkins Installation
```bash
# Install Java 17
sudo yum install java-17-amazon-corretto-devel -y

# Add Jenkins Repo
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

# Install & Start
sudo yum install jenkins -y
sudo systemctl enable --now jenkins
```

### ⚙️ Step 2: Jenkins Initial Configuration
1. Open `http://<MASTER_IP>:8080` in your browser.
2. Retrieve the admin password:
   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```
3. Install **Suggested Plugins**.
4. Create your **First Admin User**.

### 🔗 Step 3: Pipeline Orchestration
1. **Manage Jenkins** -> **Credentials** -> **System** -> **Global credentials**.
2. Add **Secret Text** credentials:
   - ID: `AWS_ACCESS_KEY_ID`
   - ID: `AWS_SECRET_ACCESS_KEY`

### 📦 Step 4: Infrastructure Customization
Before running the pipeline, update the following files:
1. **`backend.tf`**: Change the `bucket` name to a unique S3 bucket you own.
2. **`variables.tf`**: Update the `ami_id` if you are using a different region or OS.

### 🔗 Step 5: Pipeline Orchestration
4. **Pipeline Definition**:
   - SCM: **Git**
   - URL: `<your-github-repo-url>`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`
5. **Save** and click **Build Now**.

---

## 6. Security Best Practices

- **State Locking**: In a production environment, configure `backend.tf` to use an **S3 Bucket** for the state file and **DynamoDB** for state locking.
- **Least Privilege**: Avoid using root user credentials. Create a dedicated IAM role for Jenkins.
- **VPC Isolation**: The current setup uses a public subnet. For production databases or private apps, use private subnets with a NAT Gateway.

---

## 7. Troubleshooting

| Issue | Potential Solution |
|-------|--------------------|
| **Terraform Apply Fails** | Check AWS quotas and ensure the VPC CIDR doesn't overlap. |
| **Jenkins Permission Denied** | Ensure the `jenkins` user has permission to execute `terraform` and access `.aws/credentials`. |
| **SSH Timed Out** | Verify that your Security Group allows Port 22 from your current IP. |

---

## 🧹 Resource Cleanup

To avoid unexpected AWS charges, you must destroy the infrastructure when finished. 

### Manual Resource Destruction (as Root)
If you need to destroy resources from the terminal, you must navigate to the specific folder where Jenkins cloned your project.

1. **Locate your workspace**:
   Run this command to see the names of your Jenkins projects:
   ```bash
   ls /var/lib/jenkins/workspace/
   ```

2. **Navigate to the folder**:
   Replace `AWS-Infrastructure` with the name you saw in previous step:
   ```bash
   cd /var/lib/jenkins/workspace/AWS-Infrastructure
   ```

3. **Execute Destroy**:
   ```bash
   terraform init
   terraform destroy -auto-approve
   ```

**Pro-Tips for Manual Cleanup:**
- **Already Root?**: If your prompt shows `[root@...]`, you don't need `sudo`.
- **Backend Sync**: Always run `terraform init` before `destroy` to ensure your terminal is synced with the S3 state file.
- **Credential Check**: If it says "Access Denied", run `aws configure` to re-verify your keys.

---

## 🏁 Conclusion
You now have a professional, automated infrastructure pipeline. For production use, remember to transition to private subnets and use IAM Roles instead of static credentials.
