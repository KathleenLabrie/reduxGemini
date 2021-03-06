from setuptools import setup, find_packages
from codecs import open
import os

import reduxGemini
VERSION = reduxGemini.__version__

cwd = os.path.abspath(os.path.dirname(__file__))

# Get the long_description from the Description.rst file
with open(os.path.join(cwd, 'DESCRIPTION.rst'), encoding='utf-8') as f:
    long_description = f.read()

MODULENAME = 'reduxGemini'

DATA_FILES = []
DOC_FILES = [(os.path.join('share',MODULENAME,root), [os.path.join(root,f) for f in files]) \
              for root, dirs, files in os.walk('docs')]
DATA_FILES.extend(DOC_FILES)

setup(
      name = 'reduxGemini',
      version = VERSION,
      
      description = 'Tools and documentation to reduce Gemini data',
      long_description = long_description,
      
      url = 'https://github.com/KathleenLabrie/reduxGemini',
      
      author = 'Kathleen Labrie',
      author_email = 'kathleen.labrie.phd@gmail.com',
      
      license = 'LICENSE',
      
      # See https://pypi.python.org/pypi?%3Aaction=list_classifiers
      classifiers = [
                    'Development Status :: 2 - Pre-Alpha',
                    'Intended Audience :: Science/Research',
                    'License :: OSI Approved :: ISC License (ISCL)',
                    'Operating System :: Mac OS :: MacOS X',
                    'Operating System :: POSIX :: Linux',
                    'Programming Language :: Python :: 2.7',
                    'Topic :: Scientific/Engineering :: Astronomy'
                    ],
      
      keywords = 'Gemini data reduction',
      
      packages = find_packages(exclude=['docs']),
      
      #install_requires = ['']
      #extras_require = {
      #  'dev': [''],
      #},
      
      #package_data = {
      #                 'reduxGemini': [''],
      #                },
      
      data_files = DATA_FILES,
      
      scripts = [
                 'reduxGemini/gmos/scripts/fgmosLS'
                 ],
      zip_safe = False,
      )
