import json
from pathlib import Path

from terraform_vars_parser import TerraformVarsParser


WORKING_DIRECTORY = Path(__file__).parent


def obsolete(function):
    def _obsolete_function():
        raise DeprecationWarning(
            "This function has been deprecated in favor of the local_file terraform solution to write files"
        )

    return _obsolete_function()


def save_to_file(text, file_path):
    with (WORKING_DIRECTORY / file_path).open("w") as file:
        file.write(text)


def get_terraform_state():
    with (WORKING_DIRECTORY / 'terraform.tfstate').open('r') as file:
        return json.load(file)


def save_private_key_pem(key_name):
    terraform_state = get_terraform_state()

    private_key_resource = list(filter(
        lambda resource: (
            resource.get("module", None) == f"module.{key_name}"
            and resource.get("type", None) == "tls_private_key"
        ),
        terraform_state["resources"]
    ))[0]

    private_key_pem = private_key_resource["instances"][0]["attributes"]["private_key_pem"]

    save_to_file(private_key_pem, f"{key_name}.pem")


def save_output_variables(output_variables):
    output_text = "\n".join([
        f"{key}={value}"
        for key, value in output_variables.items()
    ])
    save_to_file(output_text, "output_variables.sh")


def get_ec2_instance(terraform_state):
    return terraform_state["resources"][0]["instances"][0]["attributes"]["master_public_dns"]


@obsolete
def after_deploy():
    variables_file = WORKING_DIRECTORY / "dev.tfvars"
    parser = TerraformVarsParser()
    parser.read_file(str(variables_file))

    ec2_ssh_key_name = parser.get("ec2_ssh_key_name")
    save_private_key_pem(ec2_ssh_key_name)

    terraform_state = get_terraform_state()
    output_variables = {
        "MASTER_EC2_IP": get_ec2_instance(terraform_state),
        "EC2_SSH_KEY_PEM_NAME": f"{ec2_ssh_key_name}.pem"
    }
    save_output_variables(output_variables)
