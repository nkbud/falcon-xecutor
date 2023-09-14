locals {
  user_dir = "/home/ubuntu"
  aws_credentials = [
    "[default]",
    "aws_access_key_id = ${aws_iam_access_key.x.id}",
    "aws_secret_access_key = ${aws_iam_access_key.x.secret}",
  ]
  aws_config = [
    "[default]",
    "aws_region = us-east-1"
  ]
  init_script = [
    "sudo apt-get update",
    # 5s, update packages

    "sudo apt install docker.io jq unzip -y",
    # Xs, install docker, jq, unzip

    "sudo snap install aws-cli --classic",
    # 10s, install aws cli

    "mkdir -p ${local.user_dir}/.aws",
    "echo '${join("\n", local.aws_credentials)}' > ${local.user_dir}/.aws/credentials",
    "echo '${join("\n", local.aws_config)}' > ${local.user_dir}/.aws/config",
    # Xs, configure aws for the ubuntu user

    "sudo -u ubuntu aws s3api get-object --bucket falcon-xecutor --key dockerapp.zip ${local.user_dir}/dockerapp.zip",
    # Xs, use the ubuntu user to call s3

    "unzip ${local.user_dir}/dockerapp.zip -d ${local.user_dir}/dockerapp",
    # Xs, unzip self

    "sudo bash ${local.user_dir}/dockerapp/startup.sh",
    # run the startup

    "echo f"
    # trigger a redeploy by changing any line, such as echo
  ]
}