.PHONY: clean default

default: update_xs_yum.native

clean:	
	rm -rf *.native *~ 449* _build *.iso *.cmx *.o

update_xs_yum.native: src/update_xs_yum.ml
	ocamlbuild -use-ocamlfind src/update_xs_yum.native

