# Variables
COQ_MAKEFILE ?= coq_makefile
COQC         ?= coqc
DKCHECK      ?= dkcheck
DKDEP        ?= dkdep
VERBOSE      ?=

BUILD_FOLDER = _build
OUTFOLDER    = $(BUILD_FOLDER)/out
PRUNEDFOLDER = $(BUILD_FOLDER)/pruned

COQINEPATH=coqine

DKS = $(wildcard $(PRUNEDFOLDER)/*.dk)
DKOS = $(DKS:.dk=.dko)


.PHONY: all coqine compile generate depend clean fullclean

all: coqine compile generate depend

coqine:
	make -C coqine

# Compile the local [.v] files that are not part of the stdlib
compile: CoqMakefile
	make -f CoqMakefile

# Generate the [.dk] files by executing [main.v]
generate: compile $(OUTFOLDER) $(PRUNEDFOLDER) $(BUILD_FOLDER)
	$(COQC) -init-file .coqrc -w all -R . Top main.v

$(BUILD_FOLDER)/config.dk: $(BUILD_FOLDER) generate $(OUTFOLDER)
	ls $(OUTFOLDER)/*GeoCoq*.dk | sed -e "s:out/Top__:#REQUIRE Top__:g" | sed -e "s/.dk/./g" > $(BUILD_FOLDER)/config.dk

prune: generate $(PRUNEDFOLDER) $(OUTFOLDER) $(BUILD_FOLDER)/config.dk
	dkprune -l -I $(OUTFOLDER) -o $(PRUNEDFOLDER) $(BUILD_FOLDER)/config.dk
	rm -f $(PRUNEDFOLDER)/C.dk

CoqMakefile: Make
	$(COQ_MAKEFILE) -f Make -o CoqMakefile

$(BUILD_FOLDER)/C.dk: $(BUILD_FOLDER)
	make -C coqine/encodings _build/predicates/C.dk
	cp encodings/_build/predicates/C.dk $(BUILD_FOLDER)

config.v:
	make -C coqine/encodings _build/predicates/C.config
	cp encodings/_build/predicates/C.config config.v
	echo "Dedukti Set Encoding \"template\"." >> config.v

# Generate the dependencies of [.dk] files
depend: $(PRUNEDFOLDER) $(BUILD_FOLDER) prune
	$(DKDEP) -I $(PRUNEDFOLDER) -I $(BUILD_FOLDER) $(PRUNEDFOLDER)/*.dk > .depend

# Check and compile the generated [.dk]
check: $(DKOS)

%.dko: %.dk $(PRUNEDFOLDER) $(BUILD_FOLDER) prune depend
	$(DKCHECK) -I $(PRUNEDFOLDER) -I $(BUILD_FOLDER) --eta -e $<

$(OUTFOLDER): $(BUILD_FOLDER)
	mkdir $(OUTFOLDER)

$(PRUNEDFOLDER): $(BUILD_FOLDER)
	mkdir $(PRUNEDFOLDER)

$(BUILD_FOLDER):
	mkdir $(BUILD_FOLDER)

clean: CoqMakefile
	make -C coqine/encodings clean
	make -C coqine - clean
	make -f CoqMakefile - clean
	rm -f $(OUTFOLDER) $(PRUNEDFOLDER) $(BUILD_FOLDER)
	rm -f *.dk
	rm -f *.dko
	rm -f config.v
	rm -f *.vo
	rm -f .depend
	rm -f CoqMakefile
	rm -f *.conf
	rm -f *.glob

fullclean: clean
	make -C coqine - fullclean

-include .depend
