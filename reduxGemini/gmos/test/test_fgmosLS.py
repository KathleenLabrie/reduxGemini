# pytest suite

"""
Tests for the fgmosLS software.

This is a suite of tests to be run with pytest.

To run:
    1) Set environment variable REDUXGEMINI_TESTDATA appropriately.
        (That should be were the content reduxGemini_testdata.tar.gz
        was unpacked.)
    2) From the fgmosLS.py location: py.test -v
"""

import os
from reduxGemini.gmos import fgmosLS

TESTDATAPATH = os.getenv('REDUXGEMINI_TESTDATA', '.')

class TestFgmosLS:
    """
    Suite of tests for the functions in the fgmosLS module.
    """
    @classmethod
    def setup_class(cls):
        """Run once at the beginning."""
        pass
    
    @classmethod
    def teardown_class(cls):
        """Run once at the end."""
        pass
    
    def setup_method(self, method):
        """Run once before every test."""
        pass
    
    def teardown_method(self, method):
        """Run once after every test."""
        pass
    
#------------------------------


    