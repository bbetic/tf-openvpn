# Just-in-Time OpenVPN Server on AWS (Pulumi Version)

This repository provides a simple automated solution to spin up a temporary OpenVPN server on AWS using **Pulumi**, download the configuration securely, and then lock the server down.

It is designed to be run manually via **GitHub Actions**.

## Security & Workflow

The deployment follows a **Provision -> Download -> Lock** strategy for ultimate security:

1.  **Provision**: The server is created with SSH (port 22) and OpenVPN (port 1194) temporarily open.
2.  **Download**: The GitHub Action waits for the server to be ready and securely downloads the `client.ovpn` configuration via SCP using a temporary, generated SSH key.
3.  **Lock**: Immediately after the download is complete, the automation runs a second infrastructure update to **remove SSH access** entirely.

**Result**: A running VPN server with **Zero SSH Ports Open**. Only UDP 1194 is accessible.

## State Management (GitHub Releases)

We use **GitHub Releases** to store the state of the active server.

-   **When running `up`**: A new Release named **"Active VPN Session"** (`vpn-active`) is created. The Pulumi state (`stack.json`) and the VPN config (`client.ovpn`) are attached as assets.
-   **When running `down`**: The workflow automatically downloads the state from this Release, destroys the infrastructure, and then deletes the Release.

**Note**: You can only have **one** active VPN session at a time per repository.

## Prerequisites

To run this, you need to configure the following Secrets in your GitHub repository settings:

1.  `AWS_ACCESS_KEY_ID`: Your AWS Access Key.
2.  `AWS_SECRET_ACCESS_KEY`: Your AWS Secret Key.
3.  `PULUMI_CONFIG_PASSPHRASE`: A strong passphrase to encrypt secrets in the state file.

## Usage (GitHub Actions)

### 1. Start the VPN Server

1.  Go to the **Actions** tab in the GitHub repository.
2.  Select the **OpenVPN JIT Manager** workflow.
3.  Click **Run workflow**.
4.  **Action**: `up`.
5.  Click **Run workflow**.

Wait for the job to complete.

### 2. Download Configuration

Once the "up" job finishes successfully, you have two options:
-   **Option A (Releases)**: Go to the main repository page -> **Releases**. Download `client.ovpn` from the "Active VPN Session".
-   **Option B (Artifacts)**: Go to the Actions run -> **Artifacts** -> Download `vpn-config`.

Import `client.ovpn` into your OpenVPN client.

### 3. Destroy the Server

When you are finished:
1.  Go back to the **Actions** tab.
2.  Run the **OpenVPN JIT Manager** workflow again.
3.  **Action**: `down`.
4.  Click **Run workflow**.

This will automatically find the active session and destroy it.

## Files

-   `manage.sh`: Orchestration script (handles the 2-step provision/lock process).
-   `__main__.py`: Pulumi infrastructure definition.
-   `user_data.sh.tpl`: Server setup script.

## License

GPLv3
