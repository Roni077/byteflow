# Security Policy

The ByteFlow team and contributors take the security and privacy of our users very seriously. ByteFlow is designed to be 100% offline, local-first, with zero telemetry and zero external server network connections.

---

## Supported Versions

We provide security patches and updates for the following versions:

| Version | Supported          | Notes |
| :---    | :---               | :---  |
| 1.0.x   | :white_check_mark: | Current active release branch |
| < 1.0   | :x:                | Pre-release / unsupported |

---

## Reporting a Vulnerability

If you discover a potential security vulnerability in ByteFlow (such as unexpected privilege escalation, unintended data exposure, or malicious IPC exploit), please report it responsibly:

1. **Do NOT open a public GitHub issue** for undisclosed security vulnerabilities.
2. Please use **GitHub Private Vulnerability Reporting** by navigating to:
   - [Security Advisory Submission](https://github.com/Roni077/byteflow/security/advisories/new)
3. Alternatively, contact the maintainer directly via GitHub profile message or email associated with commit signatures.

### What to Include in Your Report

To help us triage and resolve the issue quickly, please provide:
- A description of the vulnerability and its potential impact.
- Step-by-step instructions or proof-of-concept (PoC) demonstrating how to reproduce the issue.
- Details regarding affected Android OS versions, devices, or Shizuku configurations.
- Any suggested remediations or mitigations if known.

### Response Timeline

- **Initial Acknowledgement**: Within 48 hours of report submission.
- **Triage & Assessment**: Within 5 business days.
- **Fix & Disclosure**: We aim to release a patch and coordinated disclosure within 30 days of validation.

---

## Security Best Practices in ByteFlow

- **Zero Tracking**: ByteFlow does not embed any analytics SDKs, advertising libraries, or remote loggers.
- **IPC Safety**: Platform channels (`MethodChannel` / `EventChannel`) strictly validate argument types and bounds before dispatching calls to Android system services.
- **Least Privilege**: Privileged SIM operations (`READ_PRIVILEGED_PHONE_STATE`) are strictly guarded behind Shizuku binder verification and only invoked when authorized by the user.
- **Local Storage Security**: Drift database and SharedPreferences files reside exclusively in Android protected internal app storage (`/data/data/com.byteflow.network/`).
