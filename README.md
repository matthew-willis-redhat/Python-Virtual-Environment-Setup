# Python Virtual Environment Setup for Ansible Development

The purpose of this script is quickly setup a Python virtual environment for Ansible development.

## Requirements

*Tested on Fedora 38 and Ubuntu 22.04 operating systems*

Required packages

- python3
- python3-pip

Their may be APT or RPM specific packages that are necessary to install that will allow you use Python virtual environmemts.

To define specific Python virtual environments, update the **PYTHON_ENVIRONMENTS** list variable.

To define specific **ansible** or **ansible-core** versions, update the variables **ANSIBLE_PACKAGE_VER** or **ANSIBLE_CORE_PACKAGE_VER**.

## Script Logic

The script will begin by creating a **venv** folder in the current logged in user's home directory.

Next it will check if the package manager is either APT or RPM based, then will install the required packages per the operating systems packages list that will include the **REQ_PACKAGES** list.

After the packages are installed from the operating system's package manager, the script which versions of Python are installed and create a virtual environment based on the version and the name that is defined **PYTHON_ENVIRONMENTS** list.

Once the virtual environments are created, Ansible will be install via pip with either the **ansible** or **ansible-core** package and the versions defined by the variables **ANSIBLE_PACKAGE_VER** or **ANSIBLE_CORE_PACKAGE_VER**.

Lastly the script will create a **~/.bashrc.d** directory and a **venv** file inside of that directory, that will include aliases to **activate** or **deactivate** those specific Python virtual environments.
