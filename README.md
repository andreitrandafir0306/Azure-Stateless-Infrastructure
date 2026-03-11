# Azure Stateless Infrastructure

## Architecture Overview
This project is an end-to-end Infrastructure as Code (IaC) and Configuration Management pipeline. It provisions an ephemeral fleet of Azure Virtual Machines, securely bootstraps them without hardcoded credentials using native Azure API metadata and idempotently deploys a containerized Docker CLI tool.

The architecture emphasizes the Principle of Least Privilege and Role-Based Access Control.

## Technology Stack
* **Cloud Provider:** Microsoft Azure
* **CI/CD:** GitHub Actions
* **Infrastructure as Code:** Terraform
* **Configuration Management:** Ansible
* **Container Runtime:** Docker Engine
* **Dynamic Inventory:** `azure.azcollection.azure_rm` Plugin

## Core Engineering Features
* **Dynamic Tag-Based Targeting:** Bypasses static `hosts` files. Ansible queries the Azure Resource Manager (ARM) API to dynamically construct the execution inventory based on the `Role: managed_node` tag defined in Terraform for the three managed nodes.
* **Secure Authentication:** Eliminates hardcoded SSH passwords and Azure credentials from configuration files. Relies on SSH key pairs mapped dynamically. Access to the control node has been restricted to only the IP of the host launching the infrastructure and the managed nodes can be accessed only from the control node's IP address.
* **Idempotent Execution:** Validates the state of the OS package manager, GPG keys and Docker daemon sockets before execution, ensuring the playbook can be run infinitely without breaking the global state.
* **Stateless Validation:** Tests the deployment by pulling a compiled artifact from DockerHub and executing it natively in the foreground (`--rm`), ensuring zero residual configuration drift upon completion.

## Deployment Pipeline

### Prerequisites:
Azure Service Principal
Active Subscription
Azure Resource Group
Azure Storage Account
Azure Storage Container

A script to create the resource group, storage account and container can be found in scripts/Account_Setup.sh

### Reference document for OIDC setup with Azure: https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-azure

### Phase 1: Infrastructure provisioning (Terraform)
Provisions the Remote State, Virtual Networks, Subnets, Network Security Groups (NSGs), and Linux Virtual Machines. Enforces a unified admin username across the fleet of managed nodes.

### Phase 2: Configuration & Validation (Ansible)
Configures the control node, transfers the required files via scp, establishes SSH connection to control node in order to prepare Ansible, the dynamic inventory and Docker on the control node and starts the playbook to control the managed nodes.


### Phase 3: Infrastructure Destruction (Terraform)
Destroy the infrastructure, clean up the SSH keys from the runner to ensure zero costs. After the pipeline, a log will be generated and can be downloaded to review the process.









