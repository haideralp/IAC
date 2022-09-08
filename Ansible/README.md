# Ansible - Configuration Management ?

## Diagram Display of Ansible Configuration In Hybrid Setting

![image](https://user-images.githubusercontent.com/97620055/188432069-1eca356a-9bc1-41c2-9fcc-0b707825a4ff.png)


## What is Ansible ?
- A powerful automation tool, which makes it easier (simplifies) for you to provision, configure and deploy your product on web servers. It improves the scalability, consistency, and reliability of your IT environment. 

## Benefits of Ansible

- Free: Ansible is an open-source tool.
- Very simple to set up and use: No special coding skills are necessary to use Ansible’s playbooks (more on playbooks later).
- Powerful: Ansible lets you model even highly complex IT workflows. 
- Flexible: You can orchestrate the entire application environment no matter where it’s deployed. You can also customize it based - on your needs.
- Agentless: You don’t need to install any other software or firewall ports on the client systems you want to automate. You also   don’t have to set up a separate management structure.
- Efficient: Because you don’t need to install any extra software, there’s more room for application resources on your server.

## Running of Multiples VMs: Controller, Web (Agent), Database (Agent)
  
- Using the vagrant file in IAC repository I spun up three virtual machines that are defined as a controller, web and database as per the diagram shown. 
- Start Vms: `vagrant up` then check it was successfull with `vagrant status`, if not do so individually. 
- Ensure three distinguish IP addresses are allocated for them. Controller: `192.168.33.12`, Web:`192.168.33.10`, DB:`192.168.33.11`
- Check for internet connection on nodes using, `ping ip address of vm` individually.
- Ensure `sudo apt update/upgrade -y` are run on the agent nodes as well as controller.
  

## Setting Up Ansible Controller 

- Ensure python 2.7 and above is installed. 
- Perform: `sudo apt update/upgrade -y` 
- Installed any missed software: `sudo apt-get install software-properties-common`
- Link ansible repository to local host: `sudo apt-add-repository ppa:ansible/ansible`
- Install ansible: `sudo apt-get install ansible -y`
- Check version of ansible: `ansible --version`
- Default ansible directory: `cd /etc/ansible/`
- Intstall tree for better visualisation of files and folders: `sudo apt install tree`

## Accessing Agent Nodes From Controller
  
- SSH into specified node (web/db) using: `ssh vagrant@ipofagentnode(app/db)`
- First time will ask you to confirm, type yes
- Specify password by typing > default password: `vagrant`
  
## Setting up SSH connection from controller to nodes:

- Running `sudo ansible nodename -m ping` will give error due to security reasons so this was then configured in hosts file located in default `cd /etc/ansible/`.
- Enter hosts file with `sudo nano hosts` once in the default location. 
- Specify the settings as follows:
    * `[web]`
      `192.168.33.10 ansible_connection=ssh ansible_ssh_user=vagrant ansible_ssh_pass=vagrant`
    *  [db]
      `192.168.33.11 ansible_connection=ssh ansible_ssh_user=vagrant ansible_ssh_pass=vagrant`

- Ensure the file.pem content is present in controller for connection. 
- Once in cloud, hosts file will look like this:    
    
    *  `[aws-ansible]`
       `ec2-instance ansible_host=ec2-ip ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/file.pem`
    
    * `[aws-app]`
      `ec2-instance ansible_host=ec2-ip ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/file.pem` 
    
    * `[aws-db]`
    *  `ec2-instance ansible_host=ec2-ip ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/file.pem`


## Playbook Creations - Best Practice Commands

- `cd /etc/ansible` - Default ansible directory (location of hosts/inventory)
- `ansible-playbook PLAYBOOK_NAME --syntax-check` - ensure syntax is correct prior to running.
- `block:` - this allows you to write multiple shell lines in yaml.
- `ansible-playbook filename.yml` - Running playbook using this command.
- `ansible all -a "uname -a"` - Check os version of all nodes running in hosts
- `ansible nodename -a "free"`- determines free memory available.
- `ansible web/all -a "date" >> filename (to save into a file from console)` - save date to file the date.
- `ansible web/all -m shell -a "uptime"` - Check uptime 
- `ansible web -m copy -a "src=/etc/ansible/test.txt dest=/home/vagrant"` - Copy command from src folder to destination node.  


### NGINX Installation On Web

``` yaml
# create a playbook to install nginx inside web
# --- three dashes at the start of the file    

---

# add hosts or name of the host server
- hosts: web

# indentation is extremely important
# gather live information
  gather_facts: yes

# we need admin permissions
  become: true

# add the instructions
  tasks:
  - name: Install Nginx
    apt: pkg=nginx state=present

# the nginx server status is running
``` 

### Reverse Proxy

- Pre-requistes carried - copied content from server settings on nginx and created a default file in controller with new settings.
- Ensure when creating reverse proxy file as default (same name will overwrite it), specify web ip: `192.168.33.10`.
- Create a playbook file using `sudo nano filename.yml`
- The first method and easier method is to create `default` file on controller in ansbile directory and replace it on web using the playbook code below: 

``` yaml
# Setting up playbook to create reverse proxy for web server. 

---

# Add host name
- hosts: web

# Gather live information
  gather_facts: yes

# Admin Access Needed
  become: yes

# Adding Instructions
  tasks:
  - name: Reversy Proxy - Copy default file from controller to webserver
    copy:
        src: /etc/ansible/default
        dest: /etc/nginx/sites-available/default
  
  - name: Make sure NGINX service is running after setting up. 
    become: yes
    service:
      name: nginx
      state: restarted
      enabled: yes
```

-  The second method which I implemented on second iteration was to do set up reverse proxy using playbook alone as this is more relevant in a production environment. I used the code below:

``` yaml 
---
- name : Configure the Reverse Proxy for NodeAPP
  hosts: web


  tasks:
  - name: Disable NGINX Default Virtual Host
    become: yes
    ansible.legacy.command:
      cmd: unlink /etc/nginx/sites-enabled/default

  - name: Create NGINX conf file
    become: yes
    file:
      path: /etc/nginx/sites-available/node_proxy.conf
      state: touch

  - name: Amend NGINX Conf file
    become: yes
    blockinfile:
      path: /etc/nginx/sites-available/node_proxy.conf
      marker: ""
      block: |
        server {
            listen 80;
            location / {
                proxy_pass http://192.168.33.10:3000;
            }
        }

  - name: Link NGINX Node Reverse Proxy
    become: yes
    command:
      cmd: ln -s /etc/nginx/sites-available/node_proxy.conf /etc/nginx/sites-enabled/node_proxy.conf

  - name: Make sure NGINX service is running
    become: yes
    service:
      name: nginx
      state: restarted
      enabled: yes
```  

## Playbook To Migrate App folder fom Repository

- The next step I took was to clone my repository containing the app folder onto web using the following code:

``` yaml
 # Setting up playbook to clone app folder to web web server. 

---

# Add host name
- hosts: web

# Gather live information
  gather_facts: yes

# Admin Access Needed
  become: yes

# Adding Instructions
  tasks:
   name: Clone github repository
   ansible.builtin.git:
       repo: https://github.com/haideralp/CI-CD.git
       dest: /home/vagrant
       clone: yes
       update: yes
```

# Creating Nodejs & Npm Playbook

- Once the reverse proxy is configured, create playbook to configure nodejs and npm installation.
- Enter the configs as below:

``` yaml
# Create a playbook to install node and npm are inside web.
# --- three dashes at the of the file of YAML

---

# Add hosts or Name of host server.
- hosts: web
# indentation is EXTREMELY IMPORTANT
# Gather live  information
  gather_facts: yes
# Admin Access 
  become: true

#Add the instructions for nodejs and npm

# Install in nodejs & npm in webserver
  tasks:

  - name: Retrieve source for nodejs
    shell: curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - 
  
  - name: Install nodejs
    shell: sudo apt-get install -y nodejs 

  - name: Install NPM
    apt: pkg=npm state=present

# Ensure pm2 is made globally - downloading
  - name: Install pm2
    npm:
      name: pm2
      global: yes

# Enter appclone folder 
  - name: 
    shell: cd app/appclone

# Install NPM
  - name: install npm
    shell: npm install
```
 
## App Deployment on Web

- After the relevant dependencies had been installed, I configured the deployment code as follws:

``` yaml
# Setting up playbook for deployment of app on web with npm start
---

- hosts: web

  become: yes

  tasks:

# Enter into appclone folder on web
  - name: 
    shell: cd app/appclone

# Run App with npm start
  - name: start npm
    start: npm start
```

## Mongodb Database Configuration 

- Now it is time to configure the database, this was done using the following code for the playbook:
- Note: `sudo apt-get update/upgrade -y` were run prior to running any playbook on the nodes.

``` yaml
# Mongodb Playbook Config
---
- hosts: db
  gather_facts: true
  become: true

  tasks:
  - name: install mongodb
    apt: pkg=mongodb state=present

  - name: Remove mongodb file
    file:
     path: /etc/mongodb.conf
     state: absent
  
  - name: Touch a file, using symbolic modes to set permission (equivalent to 0644)
    file:
     state: touch
     path: /etc/mongodb.conf
     mode: u=rw,g=r,o=r

  - name: Insert mutliple lines and backup
    blockinfile:
     path: /etc/mongodb.conf
     backup: yes
     block: |
       "storage:
         dbPath: /var/lib/mongodb
         journal:
           enabled: true
       systemLog:
         destination: file
         logAppend: true
         path: /var/log/mongodb/mongod.log
       net:
         port: 27017
         bindIp: 0.0.0.0"
```

## Setting DB_Host Variable

```yaml

# Playbook Setting DB Host and Restarting App

# Downloading pm2

- name: Seed and Run App 
  become_user: root
  shell: |
  environment:
    DB_HOST: mongodb://ubuntu@<Priv-DB IP>:27017/posts?authSource=admin
  cd appclone/app
  node seeds/seed.js.
  pm2 kill
  pm2 start app.js
```



    


Ansible Ping

Go into hosts specify ip, connection type, user name and password. 

sudo ansible web -m ping 

Recieved 'pong' status - 


default directoy - looked for entry- web - sends to rrequest to it is alive. Security checked. so we gave permission.
need to make sure end point are awake - can cannot to.
alwasy ssh from local host when debugging. otherwsie cannot from controller.

## EC2 Launch on AWS

- I used the process below to launch EC2 isntances using Ansible:
  
### Key Dependencies:
  
  - Ansible-Vault configured (to encrypt of aws access and secret keys) 
  - Python 3.7 (3.6.9 - worked for my example) > `sudo apt install python3-pip -y`
  - pip3 installed > `pip3 install boto boto3` 
  - awscli installed > `pip3 install awscli`
  * Ensure the to create a `group_vars` inside it a `all` folder, so structure looks like this `/etc/ansible/group_vars/all/file.yml`. This is where the AWS secret/access keys will be stored, 
  * To run playbook for ec2 instances from ansible is `sudo ansible-playbook filename.yml --ask-vault-pass --tags create_ec2`.
  * Automation of ssh key access is needed 
    * Generate another keypair eng122 as well as create eng122.pem (aws key - same name)
    * Copy content of file.pem from local host to created eng122.pem in controller.
    * Playbook upload the .pub file to ec2 for access. 
  
### Ansible Vault Creation
- Follow the steps below:
  1. Create directory `sudo mkdir group_vars/all`
  2. Create ansible vault file.yml > `sudo ansible-vault create pass.yml`
  3. Give it vault password (remember will be required for authentication)
  4. Launch insert mode in vim with `i`.
  5. Enter the aws keys > `aws_access_key: xxxxxx / aws_secret_key: xxxxxx`
  6. Exit vim by > `ESC --> :wq!` and press `Enter`.
  7. To be able to edit ansbile-vault file.yml give permissions using > `sudo chmod 600 file.yml`
  8. Check this has beend done with `ll`

### Security Keypair Generation

- Got to directory /etc/ansible/.ssh/ if .ssh not present create it. 
- Create keypair with `sudo ssh-keygen -t rsa -b 4096`, give it a name so for this example I did eng122.
- Copy and paste content using `cat filename.pem` from local host into same file in controller use > `clip < ~/.ssh/key.pem`. 

## Execute EC2 Launch Playbook using code below:

- I constructed the following playbook code to launch ec2 instance:

``` yaml 

# AWS Playbook
---
- hosts: localhost
  connection: local
  gather_facts: True
  become: True
  vars:
    key_name: eng122
    region: eu-west-1
    image:  ami-0c31b3fe91357577c
    id: "Ansible for AWS"
    sec_group: "sg-0bba8ba0a45e78035"
    subnet_id: "subnet-0429d69d55dfad9d2"
# add the following line for force python 3 if errors
    #ansible_python_interpreter: /usr/bin/python3
  tasks:

    - name: Facts
      block:

      - name: Get instances facts
        ec2_instance_facts:
          aws_access_key: "{{aws_access_key}}"
          aws_secret_key: "{{aws_secret_key}}"
          region: "{{ region }}"
        register: result

    
    - name: Provisioning EC2 instances
      block:

      - name: Upload public key to AWS
        ec2_key:
          name: "{{ key_name }}"
          key_material: "{{ lookup('file', '~/.ssh/{{ key_name }}.pub') }}"
          region: "{{ region }}"
          aws_access_key: "{{aws_access_key}}"
          aws_secret_key: "{{aws_secret_key}}"


      - name: Provision instance(s)
        ec2:
          aws_access_key: "{{aws_access_key}}"
          aws_secret_key: "{{aws_secret_key}}"
          assign_public_ip: true
          key_name: "{{ key_name }}"
          id: "{{ id }}"
          vpc_subnet_id: "{{ subnet_id }}"
          group_id: "{{ sec_group }}"
          image: "{{ image }}"
          instance_type: t2.micro
          region: "{{ region }}"
          wait: true
          count: 1
          instance_tags:
            Name: eng122-haider-ansibleapp

      tags: ['never', 'create_ec2']

```

### Connection to EC2 Instance From Ansible - Ping

- To connect instances from ansible ping test must be performed as below:
- Ensure hosts are mentioned in the hosts file. 
- First  - test connection individually --> `sudo ping ip address of instance` 
- Second - test connection from controller --> `sudo ansible all -m ping --ask-vault-pass` 

- I had permision denied issues - still working on why that was - see debugging steps below or remove .pem on hosts. 
- I was able to ssh into my instance using the command below from ansible: `sudo ssh -i ~/.ssh/eng122 ubuntu@ec2-ip.eu-west-1.compute.amazonaws.com`. 
  
## Important Links For Ansible

* Documentation is rapid for ansbile ensure to check regulary for latest updates. 
  
## Debuggin Workaround 

 **Steps To Ensure Permission for controller + key.pem** 

- Allow controller to ssh into all nodes / port 22 allow it for agent node for all
- Ensure you have the valid key in your controller
- SSH into agent node from controller before you try to ping
- Ad agent ip and the valid key ~/.ssh/file.pem in your hosts
- sudo chmod 400 filename.pem. 

**Manually setting on AWS Cloud** 
    
    step 1 --> launch 3 ec2 instance on aws console - controller, app and node. 
    step 2 -->  update and upgrade in the user
    step 2.2 --> generate newfile.pem
    step 2.3 --> move/copt file.pem to your local host .ssh as well
    step 3 --> ssh into these servers from your local host
    step 4 --> ssh into these servers from your ansible controller]
    step 5-->  add ips to your hosts file as well as the file.pem then ping

