Install module
==============
Make sure that your installation location is in the PYTHONPATH before you 
install.  It is a setuptools requirement. ::

	python setup.py install --prefix=<somewhere>

with <somewhere>/lib/python2.7/site-packages in the PYTHONPATH.  (Of course,
change the 'python2.7' to match your Python version.)


Build documentation
===================
The latest documentation is available at ::
 
	http://reduxgemini.readthedocs.org/en/latest/

If you need to build documentation, eg. need a local copy, ::

	python setup.py build_sphinx

will build the html documentation in ::

	docs/reduxGemini_Manual/_build/html

Point your browser to ::

	docs/reduxGemini_Manual/_build/html/index.html

If you are interested in a PDF version: ::

	cd docs/reduxGemini_Manual
	make latexpdf

The PDF is ::

	docs/reduxGemini_Manual/_build/latexpdf/reduxGemini_Manual.pdf



Cookbooks and Templates
=======================

Cookbooks are written as IPython notebooks.  Template notebooks are also
available that one can copy over and start using for their own reduction.

The cookbooks show and discuss the data reduction process for a certain
type of data.  Like the package, the cookbooks can be dependent on IRAF
and PyRAF.

To read the cookbooks: ::

	cd doc/cookbooks
	ipython notebook

and navigate to the desired notebook.

The templates are located in: ::

	doc/templates/


Installing the documentation somewhere convenient
=================================================

The documentation is included in the egg, but it is not
really accessible.  The documentation is also in the source code
but you will probably want to delete that once you've installed
the module.

To extract the documentation and copy it somewhere useful, ::

   (from source code):
      reduxGemini/getdocs.py /your/preferred/path
   (from installed egg):
      <where_egg_is_located>/reduxGemini-0.1.0dev1-py2.7.egg/reduxGemini/getdocs.py

will copy the documentation to /your/preferred/path/reduxGemini.




