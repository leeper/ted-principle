all: ted.html ted.md

ted.md: ted.Rmd
	Rscript -e "rmarkdown::render('ted.Rmd', rmarkdown::md_document())"

ted.html: ted.Rmd
	Rscript -e "rmarkdown::render('ted.Rmd', rmarkdown::html_document())"

ted.pdf: ted.Rmd
	Rscript -e "rmarkdown::render('ted.Rmd', rmarkdown::pdf_document())"
