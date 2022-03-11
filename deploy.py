import sys
from importlib import import_module

from python_terraform import Terraform


def terraform_deploy(working_directory):
    tf = Terraform(working_dir=working_directory)
    print("Initialize Terraform")
    tf.init()
    print("Plan")
    tf.plan(var_file="dev.tfvars", lock=False)
    print("Apply")
    tf.apply(var_file="dev.tfvars", lock=False, skip_plan=True)


def main(working_directory):
    print(f"Deploy {working_directory}")
    terraform_deploy(working_directory)

    print("Execute after deploy script")
    working_directory_module = import_module(working_directory)
    working_directory_module.after_deploy()

    print("Deployment has finished")


if __name__ == "__main__":
    main(sys.argv[1])
