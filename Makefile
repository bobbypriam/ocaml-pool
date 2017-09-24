all:
				jbuilder build @install

test:
				jbuilder runtest

clean:
				jbuilder clean

.PHONY: all test clean
