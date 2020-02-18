#
# RModule
# Imports Module Source via HTTP/FTP
#
# Ashen Gunaratne
# mail@ashenm.ml
#

from http.client import HTTPException
from importlib.util import spec_from_loader
from os.path import basename
from urllib.error import URLError
from urllib.request import urlopen

def rmodule(url):

  module = spec_from_loader(
      basename(url).lower().rstrip('.py'), loader=None, origin=url)

  try:
    response = urlopen(url).read()
    source = compile(response, filename=url, mode='exec')
  except (URLError, HTTPException):
    raise ImportError(url)

  exec(source, vars(module))

  return module

# vim: set expandtab shiftwidth=2 syntax=python:
