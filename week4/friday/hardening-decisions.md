# KijaniKiosk Infrastructure Security & Hardening Decisions

1. ### Overview

This document describes the security and operational hardening decisions applied to the KijaniKiosk infrastructure. The system is designed to be reproducible, auditable, and consistent across environments using infrastructure as code and configuration management principles. The objective is to ensure that the deployed environment reduces attack surface, enforces least privilege, and maintains predictable service behavior across repeated deployments.

The infrastructure spans three server roles: API, payments, and logs. Each role is provisioned consistently using automated infrastructure provisioning and configured using declarative system configuration management.

2. ### Security Design Philosophy

The security approach is based on three principles:

Least privilege by default: Only required access and capabilities are enabled.
Reproducibility over manual intervention: All configuration is declarative and version-controlled.
Separation of concerns: Infrastructure provisioning and system configuration are handled independently to reduce coupling and risk of configuration drift.

This ensures that environments can be rebuilt identically without relying on undocumented manual steps.

3. ### Security Controls Table
| Control  | What it does   |Risk mitigated                                                |
| ---------------------------------------- | -------------------------------------------------------- | ------------------------------------------------------------- |
| Remote Terraform state storage   | Stores infrastructure state remotely rather than locally | Prevents state loss and unauthorized local modification      |
| State locking mechanism                  | Prevents concurrent infrastructure changes               | Avoids race conditions and corruption of infrastructure state |
| Dynamic AMI selection                    | Uses latest verified Ubuntu image                        | Reduces exposure to outdated OS vulnerabilities               |
| Restricted SSH ingress                   | Limits SSH access to approved CIDR range                 | Prevents unauthorized external access                         |
| Security group isolation per server role | Separates network access per service type                | Limits lateral movement between services                      |
| Dedicated service user account           | Runs services under non-root identity                    | Reduces impact of service compromise                          |
| Systemd sandboxing directives            | Applies process isolation and system restrictions        | Limits filesystem and kernel-level access                     |
| Writable application directory isolation | Ensures application writes only to controlled paths      | Prevents privilege escalation via system directories          |
| Persistent journald configuration        | Enables durable logging across reboots                   | Supports forensic analysis and monitoring                     |
| Log rotation policy                      | Automatically manages log file size and retention        | Prevents disk exhaustion attacks                              |

4. ### Systemd Hardening for kk-payments

The kk-payments service is the most sensitive component due to its role in processing transactional data. It has been hardened using systemd sandboxing features that restrict system access while maintaining functionality.

Key protections include:

Running the service under a dedicated non-privileged service account
Restricting write access to a dedicated application directory
Preventing modifications to critical system directories
Isolating runtime environment variables in a controlled configuration file location

The configuration ensures that the service can only interact with explicitly permitted paths required for normal operation.

The environment file is stored in a dedicated application directory rather than system configuration directories to ensure compatibility with strict service isolation policies. This prevents service startup failures while maintaining security boundaries.

5. ### Systemd Security Score (kk-payments)

The kk-payments service was evaluated using systemd security analysis tools.

Security score: 2.3 (Good / Hardened)
Result: Service starts successfully with sandboxing enabled
Observation: Minor remaining exposure comes from necessary network access and runtime file access required for service operation

This score demonstrates that the service is significantly hardened while still maintaining functional requirements.

6. ### Limitations and Known Gaps

Despite the implemented controls, the current system does not fully mitigate all risks. Notably:

No intrusion detection system is currently in place to detect active threats in real time.
There is no centralized log aggregation or SIEM integration for cross-service correlation.
Network traffic between services is not encrypted internally.
There is no automated vulnerability scanning of deployed infrastructure.
Secrets management is handled via static environment files rather than a dedicated secret management system.

These gaps are acknowledged and represent areas for future improvement in a production-grade deployment.

7. ### Conclusion

The current infrastructure represents a secure, reproducible baseline for deployment of KijaniKiosk services. It prioritizes consistency, reduced attack surface, and operational clarity over complexity. The design ensures that infrastructure can be rebuilt reliably and audited effectively, while maintaining service functionality under strict system constraints.

###



## PR DESCRIPTION


This pull request delivers the complete Week 4 KijaniKiosk Infrastructure-as-Code pipeline, integrating Terraform-based provisioning with Ansible-based configuration management into a fully automated and reproducible deployment workflow.

The implementation provisions three EC2 instances (api, payments, logs) using a reusable Terraform module with dynamic AMI selection and remote state management with locking. Outputs from Terraform are programmatically consumed to generate an Ansible inventory, enabling fully dynamic infrastructure targeting without hardcoded IP addresses.

Ansible configuration enforces a structured seven-phase system setup including package installation, service account creation, directory structure setup, systemd service deployment, firewall configuration, logging persistence, and log rotation. All configuration is fully parameterized using group_vars, host_vars, and Jinja2 templates, ensuring strict idempotency across repeated executions.

The pipeline is orchestrated through a single automation script that executes Terraform and Ansible sequentially, validating reproducibility by ensuring that a second execution results in no infrastructure or configuration changes.

The most confident design decision in this implementation is the strict separation of infrastructure provisioning and configuration management, with structured Terraform outputs acting as the only interface between the two systems. This ensures clarity, maintainability, and predictable automation behavior.

Given more time, I would improve the system by introducing centralized secrets management and implementing automated security scanning for both infrastructure and configuration layers.