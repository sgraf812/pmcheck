# .SUFFIXES: .tex .pdf
# .PHONY: all clean distclean FORCE

all: main

# -halt-on-error: Halts on first error, rather than prompting the user
REPL_FLAGS = -halt-on-error

main:
	lhs2TeX --poly pmcheck.lhs >pmcheck.tex
	pdflatex $(REPL_FLAGS) pmcheck
	bibtex   pmcheck
	pdflatex $(REPL_FLAGS) pmcheck
	pdflatex $(REPL_FLAGS) pmcheck

extended:
	lhs2TeX --poly pmcheck_ext.lhs >pmcheck_ext.tex
	pdflatex pmcheck_ext
	bibtex   pmcheck_ext
	pdflatex pmcheck_ext
	pdflatex pmcheck_ext

clean:
	$(RM) *.dvi *.aux *.log *.bbl *.blg *.toc *.out *.fls *.haux *.fdb_latexmk *~

distclean: clean
	$(RM) pmcheck.tex
	$(RM) pmcheck.pdf
	$(RM) pmcheck_ext.tex
	$(RM) pmcheck_ext.pdf


