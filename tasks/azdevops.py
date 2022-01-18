import os
import sys
from invoke import task
import pathlib

from tomlkit import string


current_file_dir = pathlib.Path(__file__).parent.absolute()
home_dir=f'{current_file_dir}/..'
azuredevops_storage_ressource_group = "azure_devops_rg"
azuredevops_storage_account_name = "azuredevopstest"
azuredevops_storage_state = "state"

@task
def login(c):
    az_user = os.getenv("AZ_USER",None)
    az_password = os.getenv("AZ_PASSWORD",None)
    result = c.run("az account show -o none", hide=True, warn=True)
    if az_user!=None and az_password!=None :
        c.run(f"az login -u {az_user} -p {az_password}")
    elif result.ok==False:
        c.run("az login")
    print("You are logged in!")

    
@task(pre=[login])
def setup_storage(c):
    location = "westeurope"
    c.run(f"az group create --location {location} --resource-group {azuredevops_storage_ressource_group}")
    c.run(f"az storage account create -n {azuredevops_storage_account_name} -g {azuredevops_storage_ressource_group} -l {location} --sku Standard_LRS")
    c.run(f"az storage container create -n {azuredevops_storage_state} --account-name {azuredevops_storage_account_name}")
    

def read_azdevops_environment():
    az_devops_token = os.getenv("AZ_DEVOPS_AGENT_TOKEN", None)
    az_devops_url = os.getenv("AZ_DEVOPS_AGENT_URL", None)
    if az_devops_token == None or az_devops_url == None:
        sys.exit("ERROR: AZ_DEVOPS_AGENT_TOKEN and AZ_DEVOPS_AGENT_URL need to be set")
    os.environ["TF_VAR_az_devops_token"] = az_devops_token
    os.environ["TF_VAR_az_devops_url"] = az_devops_url
    
@task(pre=[login])
def init(c):
    environment = os.getenv("ENVIRONMENT","test")
    read_azdevops_environment()
    
    os.chdir(home_dir)
    c.run(f'''rm -rf .terraform/modules .terraform/terraform.tfstate tf.plan
              terraform init -input=false \
              -backend-config="resource_group_name={azuredevops_storage_ressource_group}" \
              -backend-config="storage_account_name={azuredevops_storage_account_name}" \
              -backend-config="container_name={azuredevops_storage_state}" \
              -backend-config="key=environment/{environment}-azure-setup.tfstate" \
              -force-copy''')
    
    
@task(pre=[init])
def plan(c):
    os.chdir(home_dir)
    c.run('terraform plan -out=tf.plan')
    
@task(pre=[plan])
def setup(c):
    os.chdir(home_dir)
    c.run('terraform apply tf.plan')

@task
def destroy(c):
    os.chdir(home_dir)
    read_azdevops_environment()
    c.run('terraform destroy -auto-approve')