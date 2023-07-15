#!/bin/bash
# Name: Setup Python Virtual Environments
# Maintainer: Matt Willis
# 

set -e

# Define terminal colors
INFO=`tput setaf 33`
SUCCESS=`tput setaf 2`
WARNING=`tput setaf 3`
ERROR=`tput setaf 1`
RESET=`tput sgr0`

PKG_MANAGER=$(command -v yum || command -v apt-get)

REQ_PACKAGES=(
  python3
  python3-pip
)

# Define the Python packages to install with APT; add/edit/remove packages as necessary
# If different versions of Python are necessary, add them to the list
APT_PACKAGES=(
  python3.8
  python3.8-venv
  python3.9
  python3.9-venv
)

# Define the Python packages to install with RPM; add/edit/remove packages as necessary
# If different versions of Python are necessary, add them to the list
RPM_PACKAGES=(
  python3.8
  python3.9
  python3-virtualenv
)

# Define environment names; add/edit/remove the environment names
# Any names that do not have a specific version will default to latest Python3 version
PYTHON_ENVIRONMENTS=(
  py3.8
  py3.9
)

# Ansible package and versions; Ansible will be installed via pip
ANSIBLE_PACKAGE=ansible
ANSIBLE_PACKAGE_VER=">=2.9.0,<2.10.0"
ANSIBLE_CORE_PACKAGE=ansible-core
ANSIBLE_CORE_PACKAGE_VER=">=2.13.0,<2.14.0"

##########################
### DO NOT ALTER BELOW ###
##########################

# Create ~/venv directory for the current user
if [ ! -d "$HOME/venv" ]; then
  echo -e "${INFO}'$HOME/venv' directory is now being created.${RESET}"
  mkdir "$HOME/venv"
fi

# Check if package manager is APT
if [[ $PKG_MANAGER = *apt-get* ]]; then
  # Run APT update
  sudo apt update

  # Install packages from the PACKAGES list
  for package in "${REQ_PACKAGES[@]}"; do
    # Check if package is installed
    echo -e "${INFO}Check if '$package' is installed on operating system.${RESET}"

    if dpkg-query -Wf'${db:Status-abbrev}' $package 2>/dev/null | grep -q '^i'; then
      echo -e " $package is already installed"
    else
      echo -e " ${WARNING}$package missing.${RESET}"
      echo "Installing $package."
      sudo apt install $package
    fi
  done

  # Install packages from the PACKAGES list
  for package in "${APT_PACKAGES[@]}"; do
    # Check if package is installed
    echo -e "${INFO}Check if '$package' is installed on operating system.${RESET}"

    if dpkg-query -Wf'${db:Status-abbrev}' $package 2>/dev/null | grep -q '^i'; then
      echo -e " $package is already installed"
    else
      echo -e " ${WARNING}$package missing.${RESET}"
      echo "Installing $package."
      sudo apt install $package
    fi
  done
fi

# Check if package manager is RPM
if [[ $PKG_MANAGER = *yum* ]] || [[ $PKG_MANAGER = *dnf* ]]; then
  # Install packages from the PACKAGES list
  for package in "${REQ_PACKAGES[@]}"; do
    # Check if package is installed
    echo -e "${INFO}Check if '$package' is installed on operating system.${RESET}"

    # Create package_check var
    package_check=$(rpm -qa ${package})

    if [ ! -z $package_check ]; then
      echo -e " $package is already installed"
    else
      echo -e " ${WARNING}$package missing.${RESET}"
      echo "Installing $package."
      sudo yum install $package -y
    fi
  done

  # Install packages from the PACKAGES list
  for package in "${RPM_PACKAGES[@]}"; do
    # Check if package is installed
    echo -e "${INFO}Check if '$package' is installed on operating system.${RESET}"

    # Create package_check var
    package_check=$(rpm -qa ${package})

    if [ ! -z $package_check ]; then
      echo -e " $package is already installed"
    else
      echo -e " ${WARNING}$package missing.${RESET}"
      echo "Installing $package."
      sudo yum install $package -y
    fi
  done
fi

# Clear sudo privileges
sudo -k

# Install pip and upgrade in each Python venv environments
cd $HOME/venv

