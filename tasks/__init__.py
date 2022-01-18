
# !/usr/bin/env python

from invoke import Collection

from tasks import azdevops


ns = Collection.from_module(azdevops)
