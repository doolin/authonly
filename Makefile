auth:
	xelatex auth

test:
	./src/test.sh

clean:
	rm -rf *.log *.aux *.dvi *.out

spotless: clean
	rm -rf *.pdf
