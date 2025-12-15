FROM ubuntu:24.04

# Install dependencies and latest python
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    nano \
    apt-transport-https \
    software-properties-common \
    python3 \
    python3-pip \
    python3-venv

# Install OCI-CLI and accept all defaults
# Ref: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm#InstallingCLI__linux_and_unix
RUN bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)" -- --accept-all-defaults

# Install Powershell 7.5 via package repository
# Ref: https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu?view=powershell-7.5#installation-via-package-repository-the-package-repository
RUN . /etc/os-release && \
    wget -q https://packages.microsoft.com/config/ubuntu/$VERSION_ID/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y powershell

# Expose port for auth redirection to http://localhost:8181
EXPOSE 8181