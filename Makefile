OCAMLC     = ocamlfind ocamlc
OCAMLDEP   = ocamlfind ocamldep
OCAMLFLAGS = -w Ae -I +../compiler-lib
PROGRAM    = cmidump
TOPLVL     = $(shell ocamlfind ocamlc -where)/toplevellib.cma
INSTALLDIR = $(DESTDIR)$(shell dirname $(shell which ocamlfind))

.PHONY: all clean install uninstall reinstall

all: $(PROGRAM)

cmidump: cmidump.cmo
	$(OCAMLC) -o $@ $(TOPLVL) $(OCAMLFLAGS) $^

install: $(PROGRAM)
	@echo "Installing $< in $(INSTALLDIR)"
	install $< $(INSTALLDIR)

uninstall:
	ocamlfind remove $(PROGRAM)

reinstall: uninstall install

# Common rules
.SUFFIXES: .ml .mli .cmo .cmi .cmx

.ml.cmo:
	$(OCAMLC) $(OCAMLFLAGS) -c $<

.mli.cmi:
	$(OCAMLC) $(OCAMLFLAGS) -c $<

# Clean up
clean:
	rm -f cmidump.cmi *.cmo *.s

# Dependencies
.depend: *.ml
	$(OCAMLDEP) *.ml > .depend

include .depend
