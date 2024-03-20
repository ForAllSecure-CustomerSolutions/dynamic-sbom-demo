$provisionScript = <<-'PROVISION'
set -euxo pipefail

apt-get -y update
DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade
DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install ca-certificates curl gnupg jq

dpkg -i /tmp/debian/flotsam*.deb
usermod -aG flotsam vagrant
PROVISION

$script = <<-'SCRIPT'
set -euxo pipefail

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get -y update
DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
usermod -aG docker vagrant

cat << EOF > /etc/docker/daemon.json
{
  "runtimes": {
    "flotsam": {
      "path": "/usr/bin/flotsam",
      "runtimeArgs": [
        "runc",
        "--",
        "runc"
      ]
    }
  },
  "default-runtime": "flotsam"
}
EOF

systemctl restart docker

install -m 0755 -o vagrant -g vagrant -d /home/vagrant/.docker
curl -sSfL https://raw.githubusercontent.com/docker/scout-cli/main/install.sh | runuser -u vagrant -- sh -s --
SCRIPT

vm_name = ENV['VM_NAME'] || 'default'
workspace_dir = ENV['CARGO_WORKSPACE_DIR'] || '..'
deb_package_dir = ENV['DEB_PACKAGE_DIR'] || "#{workspace_dir}/target/debian"

Vagrant.configure('2') do |config|
  config.vm.define vm_name

  config.vm.box = 'debian/bookworm64'

  config.vm.provision 'file', source: 'flotsam_0.1.0_34724c5_amd64.deb', destination: '/tmp/debian/'
  config.vm.provision 'shell', inline: $provisionScript
  config.vm.provision 'shell', inline: $script

  if File.file?('./docker-login.sh')
    config.vm.provision 'shell', path: './docker-login.sh'
  end

  if File.file?('./test.sh')
    config.vm.provision 'file', source: './test.sh', destination: '/tmp/test.sh'
  end

  config.vm.boot_timeout = 60

  # Disable NFS share
  config.nfs.verify_installed = false
  config.vm.synced_folder '.', '/vagrant', disabled: true
end
