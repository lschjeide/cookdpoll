# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.require_version ">= 1.5.0"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.ssh.pty = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder ".", "/vagrant", type: "rsync"

  # Vagrant info from https://github.com/mitchellh/vagrant-aws
  # keeping credentials outa source with:
  # https://github.com/zwily/aws-keychain-util
  # aws-creds shell <dius-env>
  # vagrant up --provider=aws

  config.vm.hostname = "cookdpoll-berkshelf"

  config.omnibus.chef_version = :latest

  config.vm.box = "dummy"

  config.berkshelf.enabled = true

  config.vm.provider :aws do |aws, override|
    aws.access_key_id = ENV['AWS_ACCESS_KEY_ID']
    aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    aws.keypair_name = "jenkins-slave-key"
    aws.security_groups = ["poll-security-tmorgan"]

    aws.ami = "ami-fd4724c7"
    #aws.region = ENV['AWS_REGION']
    aws.region = "ap-southeast-2"
    aws.availability_zone = "ap-southeast-2b"
    aws.instance_type = "t2.small"
    aws.tags = {'Name' => ENV['AWSNAME'], 'Live' => 'true', 'created-by' => 'tmorgan@dius.com.au'}

    override.ssh.username = "ec2-user"
    override.ssh.private_key_path = "~/.ssh/jenkins-slave-key"
  end

  config.vm.provision :chef_solo do |chef|
    chef.custom_config_path = "Vagrantfile.chef"
    chef.run_list = [
        "recipe[cookdpoll::default]"
    ]
  end
end
