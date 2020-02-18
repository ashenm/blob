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
from os import stat
from subprocess import PIPE, CalledProcessError, run
from xml.etree.ElementTree import Element, SubElement, tostring

EXCLUDES = [ 'index.html', 'index.xml', 'index.xsl', 'status.xml' ]

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

    blob = SubElement(blobs, 'Blob')

    key = SubElement(blob, 'Key')
    lastmod = SubElement(blob, 'LastModified')
    size = SubElement(blob, 'Size')
    hmd5 = SubElement(blob, 'Md5')
    hsha256 = SubElement(blob, 'Sha256')

    key.text = filename
    lastmod.text = datetime.fromtimestamp(stats['st_mtime'], tz=timezone.utc).isoformat()
    size.text = str(stats['st_size'])
    hmd5.text = digest(filename, function=md5)
    hsha256.text = digest(filename, function=sha256)

  return tostring(blobs, 'utf-8')

if __name__ == '__main__':

  from bs4 import BeautifulSoup
  from glob import iglob
  from lxml import etree
  from rmodule import rmodule
  from xml.dom.minidom import parseString

  reindent = rmodule('https://raw.githubusercontent.com/ashenm/xmlresume/master/scripts/reindent.py').reindent
  refs = map(stats, filter(lambda f: f not in EXCLUDES, iglob('*???.???*')))

  with open('index.xml', mode='wb') as stream:
    stream.write(parseString(index(refs)).toprettyxml(indent='  ', newl='\r\n', encoding='UTF-8'))

  xsl = etree.XSLT(etree.parse(source='index.xsl'))
  document = str(xsl(etree.parse(source='index.xml')))

  soup = BeautifulSoup(markup=document, features='lxml')

  soup.head.append(soup.new_tag('meta', attrs={ 'build-timestamp': datetime.utcnow().ctime() }))
  soup.head.append(soup.new_tag('meta', attrs={ 'build-commit':
    run([ 'git', 'rev-parse', 'HEAD' ], stdout=PIPE).stdout.decode().strip() }))

  document = soup.prettify(encoding=None, formatter='html')

  with open('index.html', 'wt') as stream:
    stream.write(reindent(document))

# vim: set expandtab shiftwidth=2 syntax=python:
