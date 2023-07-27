#!/bin/bash

##########################################################################################
#                                   Global Variables                                     #
#                                                                                        # 
# These variables are default variables that can be overwritten during script execution. #
# Use the --help option to see script usage                                              # 
##########################################################################################

# Default Ansible Version; Ansible will be installed using 'pip' - https://pypi.org/project/ansible/
ANSIBLE_VERSION=">=8.0.0"

# Default environment name for Python Virtual Environment
ENVIRONMENT_NAME="python3-venv"

# Determine package manager; DO NOT EDIT this variable unless necessary
PACKAGE_MANAGER=$(command -v yum || command -v apt-get)

# Default Python Version
PYTHON_VERSION="3"

# Python package name; DO NOT EDIT this variable unless necessary
PYTHON_PACKAGE="python$PYTHON_VERSION"

# This is the base directory to store Python Virtual Environments
#
# Example: $VENV_DIRECTORY/$ENVIRONMENT_NAME
#          /home/user/venv/python3-venv
VENV_DIRECTORY="$HOME/venv"

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
  message_status=$(echo "$1" | awk '{print tolower($0)}')

  # Execute message based on status
  if [ "$message_status" = "error" ]; then
    message_error "$2"
  elif [ "$message_status" = "info" ]; then
    message_info "$2"
  elif [ "$message_status" = "success" ]; then
    message_success "$2"
  elif [ "$message_status" = "warning" ]; then
    message_warning "$2"
  else
    echo "$1"
  fi
}

function usage {
  # Usage/Help function
  message "  This script is meant to help with creating Python Virtual Environments for Ansible use."
  message ""
  message "  Syntax: python-virtualenv-setup.sh [-a|d|e|h|n|r|p|v|V]"
  message "" 
  message "  Options:"
  message "    -a     | --ansible               Ansible-Core version to install"
  message "    -d     | --defaults              Display default settings"
  message "    -e, -n | --environment, --name   Python Virtual Environment name to be created"
  message "    -h     | --help                  Show help"
  message "    -r     | --root, --directory     Root directory for Python Virtual Environments"
  message "    -p     | --python                Python version to install"
  message "    -v     | --verbose               Add verbosity to the script"
  message "    -V     | --version               Display version of script"
  message ""
}

function defaults {
  message info "Python Version: $PYTHON_VERSION"
  message info "Python Package: $PYTHON_PACKAGE"
  message info "Ansible Version: $ANSIBLE_VERSION"
  message info "Environment Name: $ENVIRONMENT_NAME"
  message info "Virtual Environment Directory: $VENV_DIRECTORY/$ENVIRONMENT_NAME"
}

function install_python {
  
  function version_check {

    # if [[ $PACKAGE_MANAGER = *apt-get* ]]; then
    #   # Create python_package_check var
    #   python_package_check=$(dpkg-query -Wf'${db:Status-abbrev}' $python_ver 2>/dev/null | grep -q '^i'; then)

    #   if [ ! -z $python_package_check ]; then
    #     echo -e "${SUCCESS}Python package '$python_ver' is already installed.${RESET}"
    #     return 
    #   else
    #     echo "Python package '$python_ver' is not installed on this operating system."

    #     echo "Checking if Python package '$python_ver' is available to install."
    #     python_package_install=$(apt search . | cut -f 1 -d "/" | grep -e "^${python_ver}$")

    #     if [ ! -z "$python_package_install" ]; then
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
      # Create python_package_check var
      python_package_check=$(rpm -qa ${python_pkg})
    fi

    # if [[ $PACKAGE_MANAGER = *apt-get* ]]; then

    # fi

    # if [ ! -z $python_package_check ]; then
    #   echo -e "${SUCCESS}Python package '$python_ver' is already installed.${RESET}"
    #   return 
    # else
    #   echo "Python package '$python_ver' is not installed on this operating system."

    #   echo "Checking if Python package '$python_ver' is available to install."
    #   python_package_install=$(yum list -q | grep $python_ver)

    #   if [ ! -z "$python_package_install" ]; then
    #     echo -e "${SUCCESS}Python package '$python_ver' is available to install on this operating system.\n ${RESET}"
    #     return 0
    #   else
    #     echo -e "${ERROR}Python package '$python_ver' is not available for install on this operating system. Please make another selection.\n ${RESET}"
    #     return 1
    #   fi
    # fi
  }
  version_check
}

function create_python_virtual_environment {
  
  # Create root directory of Python Virtual Environments
  if [ ! -d "$VENV_DIRECTORY" ]; then
    message info "'$VENV_DIRECTORY' directory is now being created."
    mkdir $VENV_DIRECTORY
  fi

  # Install pip and upgrade in each Python venv environments
  cd $VENV_DIRECTORY

  if [ ! -d "$VENV_DIRECTORY/$ENVIRONMENT_NAME" ]; then
      message info "Creating Python Virtual Environment: $VENV_DIRECTORY/$ENVIRONMENT_NAME"
      ${PYTHON_PACKAGE} -m venv "$ENVIRONMENT_NAME"

      source $VENV_DIRECTORY/$ENVIRONMENT_NAME/bin/activate
      python -m pip install --upgrade pip
      python -m pip install --upgrade setuptools

      # Deactivate Python Virtual Environment
      deactivate
  fi
}

# function install_ansible {

# }

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
    -r|--root|--directory)
      shift
      VENV_DIRECTORY=${1:-"$VENV_DIRECTORY"}
      ;;
  esac
  shift
done


# install_python
# create_python_virtual_environment
# install_ansible
# create_aliases