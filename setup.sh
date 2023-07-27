#!/bin/bash
##########################################################################################
# Name:             setup.sh                                                             #
# Description:      Create Python Virtual Environments with Ansible installation         #
# Author:           Matt Willis                                                          #
# Email:            mawillis@redhat.com                                                  #
# Version:          1.0.0                                                                #
##########################################################################################

##########################################################################################
#                                   Global Variables                                     #
#                                                                                        # 
# These variables are default variables that can be overwritten during script execution. #
# Use the --help option to see script usage                                              # 
##########################################################################################

# Default Ansible Version; Ansible will be installed using 'pip' - https://pypi.org/project/ansible/
ANSIBLE_PACKAGE=ansible
ANSIBLE_VERSION=">=8.0.0"

# Default environment name for Python Virtual Environment
ENVIRONMENT_NAME="python3-venv"

# Determine package manager; DO NOT EDIT this variable unless necessary
PACKAGE_MANAGER=$(command -v yum || command -v apt-get)

# Default Python Version
PYTHON_VERSION="3"

# Python package name; DO NOT EDIT this variable unless necessary
PYTHON_PACKAGE="python$PYTHON_VERSION"

RPM_PYTHON_VENV_PACKAGE="python3-virtualenv"

# This is the base directory to store Python Virtual Environments
#
# Example: $VENV_DIRECTORY/$ENVIRONMENT_NAME
#          /home/user/venv/python3-venv
VENV_DIRECTORY="$HOME/venv"

# Script version
VERSION="1.0.0"

##########################################################################################
#                                     FUNCTIONS                                          #
#                                                                                        # 
#    This section is comprised of all the necessary functions to execute the script.     # 
##########################################################################################

function message {

  # Define terminal colors
  INFO=`tput setaf 33`
  SUCCESS=`tput setaf 2`
  WARNING=`tput setaf 3`
  ERROR=`tput setaf 1`
  RESET=`tput sgr0`

  # Message error function; prefix message with ERROR
  function message_error {
    echo -e "${ERROR}ERROR${RESET}   $1"
  }
  # Message info function; prefix message with INFO
  function message_info {
    echo -e "${INFO}INFO${RESET}    $1"
  }
  # Message success function; prefix message with SUCCESS
  function message_success {
    echo -e "${SUCCESS}SUCCESS${RESET} $1"
  }
  # Message warning function; prefix message with WARNING
  function message_warning {
    echo -e "${WARNING}WARNING${RESET} $1"
  }

  # Convert arguement to lowercase; set variable
  MESSAGE_STATUS=$(echo "$1" | awk '{print tolower($0)}')

  if [ -z $QUIET ]; then
    # Execute message based on status
    if [ "$MESSAGE_STATUS" = "error" ]; then
      message_error "$2"
    elif [ "$MESSAGE_STATUS" = "info" ]; then
      message_info "$2"
    elif [ "$MESSAGE_STATUS" = "success" ]; then
      message_success "$2"
    elif [ "$MESSAGE_STATUS" = "warning" ]; then
      message_warning "$2"
    else
      echo "$1"
    fi
  fi

}

function usage {
  # Usage/Help function
  message ""
  message "  This script is meant to help create Python Virtual Environments for Ansible use."
  message "  Installing Python 3 and creating Python Virtual Environment, to install Ansible within Python Virtual Environment."
  message ""
  message "  Syntax: python-virtualenv-setup.sh [-a|d|e|h|n|r|p|V]"
  message "" 
  message "  Options:"
  message "    -a     | --ansible               Ansible version to install"
  message "    -d     | --defaults              Display default settings"
  message "    -e, -n | --environment, --name   Python Virtual Environment name to be created"
  message "    -h     | --help                  Show help"
  message "    -r     | --root, --directory     Root directory for Python Virtual Environments"
  message "    -q     | --quiet                 Suppress script message output"
  message "    -p     | --python                Python version to install"
  message "    -V     | --version               Display version of script"
  message ""
}

