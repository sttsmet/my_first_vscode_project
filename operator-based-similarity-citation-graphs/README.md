# Operator-Based Similarity in Citation Graphs

LaTeX article scaffold for the paper:

`Operator-Based Similarity in Citation Graphs: From Scientific Articles to Researchers`

## Structure

- `main.tex`: main LaTeX entry point
- `references.bib`: bibliography database
- `figures/`: place figures here

## Build

If `latexmk` is installed:

```powershell
latexmk -pdf main.tex
```

If you prefer `pdflatex` + `bibtex`:

```powershell
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex
```
