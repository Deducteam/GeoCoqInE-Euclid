# Variables
COQ_MAKEFILE ?= coq_makefile
COQC         ?= coqc
DKCHECK      ?= dkcheck
DKDEP        ?= dkdep
VERBOSE      ?=

BUILD_FOLDER = _build
OUTFOLDER    = $(BUILD_FOLDER)/out
PRUNEDFOLDER = $(BUILD_FOLDER)/pruned

ENCODING=predicates_eta

COQINEPATH=coqine

DKS = $(wildcard $(PRUNEDFOLDER)/*.dk)
DKOS = $(DKS:.dk=.dko)


.PHONY: all coqine compile generate depend prune check clean fullclean

all: coqine compile generate prune check

coqine:
	make -C coqine

# Compile the local [.v] files that are not part of the stdlib
compile: CoqMakefile
	make -f CoqMakefile

# Generate the [.dk] files by executing [main.v]
generate: coqine compile config.v | $(OUTFOLDER) $(PRUNEDFOLDER) $(BUILD_FOLDER)
	$(COQC) -init-file .coqrc -w all -R . Top -R coqine/src Coqine main.v

$(BUILD_FOLDER)/config.dk: generate | $(BUILD_FOLDER) $(OUTFOLDER)
	ls $(OUTFOLDER)/*GeoCoq*.dk | sed -e "s:$(OUTFOLDER)/Top__:#REQUIRE Top__:g" | sed -e "s/.dk/./g" > $(BUILD_FOLDER)/config.dk

prune: generate $(BUILD_FOLDER)/C.dk $(BUILD_FOLDER)/config.dk | $(PRUNEDFOLDER) $(OUTFOLDER)
	dkprune -l -I $(BUILD_FOLDER) -I $(OUTFOLDER) -o $(PRUNEDFOLDER) $(BUILD_FOLDER)/config.dk
	rm -f $(PRUNEDFOLDER)/C.dk

CoqMakefile: Make
	$(COQ_MAKEFILE) -f Make -o CoqMakefile

$(BUILD_FOLDER)/C.dk: | $(BUILD_FOLDER)
	make -C coqine/encodings _build/$(ENCODING)/C.dk
	cp coqine/encodings/_build/$(ENCODING)/C.dk $(BUILD_FOLDER)

config.v:
	make -C coqine/encodings _build/predicates/C.config
	cp coqine/encodings/_build/predicates/C.config config.v
	echo "Dedukti Set Encoding \"template\"." >> config.v
	echo "Dedukti Set Param \"syntax\" \"CondensedDedukti\"." >> config.v

# Generate the dependencies of [.dk] files
depend: prune | $(PRUNEDFOLDER) $(BUILD_FOLDER)
	$(DKDEP) -I $(PRUNEDFOLDER) -I $(BUILD_FOLDER) $(PRUNEDFOLDER)/*.dk > .depend

# Make sure .depend is generated then do the actual check
check: depend
	make actual_check

# Check and compile the generated [.dk]
actual_check: $(DKOS)

%.dko: %.dk | $(PRUNEDFOLDER) $(BUILD_FOLDER)
	$(DKCHECK) -I $(PRUNEDFOLDER) -I $(BUILD_FOLDER) --eta -e $<

$(OUTFOLDER): | $(BUILD_FOLDER)
	mkdir $(OUTFOLDER)

$(PRUNEDFOLDER): | $(BUILD_FOLDER)
	mkdir $(PRUNEDFOLDER)

$(BUILD_FOLDER):
	mkdir $(BUILD_FOLDER)

clean: CoqMakefile
	make -C coqine/encodings clean
	make -C coqine - clean
	make -f CoqMakefile - clean
	rm -rf $(OUTFOLDER) $(PRUNEDFOLDER) $(BUILD_FOLDER)
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
