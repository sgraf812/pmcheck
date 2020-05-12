# .SUFFIXES: .tex .pdf
# .PHONY: all clean distclean FORCE

all: main

# -halt-on-error: Halts on first error, rather than prompting the user
REPL_FLAGS = -halt-on-error

main:
	lhs2TeX --poly appendix.lhs >appendix.tex
	lhs2TeX --poly lyg.lhs >lyg.tex
	pdflatex $(REPL_FLAGS) lyg
	bibtex   lyg
	pdflatex $(REPL_FLAGS) lyg
	pdflatex $(REPL_FLAGS) lyg

extended:
	lhs2TeX --poly appendix_ext.lhs >appendix_ext.tex
	lhs2TeX --poly lyg_ext.lhs >lyg_ext.tex
	pdflatex lyg_ext
	bibtex   lyg_ext
	pdflatex lyg_ext
	pdflatex lyg_ext

clean:
	$(RM) *.dvi *.aux *.log *.bbl *.blg *.toc *.out *.fls *.haux *.fdb_latexmk *~

distclean: clean
	$(RM) appendix.tex
	$(RM) lyg.tex
	$(RM) lyg.pdf
	$(RM) lyg_ext.tex
	$(RM) lyg_ext.pdf

.PHONY: artifact-tarball
artifact-tarball:
	GZIP=-n tar --owner=0 --group=0 --numeric-owner --clamp-mtime --mtime=2020-05-11 --sort=name -czvf artifact5-source.tgz artifact
	@MD5=$$(md5sum artifact5-source.tgz | cut -d' ' -f 1); \
	mv artifact5-source.tgz artifact5-source-$$MD5.tgz
