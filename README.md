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
      security_groups:
      - name: sec1
        state: present
        context: running
        context_state: present
        rules:
        - name: "allow-proxy"
          protocol: tcp
          destination: "10.20.0.1/0"
          ports: "8080"
      quotas:
      - name: quota1
        state: present
        total_services: 100
        total_routes: 1000
        memory_limit: 1000
      users:
      - name: pepe@hola.com
        state: present
        password: hola
        given_name: Pepe
        family_name: Family
      - name: claudio@hola.com
        state: present
        password: hola
        given_name: Claudio
        family_name: Family
      orgs:
      - name: org1
        quota: quota1
        state: present
        users:
        - name: pepe@hola.com
        managers:
        - name: claudio@hola.com
        spaces:
        - name: test
        - name: second
      - name: org2
        state: present
        quota: quota1
        spaces:
        - name: live
          state: present
          managers:
          - name: claudio@hola.com
          security_groups:
          - name: sec1

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
* 6637: /var/vcap/packages/ansible/bin/ansible-playbook  -i /var/vcap/jobs/ansible-cfsetup/ansible/inventory /var/vcap/jobs/ansible-cfsetup/ansible/deploy.yml

PLAY [Cloud Foundry settings playbook] *****************************************

TASK [cf : Check PIP dependencies for ansible modules] *************************
ok: [api.test.cf.springer-sbm.com -> localhost] => (item={'key': u'cfconfigurator', 'value': u'0.2.1'})

TASK [cf : Config - Set global feature flags] **********************************
ok: [api.test.cf.springer-sbm.com -> localhost] => (item={u'name': u'user_org_creation', u'value': True})

TASK [cf : Config - Set global running environment variables group] ************
ok: [api.test.cf.springer-sbm.com -> localhost] => (item={u'name': u'HOLA', u'value': u'hola'})
ok: [api.test.cf.springer-sbm.com -> localhost] => (item={u'name': u'ADIOS', u'value': u'bye'})

TASK [cf : Config - Set global staging environment variables group] ************

TASK [cf : Config - Set global shared domains] *********************************

TASK [cf : Secgroups - Setting global security groups] *************************
included: /var/vcap/data/packages/ansible-cfsetup/130e121141cce7268e2651986b21eae4d6af91c9.1-bfdc6e9241b17fb425b68848d61379589ebb49e6/roles/cf/tasks/secgroup.yml for api.test.cf.springer-sbm.com

TASK [cf : Secgroup - Procesing security group sec1] ***************************
ok: [api.test.cf.springer-sbm.com -> localhost]

TASK [cf : Secgroup - Facts] ***************************************************
ok: [api.test.cf.springer-sbm.com -> localhost]

TASK [cf : Secgroup - Managing security group sec1: present] *******************
changed: [api.test.cf.springer-sbm.com -> localhost]

TASK [cf : Secgroup - Setting up security group rules] *************************
changed: [api.test.cf.springer-sbm.com -> localhost] => (item=(0, {u'destination': u'10.20.0.1/0', u'protocol': u'tcp', u'name': u'allow-proxy', u'ports': u'8080'}))

TASK [cf : Secgroup - Managing sec1 in space] **********************************

TASK [cf : Secgroups - Managing default security groups] ***********************
changed: [api.test.cf.springer-sbm.com -> localhost] => (item={u'rules': [{u'destination': u'10.20.0.1/0', u'protocol': u'tcp', u'name': u'allow-proxy', u'ports': u'8080'}], u'state': u'present', u'name': u'sec1'
, u'context': u'running', u'context_state': u'present'})

TASK [cf : Quotas - Processing quota definitions] ******************************
changed: [api.test.cf.springer-sbm.com -> localhost] => (item={u'memory_limit': 1000, u'state': u'present', u'total_routes': 1000, u'name': u'quota1', u'total_services': 100})

TASK [cf : Users - Managing users] *********************************************
changed: [api.test.cf.springer-sbm.com -> localhost] => (item={u'family_name': u'Family', u'state': u'present', u'password': u'hola', u'name': u'pepe@hola.com', u'given_name': u'Pepe'})
changed: [api.test.cf.springer-sbm.com -> localhost] => (item={u'family_name': u'Family', u'state': u'present', u'password': u'hola', u'name': u'claudio@hola.com', u'given_name': u'Claudio'})

TASK [cf : Orgs - Setting up organizations] ************************************
included: /var/vcap/data/packages/ansible-cfsetup/130e121141cce7268e2651986b21eae4d6af91c9.1-bfdc6e9241b17fb425b68848d61379589ebb49e6/roles/cf/tasks/org.yml for api.test.cf.springer-sbm.com
included: /var/vcap/data/packages/ansible-cfsetup/130e121141cce7268e2651986b21eae4d6af91c9.1-bfdc6e9241b17fb425b68848d61379589ebb49e6/roles/cf/tasks/org.yml for api.test.cf.springer-sbm.com

TASK [cf : Org - Procesing organization org1] **********************************
ok: [api.test.cf.springer-sbm.com -> localhost]

TASK [cf : Org - Facts] ********************************************************
ok: [api.test.cf.springer-sbm.com -> localhost]

TASK [cf : Org - Defining organization org1] ***********************************
changed: [api.test.cf.springer-sbm.com -> localhost]

TASK [cf : Org - Managing spaces for org1] *************************************
included: /var/vcap/data/packages/ansible-cfsetup/130e121141cce7268e2651986b21eae4d6af91c9.1-bfdc6e9241b17fb425b68848d61379589ebb49e6/roles/cf/tasks/space.yml for api.test.cf.springer-sbm.com
included: /var/vcap/data/packages/ansible-cfsetup/130e121141cce7268e2651986b21eae4d6af91c9.1-bfdc6e9241b17fb425b68848d61379589ebb49e6/roles/cf/tasks/space.yml for api.test.cf.springer-sbm.com

