#!/usr/bin/env python3
#
# Digest Files
# Computes checksums for directory files
#
# Ashen Gunaratne
# mail@ashenm.dev
#

from hashlib import md5, sha256
from itertools import product
from os.path import splitext

def digest(filename, function=sha256):

  with open(filename, 'br') as stream:
    digest = function(stream.read()).hexdigest()

  return digest

def stash(filename, digest=sha256, ext='sha256'):

  with open(f'{filename}.{ext}', mode='wt', newline='\r\n') as stream:
    stream.write(f'{digest}\r\n')

  return filename

if __name__ == '__main__':

  from re import sub
  from sys import argv

  for stream, algorithm in product(argv[1:], [ sha256, md5 ]):
    stash(stream, digest(stream, algorithm), sub(r'^.*_', '', algorithm.__name__))

# vim: set expandtab shiftwidth=2 syntax=python:
