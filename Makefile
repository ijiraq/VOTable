#++++++++++++++++
#.IDENTIFICATION Makefile
#.LANGUAGE       Make (makefile script)
#.AUTHOR         Francois Ochsenbein [CDS]
#.ENVIRONMENT    Unix
#.KEYWORDS       
#.VERSION  1.0   07-Jun-2004
#.PURPOSE        (Re)Create dependent files in this Directory
#.COMMENTS       All details for VOTable-1.2 can be downloaded from
#		ftp://cdsarc.u-strasbg.fr/sw/votable-export.tar.gz
#		ftp://cdsarc.u-strasbg.fr/sw/cgiprint.tar.gz
#----------------

SHELL=/bin/sh
#MACHINE=local

# Defaut rule (e.g. copy from a public directory)
.DEFAULT:

# Programs:
CC      = cc
COPY    = cp -p
STRIP   = strip
RANLIB  = ranlib
AR      = ar ruv

# Definitions:
DEBUG =
C_OPT = -O
SYS =
CFLAGS = $(C_OPT) $(DEBUG) $(SYS) -I. -I$(INCDIR)
COMPILE= $(CC) $(CFLAGS) -c
CGIPRINT = cgiprint/bin/cgiprint
XDOC_CLASSPATH = figicon/xdoc.jar:figicon/epsgraphics.jar:figicon/Text_shrunk.jar
BINFIGURE = java -classpath $(XDOC_CLASSPATH):. BinFigure

# Files
IMGs = circ2.gif leadsto2.gif oplus.gif serial.png binary.png binary2.png
XSD  = VOTable.xsd

default: votable.pdf votable.html

votable.pdf: votable.tex VOTable.attr.tex  VOTable.elem.tex \
             serial.png binary.pdf binary2.pdf \
             VOTable.xsd stc_example1.vot stc_example2.vot
	pdflatex votable && \
	pdflatex votable && \
	pdflatex votable

votable.html: votable.tex votable.htx $(CGIPRINT) binary.png binary2.png \
              VOTable.xsd stc_example1.vot stc_example2.vot
	$(CGIPRINT) votable.htx > votable.html

votable.tar: votable.html votable.htx votable.pdf $(IMGs) $(XSD)
	tar cvf $@ votable.html votable.pdf $(IMGs) $(XSD)

cgiprint/bin/cgiprint:
	cd cgiprint && \
        ./configure --prefix=`pwd` && \
        make && \
        make install

BinFigure.class: BinFigure.java
	javac -classpath $(XDOC_CLASSPATH) BinFigure.java

binary.png: BinFigure.class
	$(BINFIGURE) -png BINARY >$@

binary.pdf: BinFigure.class
	$(BINFIGURE) -pdf BINARY >$@

binary2.png: BinFigure.class
	$(BINFIGURE) -png BINARY2 >$@

binary2.pdf: BinFigure.class
	$(BINFIGURE) -pdf BINARY2 >$@

# Make export tar
export:	CLEAN
	h=`pwd`;d=`basename $$h`; tar cvf /tmp/$$d.tar -C .. $$d; \
	gzip -v9 /tmp/$$d.tar

# Remove useless files:
clean: 
	rm -f votable.log votable.aux votable.out votable.toc
	rm -f BinFigure.class binary.pdf binary2.pdf
	rm -f votable.tar
	cd cgiprint && rm -f cgiprint cgigraph cgiparm
	cd cgiprint && rm -rf include lib bin
	cd cgiprint && rm -f config.log config.status Makefile
	cd cgiprint && rm -f cgiprint.lis versions

# Remove depedent files:
CLEAN: clean
	rm -f votable.pdf votable.html
	rm -f binary.png binary2.png
