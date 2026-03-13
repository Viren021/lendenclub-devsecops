# DevSecOps Pipeline: Secure Cloud Infrastructure Deployment

**Student Name:** Viren Balu Hadawale  
**Branch:** BE IT  
**Role:** DevOps  

🎥 **Video Demonstration:** [https://drive.google.com/file/d/1t4-aXUJWU2-FevjXEh98BCUOoJOfcLN_/view?usp=drive_link]  

---

## 📖 Project Overview
This project demonstrates a complete DevSecOps CI/CD pipeline. It involves containerizing a Python web application, provisioning immutable cloud infrastructure using Terraform, automating deployments via Jenkins, and integrating Trivy for automated security scanning and AI-driven remediation.

### Architecture Explanation
1. **Version Control:** Source code and infrastructure definitions are hosted on GitHub.
2. **CI/CD Automation:** A local Jenkins server (running in Docker) pulls the code on execution.
3. **Security Scanning:** Trivy scans the Terraform (`main.tf`) files for misconfigurations before deployment. If critical vulnerabilities are found, the pipeline fails.
4. **Infrastructure as Code (IaC):** Terraform provisions an AWS EC2 instance and configures Security Groups dynamically.
5. **Containerization:** The web application is deployed onto the EC2 instance using Docker and Docker Compose.

### Cloud Provider & Tools Used
* **Cloud Provider:** AWS (Amazon Web Services)
* **Compute:** EC2 (t2.micro / t3.micro)
* **IaC:** Terraform
* **CI/CD:** Jenkins (Dockerized)
* **Security Scanner:** Trivy
* **Containerization:** Docker & Docker Compose
* **AI Remediation:** Google Gemini

---

## 🛡️ Before & After Security Report

### Initial State (Intentional Vulnerabilities)
The initial Terraform code contained the following severe security flaws:
1. **Unrestricted SSH Access:** Port 22 was open to the world (`0.0.0.0/0`), leaving the server vulnerable to brute-force attacks.
2. **Unencrypted Storage:** The EBS root volume lacked encryption, exposing data at rest.
3. **Overly Permissive Egress:** Outbound traffic was completely unrestricted.

### Final State (Secured & Remediated)
After integrating Trivy and consulting AI for remediation:
1. **Restricted SSH Access:** Port 22 ingress is now strictly limited to a dynamically injected personal IP address (`${var.my_ip}/32`) passed via Jenkins secure credentials.
2. **Encrypted Storage:** EBS volume encryption is explicitly enforced (`encrypted = true`).
3. **Controlled Egress & Exceptions:** Outbound traffic was restricted. A specific, documented Trivy exception (`# trivy:ignore:AVD-AWS-0104`) was implemented to allow the server to fetch required system updates (apt-get) and Docker packages safely.

---

## 🤖 AI Usage Log (Mandatory)

During the development of this pipeline, AI (Gemini) was utilized to analyze failing Trivy security scans, explain the risks, and generate secure Terraform code.

### Prompt 1: SSH Vulnerability & IP Whitelisting
* **The Prompt:** *"I got this Trivy error in Jenkins: 'Security group rule allows ingress from public internet.' How do I fix this without locking myself out?"*
* **Identified Risk:** AI explained that leaving Port 22 open to `0.0.0.0/0` allows global brute-force SSH attacks. 
* **AI Recommended Change:** AI provided updated Terraform code to restrict the `cidr_blocks` to a specific IP address using a `/32` subnet mask, and suggested abstracting the IP into a Jenkins environment variable (`TF_VAR_my_ip`) so it wouldn't be hardcoded in a public GitHub repository.

### Prompt 2: EBS Encryption
* **The Prompt:** *"Trivy is failing with 'Unencrypted root block device'. What do I add to my aws_instance block?"*
* **Identified Risk:** Data stored on the EC2 instance is vulnerable if physical drives are compromised or snapshots are leaked.
* **AI Recommended Change:** AI generated the `root_block_device { encrypted = true }` block to ensure AWS KMS automatically encrypts the volume.

### Prompt 3: Handling Security Exceptions (Egress)
* **The Prompt:** *"Trivy blocked my deployment because my egress rule allows unrestricted outbound traffic to 0.0.0.0/0, but my EC2 server needs internet to download Docker. How do I bypass this securely?"*
* **Identified Risk:** Strict egress rules blocked the server from reaching Ubuntu package repositories.
* **AI Recommended Change:** AI explained the concept of documented security exceptions and provided the inline `# trivy:ignore:AVD-AWS-0104` tag, allowing the pipeline to pass while acknowledging the intentional architectural requirement.

---

## 📸 Required Screenshots

* **Initial Failing Jenkins Scan:**
  ![Initial Failing Scan](https://github.com/user-attachments/assets/912b8f63-c684-4bb9-9c26-bcb0b720f928)
  
* **Final Passing Jenkins Scan:**
  ![Final Passing Scan](https://github.com/user-attachments/assets/eeb38ac4-2bff-418e-a898-ab3866e4826d)
  
* **Application Running on Cloud Public IP:**
  ![Live Application](https://github.com/user-attachments/assets/8a389d91-a35d-479e-b869-b4670ed0e689)