function defaults {
  message info "Python Version: $PYTHON_VERSION"
  message info "Python Package: $PYTHON_PACKAGE"
  message info "Ansible Version: $ANSIBLE_PACKAGE$ANSIBLE_VERSION"
  message info "Environment Name: $ENVIRONMENT_NAME"
  message info "Virtual Environment Directory: $VENV_DIRECTORY/$ENVIRONMENT_NAME"
}

function install_python {
  
  function version_check {

    if [[ $PACKAGE_MANAGER = *apt-get* ]]; then
      message warning "APT based Operating Systems not yet supported"
      return 1
    fi

    # if [[ $PACKAGE_MANAGER = *apt-get* ]]; then
    #   # Create PYTHON_PACKAGE_CHECK var
    #   PYTHON_PACKAGE_CHECK=$(dpkg-query -Wf'${db:Status-abbrev}' $python_ver 2>/dev/null | grep -q '^i'; then)

    #   if [ ! -z $PYTHON_PACKAGE_CHECK ]; then
    #     echo -e "${SUCCESS}Python package '$python_ver' is already installed.${RESET}"
    #     return 
    #   else
    #     echo "Python package '$python_ver' is not installed on this operating system."

    #     echo "Checking if Python package '$python_ver' is available to install."
    #     PYTHON_PACKAGE_INSTALL=$(apt search . | cut -f 1 -d "/" | grep -e "^${python_ver}$")

    #     if [ ! -z "$PYTHON_PACKAGE_INSTALL" ]; then
    #       echo -e "${SUCCESS}Python package '$python_ver' is available to install on this operating system.\n ${RESET}"
    #       return 0
    #     else
    #       echo -e "${ERROR}Python package '$python_ver' is not available for install on this operating system. Please make another selection.\n ${RESET}"
    #       return 1
    #     fi
    #   fi
    # fi

    # Check if package manager is RPM
    if [[ $PACKAGE_MANAGER = *yum* ]] || [[ $PACKAGE_MANAGER = *dnf* ]]; then
      # Create PYTHON_PACKAGE_CHECK var
      PYTHON_PACKAGE_CHECK=$(rpm -qa ${PYTHON_PACKAGE})

      if [ ! -z $PYTHON_PACKAGE_CHECK ]; then
        message success "Python package '$PYTHON_PACKAGE' is already installed."
        return 
      else
        message "Python package '$PYTHON_PACKAGE' is not installed on this operating system."

        message "Checking if Python package '$PYTHON_PACKAGE' is available to install."
        PYTHON_PACKAGE_INSTALL=$(yum list -q | grep $PYTHON_PACKAGE)

        if [ ! -z "$PYTHON_PACKAGE_INSTALL" ]; then
          message info "Python package '$PYTHON_PACKAGE' is available to install on this operating system."
          message ""
          return 0
        else
          message error "Python package '$PYTHON_PACKAGE' is not available to install on this operating system."
          message "Learn more about the Python releases: https://devguide.python.org/versions/"
          return 1
        fi
      fi
    fi
  }

  # Check if the Python version is installed and/or available to be installed
  version_check

  if [ $? -eq 0 ]; then       
    if [[ $PACKAGE_MANAGER = *yum* ]] || [[ $PACKAGE_MANAGER = *dnf* ]]; then

      if [ -z $QUIET ]; then
        # Install Python and Virtual Environment RPM packages
        message info "Installing '$PYTHON_PACKAGE' and '$RPM_PYTHON_VENV_PACKAGE'." 
        sudo yum install $PYTHON_PACKAGE $RPM_PYTHON_VENV_PACKAGE -y
      else
        sudo yum install $PYTHON_PACKAGE $RPM_PYTHON_VENV_PACKAGE -y -q
      fi
      
      if [ $? -eq 0 ]; then
        message success "Python packages have been installed."
        message info "Print Python version"
        python --version
      else
        message warning "Check installation issues."
        exit
      fi
      # Clear sudo privileges
      sudo -k
      
    fi
  else
    # Exit script because Python version entered is not available
    exit
  fi
}

