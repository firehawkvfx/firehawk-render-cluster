variable "aws_region" {
  type = string
  default = null
}

locals {
  timestamp    = regex_replace(timestamp(), "[- TZ:]", "")
  template_dir = path.root
}

source "amazon-ebs" "openvpn-server-ami" { # Open vpn server requires vault and consul, so we build it here as well.
  ami_description = "An Open VPN Access Server AMI configured for Firehawk"
  ami_name        = "firehawk-base-openvpn-server-${local.timestamp}-{{uuid}}"
#   user_data       = "admin_user=openvpnas; admin_pw=openvpnas"
  user_data_file  = "${local.template_dir}/user_data.sh"
  instance_type   = "t2.micro"
  region          = "${var.aws_region}"
  source_ami_filter {
    filters = {
      description  = "OpenVPN Access Server 2.8.3 publisher image from https://www.openvpn.net/."
      product-code = "f2ew2wrz425a1jagnifd02u5t"
    }
    most_recent = true
    owners      = ["679593333241"]
  }
  ssh_username = "openvpnas"
#   ssh_password = "openvpnas"
}

build {
  sources = [
    "source.amazon-ebs.openvpn-server-ami"
    ]
  provisioner "shell" {
    inline         = [
        "unset HISTFILE",
        "history -cw",
        "echo === Waiting for Cloud-Init ===",
        "timeout 180 /bin/bash -c 'until stat /var/lib/cloud/instance/boot-finished &>/dev/null; do echo waiting...; sleep 6; done'",
        "echo === System Packages ===",
        "echo 'connected success'"
        ]
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    inline_shebang = "/bin/bash -e"
  }
}