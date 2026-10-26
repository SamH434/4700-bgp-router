.PHONY: run clean test

run:
	python3 4700router $(ARGS)

test:
	./run configs/1-1.conf

clean:
	rm -f *.pyc __pycache__ *.o