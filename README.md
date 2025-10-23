# Terraform 学习项目 — 使用 AWS 作为云平台

## 🌍 项目简介
本项目用于记录学习 **Terraform 基础语法与基础设施即代码（IaC, Infrastructure as Code）** 实践，  
以 **AWS（Amazon Web Services）** 作为主要云平台，帮助理解从代码定义到云资源创建的完整流程。

通过此项目，实践以下操作：
- 编写 Terraform 配置文件定义 AWS 基础架构  
- 使用变量（variables）和输出（outputs）管理资源配置  
- 管理 Terraform 状态（state）文件  
- 使用 provider 与模块化结构组织项目  
- 在 AWS 上自动化部署网络与计算资源（如 EC2、VPC、S3 等）

---

## ⚙️ 技术栈
- **Terraform** ≥ 1.5  
- **AWS Cloud Platform**  
- **AWS CLI**（命令行工具）  
- **IAM 用户凭证**（用于认证 Terraform 与 AWS）  

---

## 🧩 目录结构
```bash
terraform-aws-tutorial/
├── main.tf              # 主配置文件（provider、资源定义）
├── variables.tf         # 变量定义
├── outputs.tf           # 输出配置
├── terraform.tfvars     # 变量值
├── modules/             # 可选：模块化结构
└── README.md
