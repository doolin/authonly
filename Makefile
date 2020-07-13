auth:
	xelatex auth

test:
	# ./src/rails_basic_auth_test.sh
	./src/rack_jwt_test.sh

clean:
	rm -rf *.log *.aux *.dvi *.out

spotless: clean
	rm -rf *.pdf
