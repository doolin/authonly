auth:
	xelatex auth

clean:
	rm -rf *.log *.aux *.dvi *.out

spotless: clean
	rm -rf *.pdf
