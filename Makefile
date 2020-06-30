# .SUFFIXES: .tex .pdf
# .PHONY: all clean distclean FORCE

all: main

# -halt-on-error: Halts on first error, rather than prompting the user
REPL_FLAGS := -halt-on-error

.PHONY: main

# The main paper without appendix
main: lyg.lhs macros.tex
	lhs2TeX --poly lyg.lhs >lyg.tex
	pdflatex $(REPL_FLAGS) lyg
	bibtex   lyg
	pdflatex $(REPL_FLAGS) lyg
	pdflatex $(REPL_FLAGS) lyg

# Fast, possibly incomplete rebuild. Mostly sufficient for quick rebuilds
main_fast: lyg.lhs macros.tex
	lhs2TeX --poly lyg.lhs >lyg.tex
	pdflatex $(REPL_FLAGS) lyg

# Just a standalone appendix.pdf
appendix: lyg.lhs macros.tex appendix.lhs
	lhs2TeX --poly appendix.lhs >appendix.tex
	lhs2TeX --poly lyg.lhs | sed -e 's/^%\\appendixonly/\\appendixonly/g' >lyg.tex
	pdflatex $(REPL_FLAGS) -jobname=appendix lyg
	bibtex   lyg
	pdflatex $(REPL_FLAGS) -jobname=appendix lyg
	pdflatex $(REPL_FLAGS) -jobname=appendix lyg

diff:
	pdflatex $(REPL_FLAGS) diff
	bibtex   diff
	pdflatex $(REPL_FLAGS) diff
	pdflatex $(REPL_FLAGS) diff

# Main paper including appendix
extended:
	lhs2TeX --poly appendix.lhs >appendix.tex
	lhs2TeX --poly lyg.lhs | sed -e 's/^%\\extended/\\extended/g' >lyg.tex
	pdflatex $(REPL_FLAGS) -jobname=lyg_ext lyg
	bibtex   lyg_ext
	pdflatex $(REPL_FLAGS) -jobname=lyg_ext lyg
	pdflatex $(REPL_FLAGS) -jobname=lyg_ext lyg

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
	GZIP=-n tar --owner=0 --group=0 --numeric-owner --clamp-mtime --mtime=2020-05-11 --sort=name -czvf artifact05-source.tgz artifact
	@MD5=$$(md5sum artifact05-source.tgz | cut -d' ' -f 1); \
	mv artifact05-source.tgz artifact05-source-$$MD5.tgz
