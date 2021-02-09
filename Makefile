# Makefile syntax
# <target_file> : <dependency1> ...
# <TAB> command to produce target file

# If the dependencies or recipe need to take up more than one line, the line
# must be continued using a backslash.

all : choctaw_lexicon.lexc \
	choctaw_gen.hfstol \
	choctaw_ana.hfstol \
	choctaw_ana.png \
	choctaw_lexicon.png \
	choctaw.twol \
        choctaw_sc.hfst

nosc : choctaw_lexicon.lexc \
         choctaw_gen_nosc.hfstol

choctaw_lexicon.lexc : root.lexc nouns.lexc verbs.lexc
	cat root.lexc nouns.lexc verbs.lexc > choctaw_lexicon.lexc

choctaw_gen.hfst : choctaw_lexicon.lexc choctaw_sc.hfst
	hfst-lexc < choctaw_lexicon.lexc > choctaw_gen_nosc.hfst
	hfst-compose-intersect -1 choctaw_gen_nosc.hfst -2 choctaw_sc.hfst -o choctaw_gen.hfst

choctaw_gen_nosc.hfst : choctaw_lexicon.lexc
	hfst-lexc < choctaw_lexicon.lexc > choctaw_gen_nosc.hfst

choctaw_sc.hfst : choctaw.twol
	hfst-twolc -o choctaw_sc.hfst choctaw.twol

choctaw_gen.hfstol : choctaw_gen.hfst
	hfst-fst2fst --optimized-lookup-unweighted -i choctaw_gen.hfst -o choctaw_gen.hfstol

choctaw_gen_nosc.hfstol : choctaw_gen_nosc.hfst
	hfst-fst2fst --optimized-lookup-unweighted -i choctaw_gen_nosc.hfst -o choctaw_gen_nosc.hfstol

choctaw_ana.hfst : choctaw_gen.hfst
	hfst-invert -i choctaw_gen.hfst -o choctaw_ana.hfst

choctaw_ana.hfstol : choctaw_ana.hfst
	hfst-fst2fst --optimized-lookup-unweighted -i choctaw_ana.hfst -o choctaw_ana.hfstol

choctaw_ana.png : choctaw_ana.hfst
	hfst-fst2txt choctaw_ana.hfst | python3 att2dot.py | dot -T png -o choctaw_ana.png

choctaw_lexicon.png : choctaw_lexicon.lexc
	python3 lexc2dot.py < choctaw_lexicon.lexc | dot -T png -o choctaw_lexicon.png  # BUG

.PHONY : clean
clean :
	-rm *.hfst *.hfstol choctaw_lexicon.lexc

.PHONY : test
test :
	sh tests.sh  # sh is a command to run the argument filename as a shell script (usually bash)

strings.txt : choctaw_gen.hfst
	hfst-fst2strings -c 2 -X obey-flags choctaw_gen.hfst > strings.txt

stringsnosc.txt : 
	hfst-fst2strings -c 2 -X obey-flags choctaw_gen_nosc.hfst > strings.txt
