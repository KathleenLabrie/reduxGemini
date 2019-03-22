procedure statsci (inimages)

char	inimages	{prompt="Images to inspect"}
char    extension   {"SCI", prompt="Extension to measure"}
char    section     {"", prompt="Section for statistics"}
struct	*scanfile	{"", prompt="Internal use"}

begin
	char    l_inimages = ""
    char    l_extension = ""
    char    l_section = ""
    
	char    image, tmpin
    int     junk
	
    junk = fscan (inimages, l_inimages)
    junk = fscan (extension, l_extension)
    junk = fscan (section, l_section)
	
	tmpin = mktemp ("tmpin")
	gemextn (l_inimages, check="", proc="none", outfile=tmpin)
	
	scanfile = tmpin
	printf ("IMAGE                  MEAN      MIDPT     STDDEV    \
	    MIN    MAX\n")
	while (fscan(scanfile, image) != EOF) {
	    imstatistic (image//"["//l_extension//"]"//l_section,
	        fields="image,mean,midpt,stddev,min,max", format-)
	}
	scanfile=""

	delete (tmpin, verify-, >& "dev$null")
end
