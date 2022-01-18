
from invoke import task
import pathlib


current_file_dir = pathlib.Path(__file__).parent.absolute()
dev_image = "devops_setup:latest"
dev_container = "devops_setup"


@task
def setup(c):
    c.run(f"docker build {current_file_dir}/../.devcontainer -t {dev_image}")


@task(pre=setup)
def run(c, image=dev_image):
    c.run(
        f'nohup docker run --rm -v {current_file_dir}/..:/dev --name devops_setup -t {image}')


@task
def clean(c, image="iot-edge-image"):
    c.run(f'docker stop {dev_container}')
    c.run(f'docker rmi {image}')
