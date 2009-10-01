OCAMLC     = ocamlfind ocamlc
OCAMLDEP   = ocamlfind ocamldep
OCAMLFLAGS = -w Ae
PROGRAM    = cmidump
EXTCMI     = printtyp.cmi typemod.cmi config.cmi
TOPLVL     = $(shell ocamlfind ocamlc -where)/toplevellib.cma
INSTALLDIR = $(DESTDIR)$(shell dirname $(shell which ocamlfind))

.PHONY: all clean install uninstall reinstall

all: checkcmi $(PROGRAM)

cmidump: cmidump.cmo
	$(OCAMLC) -o $@ $(TOPLVL) $(OCAMLFLAGS) $^

checkcmi:
	@for i in $(EXTCMI) ; do if ! test -f $$i ; then echo "Ocamlc will fail if it cant access $$i" ; fi ; done

install: $(PROGRAM)
	@echo "Installing $< in $(INSTALLDIR)"
	install -o root -g root $< $(INSTALLDIR)

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
