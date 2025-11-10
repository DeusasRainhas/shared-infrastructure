#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
reset='\033[0m'

function get_latest_runner_version(){
  local latest_release=$(curl -s https://api.github.com/repos/actions/runner/releases/latest)
  local version=$(echo "$latest_release" | grep -oP '(?<=tag_name": "v)\d+\.\d+\.\d+')
  echo "$version"
}

function download_runner(){
  if [ -z "$1" ]; then
    echo -e "[${red}ERROR${reset}] No version specified. Please provide a version to download."
    exit 1
  fi
  echo -e " - [${yellow}INFO${reset}]  Downloading GitHub Actions runner version $1"

  local version=$1
  local destination_dir=${2:-~/runner/$version}
  mkdir -p "$destination_dir"

  curl -o "$destination_dir/actions-runner-linux-x64-$version.tar.gz" -L "https://github.com/actions/runner/releases/download/v$version/actions-runner-linux-x64-$version.tar.gz" &> /dev/null || {
    echo -e "[${red}ERROR${reset}] Failed to download the runner. Please check the version and your internet connection."
    exit 1
  }
  echo -e " - [${green}OK${reset}]    GitHub Actions runner version $version downloaded successfully to $destination_dir."
}

function extract_runner(){
  local version=$1
  local destination_dir=${2:-~/runner/$version}
  if [ -z "$version" ]; then
    echo -e "[${red}ERROR${reset}] No version specified for extraction. Please provide a version."
    exit 1
  fi
  if [ ! -f "$destination_dir/actions-runner-linux-x64-$version.tar.gz" ]; then
    echo -e "[${red}ERROR${reset}] The specified file does not exist. Please ensure the file is downloaded before extraction."
    exit 1
  fi
  echo -e " - [${yellow}INFO${reset}]  Extracting GitHub Actions runner version $version..."
  tar -xzf "$destination_dir/actions-runner-linux-x64-$version.tar.gz" -C "$destination_dir"
}

function check_dependencies() {
  if ! command -v curl &> /dev/null; then
    echo -e "[${red}ERROR${reset}] curl is not installed. Please install curl to proceed."
    exit 1
  fi
  if ! command -v tar &> /dev/null; then
    echo -e "[${red}ERROR${reset}] tar is not installed. Please install tar to proceed."
    exit 1
  fi
}

function remove_compressed_files() {
  local version=$1
  local destination_dir=${2:-~/runner/$version}
  if [ -f "$destination_dir/actions-runner-linux-x64-$version.tar.gz" ]; then
    echo -e " - [${yellow}INFO${reset}]  Removing compressed file actions-runner-linux-x64-$version.tar.gz..."
    rm "$destination_dir/actions-runner-linux-x64-$version.tar.gz"
    echo -e " - [${green}OK${reset}]    Compressed file removed successfully."
    echo -e " - [${green}OK${reset}]    GitHub Actions runner installation completed successfully."
  else
    echo -e " - [${yellow}INFO${reset}]  No compressed file found to remove."
  fi
}

function print_usage() {
  echo -e "Usage: $0 [version] [destination_directory]"
  echo -e "  version: The version of the GitHub Actions runner to download (default: latest)."
  echo -e "  destination_directory: The directory where the runner will be downloaded and extracted (default: ~/runner/<version>)."
}

function footer() {
  echo -e "You can now configure the runner using the config.sh script in the downloaded directory."
  echo -e "Run the following command to start the configuration experience:"
  echo -e "./config.sh --url <your-repo-url> --token <your-token>"
}

function is_installed() {
  local version=$1
  local destination_dir=${2:-~/runner/$version}
  if [ -d "$destination_dir" ]; then
    echo -e " - [${green}OK${reset}]    GitHub Actions runner version $version is already installed in $destination_dir."
    echo -e " - [${yellow}INFO${reset}]  If you want to reinstall, please remove the existing directory first."
    footer
    exit 0
  fi
}

function is_help() {
  if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    print_usage
    exit 0
  fi
}

function move_configuration_script() {
  local version=$1
  local destination_dir=${2:-~/runner/$version}
  if [ -d "$destination_dir" ]; then
    echo -e " - [${yellow}INFO${reset}]  Moving configuration script to $destination_dir..."
    mv ./configuration.sh "$destination_dir/configuration.sh"
    echo -e " - [${green}OK${reset}]    Configuration script moved successfully."
  else
    echo -e "[${red}ERROR${reset}] Destination directory does not exist. Please create it first."
    exit 1
  fi
}

function main(){
  is_help "$1"
  
  check_dependencies
  local latest_version=$(get_latest_runner_version)
  is_installed "$latest_version"
  download_runner "$latest_version"
  extract_runner "$latest_version"
  remove_compressed_files "$latest_version"
  move_configuration_script "$latest_version"
  footer
}

main "$@"