for pyenv in "${PYTHON_ENVIRONMENTS[@]}"; do
  # Check for Python 3.8 environment
  if [[ $pyenv = *3.8* ]]; then
    if [ ! -d "$HOME/venv/$pyenv" ]; then
      echo -e "\n${INFO}Creating Python 3.8 venv:${RESET} $HOME/venv/$pyenv"
      python3.8 -m venv "$pyenv"

      source $HOME/venv/$pyenv/bin/activate
      python -m pip install --upgrade pip
      python -m pip install --upgrade setuptools

      # Deactivate Python 3.8 environment
      deactivate
    fi
  # Check for Python 3.9 environment
  elif [[ $pyenv = *3.9* ]]; then
    if [ ! -d "$HOME/venv/$pyenv" ]; then
      echo -e "\n${INFO}Creating Python 3.9 venv:${RESET} $HOME/venv/$pyenv"
      python3.9 -m venv "$pyenv"

      source $HOME/venv/$pyenv/bin/activate
      python -m pip install --upgrade pip
      python -m pip install --upgrade setuptools

      # Deactivate Python 3.9 environment
      deactivate
    fi
  # If a specific version doesn't match, use python3
  else
    if [ ! -d "$HOME/venv/$pyenv" ]; then
      echo -e "\n${INFO}Creating Python 3 venv:${RESET} $HOME/venv/$pyenv"
      python3 -m venv "$pyenv"

      source $HOME/venv/$pyenv/bin/activate
      python -m pip install --upgrade pip
      python -m pip install --upgrade setuptools

      # Deactivate Python 3.9 environment
      deactivate
    fi 
  fi

  # Check for Python 3.8 environment
  if [[ $pyenv = *3.8* ]]; then
    # Load Python 3.8 virtual environment
    source $HOME/venv/$pyenv/bin/activate

    ansible_pip_package=$(pip list | grep ${ANSIBLE_PACKAGE} | awk '{print $1}')

    # Check if Ansible is installed
    if [ -z $ansible_pip_package ]; then
      pip install "${ANSIBLE_PACKAGE}${ANSIBLE_PACKAGE_VER}"
    fi

    # Print Ansible version details
    #ansible --version

    # Deactivate Python 3.8 environment
    deactivate
  # Check for Python 3.9 environment
  elif [[ $pyenv = *3.9* ]]; then
    # Load Python 3.9 virtual environment
    source $HOME/venv/$pyenv/bin/activate

    ansible_pip_package=$(pip list | grep ${ANSIBLE_CORE_PACKAGE} | awk '{print $1}')

    # Check if Ansible is installed
    if [ -z $ansible_pip_package ]; then
      pip install "${ANSIBLE_CORE_PACKAGE}${ANSIBLE_CORE_PACKAGE_VER}"
    fi

    # Print Ansible version details
    #ansible --version

    # Deactivate Python 3.9 environment
    deactivate
  else
    # Load Python 3 virtual environment
    source $HOME/venv/$pyenv/bin/activate

    ansible_pip_package=$(pip list | grep ${ANSIBLE_CORE_PACKAGE} | awk '{print $1}')

    # Check if Ansible is installed
    if [ -z $ansible_pip_package ]; then
      pip install "${ANSIBLE_CORE_PACKAGE}"
    fi

    # Print Ansible version details
    #ansible --version

    # Deactivate Python 3.9 environment
    deactivate

  fi

done

# Create aliases to activate and deactivate Python venv environments.
# Create bashrc.d directory
if [ ! -d "$HOME/.bashrc.d" ]; then
  mkdir "$HOME/.bashrc.d"
fi

# Update bashrc to read files from ~/.bashrc.d directory
if ! grep -q -e "bashrc.d" $HOME/.bashrc; then
  tee -a $HOME/.bashrc << END
if [ -d ~/.bashrc.d ]; then
  for rc in ~/.bashrc.d/*; do
    if [ -f "$rc" ]; then
      . "$rc"
    fi
  done
fi

unset rc
END
fi

# Create alias file for Python virtual environments
# You may alter the contents of the file with any aliases
if [ ! -f "$HOME/.bashrc.d/venv" ]; then
  touch "$HOME/.bashrc.d/venv"

  for pyenv in "${PYTHON_ENVIRONMENTS[@]}"; do
    tee -a $HOME/.bashrc.d/venv << END
alias venv-$pyenv-activate='source $HOME/venv/$pyenv/bin/activate'
alias venv-$pyenv-deactivate='deactivate'
END
  done
fi

# Source the ~/.bashrc file
source ~/.bashrc

# Print alias commands
echo -e "\n"

for pyenv in "${PYTHON_ENVIRONMENTS[@]}"; do
  echo -e "venv-$pyenv-activate
venv-$pyenv-deactivate"
done

echo -e "\n${INFO}Use the alias commands listed above to activate or deactivate your virtual Python environment.${RESET}"

# Complete script statement
echo -e "\n${SUCCESS}Setup complete.\n${RESET}"