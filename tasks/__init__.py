
# !/usr/bin/env python

from invoke import Collection

from tasks import azdevops, docker


ns = Collection.from_module(azdevops)
ns.add_collection(Collection.from_module(docker, name="docker"))