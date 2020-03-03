# .SUFFIXES: .tex .pdf
# .PHONY: all clean distclean FORCE

all: main

# -halt-on-error: Halts on first error, rather than prompting the user
REPL_FLAGS = -halt-on-error

main:
	lhs2TeX --poly lyg.lhs >lyg.tex
	pdflatex $(REPL_FLAGS) lyg
	bibtex   lyg
	pdflatex $(REPL_FLAGS) lyg
	pdflatex $(REPL_FLAGS) lyg

extended:
	lhs2TeX --poly lyg_ext.lhs >lyg_ext.tex
	pdflatex lyg_ext
	bibtex   lyg_ext
	pdflatex lyg_ext
	pdflatex lyg_ext

clean:
	$(RM) *.dvi *.aux *.log *.bbl *.blg *.toc *.out *.fls *.haux *.fdb_latexmk *~

distclean: clean
	$(RM) lyg.tex
	$(RM) lyg.pdf
	$(RM) lyg_ext.tex
	$(RM) lyg_ext.pdf


