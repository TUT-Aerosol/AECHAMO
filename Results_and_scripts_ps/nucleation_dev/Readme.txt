run_20130628T101416 on ajettu samoilla alkuarvoilla kuin
chamb(1) tiedostossa \Results and scripts_mp\validation 17.6\run_20130617T155553.mat

run_20130628T104848 on ajettu samoilla alkuarvoilla (paitsi N = 0 ja aika on lyhyempi) kuin
\Results and scripts_mp\Test and bug fixing\run_20130607T181225.mat

run_20130628T135329 on ajettu t�sm�lleen samoilla alkuarvoilla kuin
\Results and scripts_mp\Test and bug fixing\run_20130607T181225.mat

run_20130628T145150.mat: Cvap != vakio, massa s�ilyy.

run_20130629T085050 on ajettu tiedostolla SOA_formation_28062013_nucl.m

run_20130701T112621 sama kuin edellisen tiedoston chamb(1), nyt onnistuneesti.

run_20130702T155202 sama kuin edellinen, mutta halkaisijat asetettu 'NonNegative'
ja koagulaatio tapahtuu vain, kun kaikki halkaisijavektori on kasvava -> koagulaatio ei aiheuta NaN ja Inf.
T�m� paljon nopeampi kuin edellinen.

run_20130703T085158 on ajettu samoilla alkuarvoilla kuin
\Results and scripts_mp\Test and bug fixing\run_20130607T181225.mat, mutta
N=0. Versio on nyt muuttunut siten, ett� koagulaatio tapahtuu vain silloin,
kun halkaisijavektori on kasvava.

temp-tiedostot: Ajettu tiedostolla SOA_formation_28062013_nucl.m, josta on
poistettu pienempi h�yrynl�hde. T�ss� siis 7 ensimm�ist� ajoa, joissa on suuri
h�yrynl�hde. Kaikki paitsi 6 onnistuneita.