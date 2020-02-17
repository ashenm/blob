#!/usr/bin/env python3
#
# Build Index
# Builds directory listing index
#
# Ashen Gunaratne
# mail@ashenm.ml
#

from datetime import datetime, timezone
from digest import digest
from hashlib import md5, sha256
from importlib.util import module_from_spec, spec_from_file_location
from os import stat
from os.path import join
from subprocess import PIPE, CalledProcessError, run
from xml.etree.ElementTree import Element, SubElement, tostring

EXCLUDES = [ 'index.xml', 'status.xml' ]

def stats(filename):

  _ = stat(filename)

  try:
    proc = run([ 'git', 'log', '--max-count=1', '--pretty=format:%ct', filename ], stdout=PIPE, check=True)
    mtime = int(proc.stdout.decode())
  except (CalledProcessError, ValueError):
    mtime = _.st_mtime

  return (filename, {
    'st_mtime': mtime,
    'st_size': _.st_size
  })

def index(collections):

  blobs = Element('Blobs')

  for collection in collections:

    filename, stats = collection

    blob = SubElement(blobs, 'Blob', {
      'md5': digest(filename, function=md5),
      'sha256': digest(filename, function=sha256)
    })

    key = SubElement(blob, 'Key')
    lastmod = SubElement(blob, 'LastModified')
    size = SubElement(blob, 'Size')

    key.text = filename
    lastmod.text = datetime.fromtimestamp(stats['st_mtime'], tz=timezone.utc).isoformat()
    size.text = str(stats['st_size'])

  return tostring(blobs, 'utf-8')

if __name__ == '__main__':

  from glob import iglob
  from xml.dom.minidom import parseString

  refs = map(stats, filter(lambda f: f not in EXCLUDES, iglob('*???.???*')))

  with open('index.xml', mode='wb') as stream:
    stream.write(parseString(index(refs)).toprettyxml(indent='  ', newl='\r\n', encoding='UTF-8'))

# vim: set expandtab shiftwidth=2 syntax=python:
