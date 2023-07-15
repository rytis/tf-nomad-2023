#!/bin/bash

export ANSIBLE_ROLES_PATH=/var/tmp/ansible/roles

ansible-playbook /var/tmp/ansible/playbooks/bootstrap-server.yml
