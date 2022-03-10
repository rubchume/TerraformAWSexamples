import sys
from importlib import import_module

from python_terraform import Terraform


def terraform_deploy(working_directory):
    tf = Terraform(working_dir=working_directory)
    tf.init()
    tf.plan(var_file="dev.tfvars", lock=False)
    tf.apply(var_file="dev.tfvars", lock=False, skip_plan=True)


def main(working_directory):
    terraform_deploy(working_directory)

    working_directory_module = import_module(working_directory)
    working_directory_module.after_deploy()


if __name__ == "__main__":
    main(sys.argv[1])