TASK [cf : Space - Procesing space test in org1 organization] ******************
ok: [api.test.cf.springer-sbm.com -> localhost]

TASK [cf : Space - Facts] ******************************************************
ok: [api.test.cf.springer-sbm.com -> localhost]

TASK [cf : Space - Managing space org1:test present] ***************************
changed: [api.test.cf.springer-sbm.com -> localhost]

TASK [cf : Space - Managing security groups for org1:test] *********************

TASK [cf : Space - Assigning developers to org1:test] **************************

TASK [cf : Space - Assigning managers to space org1:test] **********************

TASK [cf : Space - Assigning auditors to space org1:test] **********************

TASK [cf : Space - Procesing space second in org1 organization] ****************
ok: [api.test.cf.springer-sbm.com -> localhost]

TASK [cf : Space - Facts] ******************************************************
ok: [api.test.cf.springer-sbm.com -> localhost]

TASK [cf : Space - Managing space org1:second present] *************************
changed: [api.test.cf.springer-sbm.com -> localhost]

TASK [cf : Space - Managing security groups for org1:second] *******************

TASK [cf : Space - Assigning developers to org1:second] ************************

TASK [cf : Space - Assigning managers to space org1:second] ********************

TASK [cf : Space - Assigning auditors to space org1:second] ********************

TASK [cf : Org - Deleting spaces for org1] *************************************

TASK [cf : Org - Deleting organization org1] ***********************************

TASK [cf : Org - Create private domains to organization org1] ******************

TASK [cf : Org - Assigning users to organization org1] *************************
changed: [api.test.cf.springer-sbm.com -> localhost] => (item={u'name': u'pepe@hola.com'})
changed: [api.test.cf.springer-sbm.com -> localhost] => (item={u'name': u'claudio@hola.com'})

TASK [cf : Org - Assigning managers to organization org1] **********************
changed: [api.test.cf.springer-sbm.com -> localhost] => (item={u'name': u'claudio@hola.com'})

TASK [cf : Org - Assigning auditors to organization org1] **********************

TASK [cf : Org - Assigning billing_managers to organization org1] **************

TASK [cf : Org - Assigning default organization org1 for requested users] ******

TASK [cf : Org - Procesing organization org2] **********************************
ok: [api.test.cf.springer-sbm.com -> localhost]

TASK [cf : Org - Facts] ********************************************************
ok: [api.test.cf.springer-sbm.com -> localhost]

TASK [cf : Org - Defining organization org2] ***********************************
changed: [api.test.cf.springer-sbm.com -> localhost]

TASK [cf : Org - Managing spaces for org2] *************************************
included: /var/vcap/data/packages/ansible-cfsetup/130e121141cce7268e2651986b21eae4d6af91c9.1-bfdc6e9241b17fb425b68848d61379589ebb49e6/roles/cf/tasks/space.yml for api.test.cf.springer-sbm.com

TASK [cf : Space - Procesing space live in org2 organization] ******************
ok: [api.test.cf.springer-sbm.com -> localhost]

TASK [cf : Space - Facts] ******************************************************
ok: [api.test.cf.springer-sbm.com -> localhost]

TASK [cf : Space - Managing space org2:live present] ***************************
changed: [api.test.cf.springer-sbm.com -> localhost]

TASK [cf : Space - Managing security groups for org2:live] *********************
included: /var/vcap/data/packages/ansible-cfsetup/130e121141cce7268e2651986b21eae4d6af91c9.1-bfdc6e9241b17fb425b68848d61379589ebb49e6/roles/cf/tasks/secgroup.yml for api.test.cf.springer-sbm.com

TASK [cf : Secgroup - Procesing security group sec1] ***************************
ok: [api.test.cf.springer-sbm.com -> localhost]

TASK [cf : Secgroup - Facts] ***************************************************
ok: [api.test.cf.springer-sbm.com -> localhost]

TASK [cf : Secgroup - Managing security group sec1: present] *******************

TASK [cf : Secgroup - Setting up security group rules] *************************

TASK [cf : Secgroup - Managing sec1 in space live] *****************************
changed: [api.test.cf.springer-sbm.com -> localhost]

TASK [cf : Space - Assigning developers to org2:live] **************************

TASK [cf : Space - Assigning managers to space org2:live] **********************
changed: [api.test.cf.springer-sbm.com -> localhost] => (item={u'name': u'claudio@hola.com'})

TASK [cf : Space - Assigning auditors to space org2:live] **********************

TASK [cf : Org - Deleting spaces for org2] *************************************

TASK [cf : Org - Deleting organization org2] ***********************************

TASK [cf : Org - Create private domains to organization org2] ******************

TASK [cf : Org - Assigning users to organization org2] *************************

TASK [cf : Org - Assigning managers to organization org2] **********************

TASK [cf : Org - Assigning auditors to organization org2] **********************

TASK [cf : Org - Assigning billing_managers to organization org2] **************

TASK [cf : Org - Assigning default organization org2 for requested users] ******

PLAY RECAP *********************************************************************
api.test.cf.springer-sbm.com : ok=38   changed=14   unreachable=0    failed=0

Playbook run took 0 days, 0 hours, 0 minutes, 16 seconds

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

SpringerNature Platform Engineering, 
José Riguera López (jose.riguera@springer.com)


Copyright 2017 Springer Nature



# License

Apache 2.0 License
