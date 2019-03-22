procedure inspect (inimages)

char	inimages	{prompt="Images to inspect"}
char    extension   {"SCI", prompt="Extension to display"}
char    logfile     {"", prompt="Imexam logfile"}
struct	*scanfile	{"", prompt="Internal use"}

begin
	char    l_inimages = ""
    char    l_extension = ""
    char    l_logfile = ""
    
	char    image, tmpin
    int     junk
	
    junk = fscan (inimages, l_inimages)
    junk = fscan (extension, l_extension)
    junk = fscan (logfile, l_logfile)
		
	tmpin = mktemp ("tmpin")
	gemextn (l_inimages, check="", proc="none", outfile=tmpin)
	
	scanfile = tmpin
	while (fscan(scanfile,image) != EOF) {
	    printf ("%s : ", image)
	    imexa (image//"["//l_extension//"]", logfile=l_logfile)
	}
	scanfile=""

	delete (tmpin, verify-, >& "dev$null")
end
