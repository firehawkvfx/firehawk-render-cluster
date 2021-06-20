data "aws_instance" "verify" {
  count = try( length(var.instance_id), 0 ) > 0 ? 1 : 0
  instance_id = var.instance_id
}

resource "null_resource" "sqs_notify" {
  count = length( data.aws_instance.verify ) > 0 ? 1 : 0 # if a valid instance was found, update the sqs data.

  triggers = {
    instance_dependency = length( data.aws_instance.verify ) > 0 ? data.aws_instance.verify[0].id : null
  }
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
      ${path.module}/modules/firehawk-auth-scripts/sqs-send-deadline-payload --resourcetier "${var.resourcetier}"
EOT
  }
}

# below was deprecated in favor of the simpler standardised command above.
# ${path.module}/modules/firehawk-auth-scripts/sqs-notify --resourcetier "${var.resourcetier}" --sqs-queue-url "${var.sqs_remote_in_deadline_cert_url}" --host1 "${var.host1}" --host2 "${var.host2}" --token-policy deadline_client --token-use-limit "${var.token_use_limit}"