function create_python_virtual_environment {
  
  message info "Checking if '$VENV_DIRECTORY' exists."

  # Create root directory of Python Virtual Environments
  if [ ! -d "$VENV_DIRECTORY" ]; then
    message info "'$VENV_DIRECTORY' directory is now being created."
    mkdir $VENV_DIRECTORY
    message success "'$VENV_DIRECTORY' directory created."
  else
    message success "'$VENV_DIRECTORY' directory already exists."
  fi

  # Install pip and upgrade in each Python venv environments
  cd $VENV_DIRECTORY

  message info "Checking if '$VENV_DIRECTORY/$ENVIRONMENT_NAME' Python Virtual Environment exists."
  if [ ! -d "$VENV_DIRECTORY/$ENVIRONMENT_NAME" ]; then
      message info "Creating Python Virtual Environment: $VENV_DIRECTORY/$ENVIRONMENT_NAME"
      ${PYTHON_PACKAGE} -m venv "$ENVIRONMENT_NAME"

      # Activate Python Virtual Environment
      source $VENV_DIRECTORY/$ENVIRONMENT_NAME/bin/activate

      # Install required Python packages for Python Virtual Environment
      if [ -z $QUIET ]; then
        python -m pip install --upgrade pip
        python -m pip install --upgrade setuptools
      else
        python -m pip -q install --upgrade pip
        python -m pip -q install --upgrade setuptools
      fi

      # Deactivate Python Virtual Environment
      deactivate
      message success "'$VENV_DIRECTORY/$ENVIRONMENT_NAME' Python Virtual Environment created."
  else
    message success "'$VENV_DIRECTORY/$ENVIRONMENT_NAME' Python Virtual Environment already exists."
  fi
}

function install_ansible {
  
  # Activate Python Virtual Environment prior to installing Ansible
  source $VENV_DIRECTORY/$ENVIRONMENT_NAME/bin/activate

  # Get output of pip list
  ANSIBLE_PIP_PACKAGE=$(pip list | grep ${ANSIBLE_PACKAGE} | awk '{print $1}')

  # Check if Ansible is installed
  if [ -z $ANSIBLE_PIP_PACKAGE ]; then
    message info "Installing ${ANSIBLE_PACKAGE}${ANSIBLE_VERSION}"
    if [ -z $QUIET ]; then
      # Install Ansible package via PIP
      pip install "${ANSIBLE_PACKAGE}${ANSIBLE_VERSION}"
    else
      # Quietly install Ansible package via PIP
      pip install -q "${ANSIBLE_PACKAGE}${ANSIBLE_VERSION}"
    fi
  fi

  message success "Ansible has been successfully installed"

  if [ -z $QUIET ]; then 
    # Print Ansible version details
    message info "Print Ansible Version"
    ansible --version
  fi

  # Deactivate Python Virtual Environment
  deactivate
}

# Get script arguments prior to executing script
while [[ "$1" == -* ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -a|--ansible)
      shift
      ANSIBLE_VERSION=${1:-"$ANSIBLE_VERSION"}
      ;;
    -d|--defaults)
      shift
      defaults
      exit 0
      ;;
    -e|-n|--environment|--name)
      shift
      ENVIRONMENT_NAME=${1:-"$ENVIRONMENT_NAME"}
      ;;
    -p|--python)
      shift
      PYTHON_VERSION=${1:-"$PYTHON_VERSION"}
      PYTHON_PACKAGE="python${PYTHON_VERSION}"      
      ;;
    -q|--quiet)
      QUIET="true"
      ;;
    -r|--root|--directory)
      shift
      VENV_DIRECTORY=${1:-"$VENV_DIRECTORY"}
      ;;
    -V|--version)
      message "Version: $VERSION"
      exit 0
      ;;
  esac
  shift
done

##########################################################################################
#                                       Main                                             #
#                                                                                        # 
#    This section is main portion of the script, that calls the functions to execute.    #
##########################################################################################

# Install Python3.x
# $PYTHON_VERSION - Default Python Version for installation
# $PYTHON_PACKAGE - Python package name for installation
install_python

# Create Python Virtual Environment
# $VENV_DIRECTORY - Python Virtual Environment directory
# $ENVIRONMENT_NAME - Default environment name for Python Virtual Environment
create_python_virtual_environment

# Install Ansible 2.X via PIP; this will include the ansible-core package
# $ANSIBLE_VERSION - Default Ansible Version for installation
install_ansible

message success "Script completed"