# devsecops

# Requirements
- Requires awscli + lab

# Run cloudformation template to install k3s cluster
```shell
./create.sh
```

## Check cluster state
on master node (connected via ssh)
```shell
k3s kubectl get nodes
```

# Install Github Actions runner (self hosted)
```shell
# Create a folder
$ mkdir actions-runner && cd actions-runner

# Download the latest runner package
$ curl -o actions-runner-linux-x64-2.328.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.328.0/actions-runner-linux-x64-2.328.0.tar.gz

# Optional: Validate the hash
$ echo "<hash>  actions-runner-linux-x64-2.328.0.tar.gz" | shasum -a 256 -c

# Extract the installer
$ tar xzf ./actions-runner-linux-x64-2.328.0.tar.gz

# Create the runner and start the configuration experience
$ ./config.sh --url https://github.com/RoMinjun/devsecops --token AZWGS5G5K2ZE6C5QZPYXXHDIXR3PS
```

## Create systemd service instead of run.sh to make it persistent
Add the following to `/etc/systemd/system/github-runner.service`
```conf
[Unit]
Description=GitHub Actions Runner
Wants=network-online.target
After=network-online.target
StartLimitIntervalSec=60
StartLimitBurst=10

[Service]
# Run as your ubuntu user
User=ubuntu
Group=ubuntu

# Runner install directory
WorkingDirectory=/home/ubuntu/actions-runner

# Start the runner
ExecStart=/bin/bash /home/ubuntu/actions-runner/run.sh

# Shutdown handling
KillSignal=SIGINT
KillMode=control-group
TimeoutStopSec=30

# Auto-restart
Restart=always
RestartSec=5s

# Journald logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=github-runner

[Install]
WantedBy=multi-user.target
```

### Prepare usage of service
```shell
# Ensure run.sh is executable
chmod +x /home/ubuntu/actions-runner/run.sh

# Install + enable the service
sudo systemctl daemon-reload
sudo systemctl enable --now github-runner.service
```

#### Watch logs
```shell
journalctl -u github-runner -f
```

---

# Prepare github actions workflow 

## create ns for app
```shell
k create ns 531630-app 
```

## Create docker-registry secret
screenshots in the word doc
```shell
k -n 531630-app create secret docker-registry <studentnumber>-regsec --docker-server=docker.io --docker-username=<rominjun> --docker-password='<passwd>' --docker-email=<email>
```

