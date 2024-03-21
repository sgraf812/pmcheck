# .SUFFIXES: .tex .pdf
# .PHONY: all clean distclean FORCE

all: lyg.pdf

# -halt-on-error: Halts on first error, rather than prompting the user
REPL_FLAGS := -halt-on-error

.PHONY: main

# The main paper without appendix
lyg.pdf: lyg.lhs custom.fmt macros.tex
	lhs2TeX --poly lyg.lhs >lyg.tex
	pdflatex $(REPL_FLAGS) -draftmode lyg
	bibtex   lyg
	pdflatex $(REPL_FLAGS) -draftmode lyg
	pdflatex $(REPL_FLAGS) lyg

# Fast, possibly incomplete rebuild. Mostly sufficient for quick rebuilds
fast: lyg.lhs custom.fmt macros.tex
	lhs2TeX --poly lyg.lhs >lyg.tex
	pdflatex $(REPL_FLAGS) lyg

# For camera-ready submission
zipball: main appendix
	git archive --format zip --output lyg.zip HEAD
	zip -ur lyg.zip lyg.tex
	zip -ur appendix.zip appendix.pdf

clean:
	$(RM) *.dvi *.aux *.log *.bbl *.blg *.toc *.out *.fls *.haux *.fdb_latexmk *~ lyg.zip

distclean: clean
	$(RM) appendix.tex
	$(RM) lyg.tex
	$(RM) lyg.pdf
	$(RM) lyg_ext.tex
	$(RM) lyg_ext.pdf

.PHONY: artifact-tarball
artifact-tarball:
	GZIP=-n tar --owner=0 --group=0 --numeric-owner --clamp-mtime --mtime=2020-05-11 --sort=name -czvf artifact05-source.tgz artifact
	@MD5=$$(md5sum artifact05-source.tgz | cut -d' ' -f 1); \
	mv artifact05-source.tgz artifact05-source-$$MD5.tgz
