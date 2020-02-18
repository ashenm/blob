#
# RModule
# Imports Module Source via HTTP/FTP
#
# Ashen Gunaratne
# mail@ashenm.ml
#

from http.client import HTTPException
from imp import new_module
from os.path import basename
from urllib.error import URLError
from urllib.request import urlopen

def rmodule(url):

  module = new_module(basename(url).lower().rstrip('.py'))

  try:
    response = urlopen(url).read()
    source = compile(response, filename=url, mode='exec')
  except (URLError, HTTPException):
    raise ImportError(url)

  exec(source, vars(module))

  return module

# vim: set expandtab shiftwidth=2 syntax=python:
