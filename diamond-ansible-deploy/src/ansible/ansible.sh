#!/bin/bash
# Run ansible to configure container host and deploy container
# 
# Note: the playbook would normally be run by some orchestration (e.g. Jenkins, Go, TeamCity)

# Check ansible configuration
#
ansible dmd_daemons -i hosts --private-key=KeyPair.pem -u admin -m ping

# Run the project playbook
#
ansible-playbook playbook.yml -i ./hosts --private-key=KeyPair.pem -u admin --extra-vars "docker_tag=${project.version}"