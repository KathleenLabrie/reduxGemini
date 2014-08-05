# fgmosLS.py module

"""

See Also
--------
The command-line app 'fgmosLS' is the shell wrapper for fgmosLS()
"""

import re
import os.path

from astropy.io import fits

from pyraf import iraf

import reduxGemini
VERSION = reduxGemini.__version__
GEMINIVERSION = iraf.gemini.version + iraf.gemini.verno

# match .fits extension
matchfits = re.compile(r'(\.fits)$')

# Default for interactive flags
inter_flags = {'extract': False,
              'skysub': False,
              'wavecal': True}
ALLOWED_INTERPROC = sorted(inter_flags.keys())


def fgmosLS(input_fnames, rawdir, inter_flags=inter_flags, nsrc=1,
            linelist=None, logfile='fgmosLS.log', verbose=False):
    
    # Load GMOS package from Gemini IRAF
    iraf.gemini()
    iraf.gmos()
    
    # Make a processed flatfield
    if matchfits.search(input_fnames['flatfile']) == None:
        procflatfile = input_fnames['flatfile'] + '_flat.fits'
    else:
        procflatfile = re.sub(r'\.fits$', '_flat.fits', \
                              input_fnames['flatfile'])
    
    
    return

def tagversion(fname):
    """
    Tag the header of the outfiles with version numbers for this software
    and for the Gemini IRAF package that was used.
    
    The file will have HISTORY keywords added to the PHU.
    
    Note that since IRAF keeps nothing in memory and writes the output
    to disk, we need to pass the filename here, open the files and 
    write it back to disk.
    
    Parameters
    ----------
    fname: str
        Name of the FITS file to tag.
    
    Returns
    -------
    Nothing.  The file is written back to disk.
    
    Raises
    ------
    See Also
    --------
    Examples
    --------
    """
    if matchfits.search(fname) == None:
        fname = fname + '.fits'
    hdulist = fits.open(fname, mode='update')
    hdulist[0].header.add_history('Processed with reduxGemini v' + VERSION)
    hdulist[0].header.add_history('Processed with Gemini IRAF ' + GEMINIVERSION)
    hdulist.flush()
    hdulist.close()


def check_inputs(scifiles, biasfile, flatfile, arcfile, 
                 rawdir, linelist, verbose=True):
    """
    Check that the input files and directory do exist.
    It is recommended to run check_inputs() before calling fgmosLS.
    
    Parameters
    ----------
    scifiles: list of str
    biasfile: str
    flatfile: str
    arcfile: str
    rawdir: str
    linelist: str
    
    Returns
    -------
    Boolean.  True if everything checks out, False otherwise.
    """
    
    # Check that rawdir exists
    if not os.path.isdir(rawdir):
        error_message = 'Directory \'' + rawdir + '\' does not exist.'
        if verbose:
            print error_message
        return False
    
    # Add path and .fits to science files
    scifullfnames = []
    for fname in scifiles:
        if matchfits.search(fname) == None:
            fname = fname + '.fits'
        scifullfnames.append(os.path.join(rawdir, fname))
    
    # Add path and .fits to the other raw FITS files
    if matchfits.search(flatfile) == None:
        flatfullfname = flatfile + '.fits'
    flatfullfname = os.path.join(rawdir, flatfullfname)

    if matchfits.search(arcfile) == None:
        arcfullfname = arcfile + '.fits'
    arcfullfname = os.path.join(rawdir, arcfullfname)
    
    # Add the .fits to the processed bias (it should already have
    # its path defined.
    if matchfits.search(biasfile) == None:
        biasfullfname = biasfile + '.fits'
    
    # Check that necessary files exists
    files_to_check = []
    files_to_check.extend(scifullfnames)
    files_to_check.extend([biasfullfname, flatfullfname, arcfullfname])
    if linelist is not None:
        files_to_check.append = linelist
    
    error_message = ''
    for afile in files_to_check:
        if not os.path.isfile(afile):
            error_message += '\nERROR: File \'' + afile + '\' does not exist.'
    if error_message:
        if verbose:
            print error_message
        return False
    
    return True
