# .SUFFIXES: .tex .pdf
# .PHONY: all clean distclean FORCE

export SHELL := /bin/bash

all: main

main:
	lhs2TeX --verb pmcheck.lhs >pmcheck.tex
	pdflatex pmcheck
	bibtex   pmcheck
	pdflatex pmcheck
	pdflatex pmcheck

extended:
	lhs2TeX --verb pmcheck_ext.lhs >pmcheck_ext.tex
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


