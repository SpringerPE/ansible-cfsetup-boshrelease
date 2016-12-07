# Add-on BOSH Release for [ansible-boshrelease](https://github.com/SpringerPE/ansible-boshrelease)

Add-on release with ansible playbooks to manage Cloud Foundry resources:
users, security groups, quotas, feature flags, environment variables, organizations and spaces

The core functionality is provided by https://github.com/SpringerPE/ansible-cloudfoundry,
this is just an add-on to run the that ansible role in a Bosh errand.


## Usage

This is and add-on release, it will work only if it is deployed together with the 
*ansible-boshrelease* on the nodes, in particular with **ansible-deploy** job.
Have a look at [ansible-boshrelease](https://github.com/SpringerPE/ansible-boshrelease)
for the requirements and to see how it works.

Considering v2 manifest style, this could be an example:

```
name: cfsetup
# replace with `bosh status --uuid`
director_uuid: 1c799a52-154b-4fb3-b181-d81ec5f3c97b

releases:
- name: ansible
  version: latest
- name: ansible-cfsetup
  version: latest

stemcells:
- alias: trusty
  name: bosh-vsphere-esxi-ubuntu-trusty-go_agent
  version: latest

instance_groups:
- name: ansible-cfsetup
  lifecycle: errand
  instances: 1
  vm_type: medium
  stemcell: trusty
  vm_extensions: []
  azs:
  - Online
  networks:
  - name: online
  jobs:
  - name: ansible-deploy
    release: ansible
  - name: ansible-cfsetup
    release: ansible-cfsetup
  properties:
    ansible_cfsetup:
      credentials:
      - name: test
        api: "https://api.test.cf.springer-sbm.com"
        admin: "admin"
        password: "password"
      feature_flags:
      - name: user_org_creation
        value: true
      running_environment_variables:
      - name: HOLA
        value: hola
      - name: ADIOS
        value: bye

update:
  canaries: 1
  max_in_flight: 1
  serial: false
  canary_watch_time: 1000-60000
  update_watch_time: 1000-60000
```

You can add more Cloud Foundry environments in credentials to apply the same
settings to all of them (see also the `parallel` parameter to control the serialization/parallelism.

and that's all!, run `bosh-deploy`. Once the release has been deployed, you can run it as a errand:

```
# bosh errands
https://10.10.0.10:25555

+-----------------+
| Name            |
+-----------------+
| ansible-cfsetup |
+-----------------+
```

And then run the errand:

```
# bosh run errand ansible-cfsetup
https://10.10.0.10:25555
Acting as user 'admin' on deployment 'cfsetup' on 'pe-dogo-01'

Director task 2964
  Started preparing deployment > Preparing deployment. Done (00:00:00)

  Started preparing package compilation > Finding packages to compile. Done (00:00:00)

  Started creating missing vms > ansible-cfsetup/26fb59a0-2866-49f6-8644-fcd0e1d85b75 (0). Done (00:02:14)

  Started updating instance ansible-cfsetup > ansible-cfsetup/26fb59a0-2866-49f6-8644-fcd0e1d85b75 (0) (canary). Done (00:00:24)

  Started running errand > ansible-cfsetup/0. Done (00:00:07)

  Started fetching logs for ansible-cfsetup/26fb59a0-2866-49f6-8644-fcd0e1d85b75 (0) > Finding and packing log files. Done (00:00:01)

  Started deleting errand instances ansible-cfsetup > ansible-cfsetup/26fb59a0-2866-49f6-8644-fcd0e1d85b75 (0). Done (00:00:18)

Task 2964 done

Started         2016-12-06 23:27:58 UTC
Finished        2016-12-06 23:31:02 UTC
Duration        00:03:04

[stdout]
* 6641: /var/vcap/packages/ansible/bin/ansible-playbook  -i /var/vcap/jobs/ansible-cfsetup/ansible/inventory /var/vcap/jobs/ansible-cfsetup/ansible/deploy.yml

PLAY [Cloud Foundry settings playbook] *****************************************

TASK [cf : Check PIP dependencies for ansible modules] *************************
ok: [api.test.cf.springer-sbm.com -> localhost] => (item={'key': u'cfconfigurator', 'value': u'0.2.1'})

TASK [cf : Config - Set global feature flags] **********************************
changed: [api.test.cf.springer-sbm.com -> localhost] => (item={u'name': u'user_org_creation', u'value': True})

TASK [cf : Config - Set global running environment variables group] ************
changed: [api.test.cf.springer-sbm.com -> localhost] => (item={u'name': u'HOLA', u'value': u'hola'})
changed: [api.test.cf.springer-sbm.com -> localhost] => (item={u'name': u'ADIOS', u'value': u'bye'})

TASK [cf : Config - Set global staging environment variables group] ************

TASK [cf : Config - Set global shared domains] *********************************

TASK [cf : Secgroups - Setting global security groups] *************************

TASK [cf : Secgroups - Managing default security groups] ***********************

TASK [cf : Quotas - Processing quota definitions] ******************************

TASK [cf : Users - Managing users] *********************************************

TASK [cf : Orgs - Setting up organizations] ************************************

PLAY RECAP *********************************************************************
api.test.cf.springer-sbm.com : ok=3    changed=2    unreachable=0    failed=0   

Playbook run took 0 days, 0 hours, 0 minutes, 2 seconds

[stderr]
None

Errand 'ansible-cfsetup' completed successfully (exit code 0)
```

Of course, you can include the errand in the Cloud Foundry manifest, in the same
way as the smoke tests.



# Updating the role

The source code is a submodule of this repo, get it by running:

```
git submodule init
git submodule update
```

All the functionality is provided by: https://github.com/SpringerPE/ansible-cloudfoundry
The role is re-usable outside this release by re-defining a inventory with the variables
and a group_vars folder. Have a look at the examples on its repository.

All actions/playbooks (thanks to ansible) are idempotent.


# Author

José Riguera López (jose.riguera@springer.com)

SpringerNature Platform Engineering



# License

Apache 2.0 License
