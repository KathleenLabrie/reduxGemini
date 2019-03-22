procedure dirtyIFU (inimages)

# Quick and dirty reduction of IFU data
#   Purpose: verify seeing, verify centering, verify signal
#            i.e. morning after sanity checks

char    inimages    {prompt="List of raw input science frame"}
char    gcalflats   {"", prompt="List of raw GCALflats"}
char    rawpath     {"/net/archie/staging/perm/", prompt="Location of raw data"}
char    flat        {"", prompt="Already reduced flat"}
char    dispscript  {"dispscript.cl", prompt="Script to display reduced output"}
char    slits       {"both", prompt="Slit(s) used"}
char    logfile     {"dirtyIFU.log", prompt="Name of logfile"}
bool    verbose     {yes, prompt="Verbose"}
int     status      {0, prompt="Exit status"}
struct  *scanfile   {"", prompt="Internal use only"}

begin
    char    l_inimages = ""
    char    l_gcalflats = ""
    char    l_rawpath = ""
    char    l_flat = ""
    char    l_dispscript = ""
    char    l_slits = ""
    char    l_logfile = ""
    bool    l_verbose
    
    char    paramstr, lastchar, errmsg
    char    filename, flatused
    char    tmpinimg, tmpinflat
    int     junk
    bool    reduxflat, doscript
    
    cache ("gloginit")
    
    status = 0
    
    junk = fscan (inimages, l_inimages)
    junk = fscan (gcalflats, l_gcalflats)
    junk = fscan (rawpath, l_rawpath)
    junk = fscan (flat, l_flat)
    junk = fscan (dispscript, l_dispscript)
    junk = fscan (slits, l_slits)
    junk = fscan (logfile, l_logfile)
    l_verbose = verbose
    
    # Make temporary file names
    tmpinimg = mktemp ("tmpinimg")
    tmpinflat = mktemp ("tmpinflat")
        
    # Create the list of parameter/value pairs.  One pair per line.
    # All lines combined into one string.  Line delimiter is '\n'.
    paramstr =  "inimages       = "//inimages.p_value//"\n"
    paramstr += "gcalflats      = "//gcalflats.p_value//"\n"
    paramstr += "rawpath        = "//rawpath.p_value//"\n"
    paramstr += "flat           = "//flat.p_value//"\n"
    paramstr += "dispscript     = "//dispscript.p_value//"\n"
    paramstr += "slits          = "//slits.p_value//"\n"
    paramstr += "logfile        = "//logfile.p_value//"\n"
    paramstr += "verbose        = "//verbose.p_value
    
    # Assign a logfile name if not given.  Open logfile and start log.
    # Write parameter/value pairs ("paramstr") to log.
    gloginit (l_logfile, "dirtyIFU", "gmos", paramstr, fl_append+,
        verbose=l_verbose)
    if (gloginit.status != 0) {
        status = gloginit.status
        goto exitnow
    }
    l_logfile = gloginit.logfile.p_value
    
    # Check dispscript
    if (l_dispscript == "") doscript = no
    else                    doscript = yes
    
    if (doscript && (yes == access(l_dispscript))) {
        errmsg = "A display script named "//l_dispscript//" already exists."
        status = 102
        glogprint (l_logfile, "dirtyIFU", "status", type="error", errno=status,
            str=errmsg, verbose+)
        goto clean
    }
    
    ## Ensure rawpath is correct
    lastchar = substr (l_rawpath, strlen (l_rawpath), strlen (l_rawpath))
    if ((l_rawpath != "") && (lastchar != "$") && (lastchar != "/"))
        l_rawpath = l_rawpath//"/"
    
    # Check inputs
    gemextn (l_inimages, check="exists,mef", process="none", index="",
        extname="", extversion="", ikparams="", omit="kernel,exten",
        replace="^%%"//l_rawpath//"%", outfile="dev$null", logfile=l_logfile,
        verbose=l_verbose)
    
    if (gemextn.fail_count > 0) {
        errmsg = gemextn.fail_count//" input science frames were not found."
        status = 101
    } else if (gemextn.count == 0) {
        errmsg = "No valid input science frames defined!"
        status = 121
    }

    if (status != 0) {
        glogprint (l_logfile, "dirtyIFU", "status", type="error", errno=status,
            str=errmsg, verbose+)
        goto clean
    } else {
        gemextn (l_inimages, check="", process="none", index="", extname="",
            extversion="", ikparams="", omit="exten", replace="",
            outfile=tmpinimg, logfile=l_logfile, verbose=l_verbose)
    }
    
    if (l_gcalflats == "") {
        reduxflat = no
    } else {
        reduxflat = yes
        
        gemextn (l_gcalflats, check="exists,mef", process="none", index="",
            extname="", extversion="", ikparams="", omit="kernel,exten",
            replace="^%%"//l_rawpath//"%", outfile="dev$null", 
            logfile=l_logfile, verbose=l_verbose)

        if (gemextn.fail_count > 0) {
            errmsg = gemextn.fail_count//" input GCAL flats were not found."
            status = 101
        } else if (gemextn.count == 0) {
            errmsg = "No input science frames defined!"
            status = 121

        }
        
        if (status != 0) {
            glogprint (l_logfile, "dirtyIFU", "status", type="error", 
                errno=status, str=errmsg, verbose+)
            goto clean
        } else {
            gemextn (l_gcalflats, check="", process="none", index="", 
                extname="", extversion="", ikparams="", omit="", replace="", 
                outfile=tmpinflat, logfile=l_logfile, verbose=l_verbose)
        }
    }
    
    if (reduxflat) {
        gfreduce (l_gcalflats, outimag="", outpref="default", slits=l_slits,
            fl_nodsh=no, fl_inter=no, fl_vardq=no, fl_addmdf=yes, fl_over=no,
            fl_trim=yes, fl_bias=no, fl_gscrrej=no, fl_gnsskysub=no,
            fl_extract=yes, fl_gsappwave=yes, fl_wavtran=no, fl_skysub=no,
            fl_fluxcal=no, rawpath=l_rawpath, key_mdf="", mdffile="default",
            mdfdir="gmos$data/", key_biassec="BIASSEC", key_datasec="DATASEC",
            bpmfile="gmos$data/chipgaps.dat", bias="", reference="",
            response="", wavtraname="", sfunction="", extinction="",
            fl_fixnc=no, fl_novlap=yes, perovlap=10., order=1, line=INDEF,
            nsum=10, trace=yes, recenter=yes, thresh=200.,
            function="chebyshev", t_order=5, t_nsum=10, weights="variance",
            gratingdb="gmos$data/GMOSgratings.dat",
            filterdb="gmos$data/GMOSfilters.dat", xoffset=INDEF,
            expr="default", observatory="default", sci_ext="SCI", var_ext="VAR",
            dq_ext="DQ", logfile=l_logfile, verbose=l_verbose)
        if (doscript) {
            scanfile = tmpinflat
            while (fscan (scanfile, filename) != EOF) {
                printf ("gfdisplay erg%s ver=1 \
                    config=gmos$data/gnifu_slitr.cfg \
                    deadfib=gmos$data/gnifu_deadr.cfg\n\n", filename,
                    >> l_dispscript)
            }
            scanfile = ""
        }
        scanfile = tmpinflat
        junk = fscan (scanfile, filename)
        scanfile = ""
        flatused = "erg"//filename
    } else {
        flatused = l_flat
    }
    
    gfreduce (l_inimages, outimag="", outpref="default", slits=l_slits,
        fl_nodsh=no, fl_inter=no, fl_vardq=no, fl_addmdf=yes, fl_over=no,
        fl_trim=yes, fl_bias=no, fl_gscrrej=yes, fl_gnsskysub=no,
        fl_extract=yes, fl_gsappwave=no, fl_wavtran=no, fl_skysub=yes,
        fl_fluxcal=no, rawpath=l_rawpath, key_mdf="", mdffile="default",
        mdfdir="gmos$data/", key_biassec="BIASSEC", key_datasec="DATASEC",
        bpmfile="gmos$data/chipgaps.dat", bias="", reference=flatused, 
        wavtraname="", sfunction="", extinction="", fl_fixnc=no, fl_novlap=yes,
        perovlap=10., order=1, line=INDEF, nsum=10, trace=no, recenter=yes,
        thresh=200., function="chebyshev", t_order=5, t_nsum=10,
        weights="variance", gratingdb="gmos$data/GMOSgratings.dat",
        filterdb="gmos$data/GMOSfilters.dat", xoffset=INDEF, expr="default",
        observatory="default", sci_ext="SCI", var_ext="VAR", dq_ext="DQ",
        logfile=l_logfile, verbose=l_verbose)
    
    scanfile = tmpinimg
    while (fscan (scanfile, filename) !=  EOF) {
        gfcube ("sexrg"//filename, outimage="sexrg"//filename//"_3D", 
            outpref="", ssample=0.1)
        if (doscript) {
            printf ("gfdisplay sexrg%s out=sexrg%s_2D ver=1 \
                config=gmos$data/gnifu_slitr.cfg \
                deadfib=gmos$data/gnifu_deadr.cfg\n\n", filename, filename,
                >> l_dispscript)
        }
    }
    scanfile = ""
    

clean:
    scanfile = ""
    delete (tmpinimg, ver-, >& "dev$null")
    delete (tmpinflat, ver-, >& "dev$null")
    
    if (status == 0)
        glogclose (l_logfile, "dirtyIFU", fl_success+, verbose=l_verbose)
    else
        glogclose (l_logfile, "dirtyIFU", fl_success-, verbose=l_verbose)

exitnow:
    ;    

end
