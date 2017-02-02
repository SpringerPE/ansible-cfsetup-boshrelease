#!/usr/bin/env bash

if [ -z ${ANSIBLE_ROLES_PATH+x} ]; then
    ANSIBLE_ROLES_PATH=/var/vcap/packages/ansible-cfsetup/roles
else
    ANSIBLE_ROLES_PATH=/var/vcap/packages/ansible-cfsetup/roles:${ANSIBLE_ROLES_PATH}
fi
export ANSIBLE_ROLES_PATH
