# Gra w statki jako problem decyzyjny

SPIS TREŚCI
1.	Idea problemu
2.	Matematyczna interpretacja problemu decyzyjnego
3.	CPLEX
4.	Algorytm Symulowanego Wyżarzania w języku python
5.	Wnioski


## Idea Problemu
Gra w statki to łamigłówka logiczna, pierwotnie ukazywana w czasopismach papierowych. Polega na rozmieszczeniu statków, na prostokątnej planszy, zamalowując jej pola, w miejsce statku. Chcę przenieść ją do środowiska wirtualnego, modyfikować rozmiar planszy, zbadać trudność problemu i czas rozwiązania go różnymi metodami.

## Matematyczna interpretacja problemu matematycznego
Koncept:
Plansza do gry jest o wymiarze prostokąta m x n, gdzie m,n ϵ N.
Przy każdym wierszu i kolumnie znajduje się liczba k, gdzie k <= m (dla liczby wierszy), k<=n (dla liczby kolumn), k ϵ N i określa, ile pól zajmują statki, w danym wierszu / kolumnie
Wszystkie ograniczenia kolumn i wierszy muszą zostać spełnione
Żaden ze statków nie styka się ze sobą rogami po skosie, ale statki mogą być ustawiane pionowo i poziomo

![image](https://github.com/bidonbidonbidon/battleship/assets/134869902/687fdf32-3fa7-4f3e-b2f1-1623239c14d0)


ZŁE WYPEŁNIENIE (niespełniony warunek ograniczeń wierszy i kolumn)


![image](https://github.com/bidonbidonbidon/battleship/assets/134869902/efbd8c87-abcb-45f2-8c6f-7e71561cb00a)

ZŁE WYPEŁNIENIE (statki stykają się po skosie)

![image](https://github.com/bidonbidonbidon/battleship/assets/134869902/fbf0ceed-0d15-4bef-989d-1e13ef7d4412)

POPRAWNE WYPEŁNIENIE PLANSZY DO GRY

Każdą łamigłówkę o wymiarach m x n można zapisać jako 3-elementowy zbiór {I,C,R}, gdzie
I: {1..m} x {1..n} -> {1,0,?}, m,n ϵ N
I jest funkcją początkowego układu statków na planszy. Jeśli I(i,j) = 1  to jest tam statek, jeśli I(i,j) = 0, to jest tam woda, jeśli I(i,j) = ? to rozwiązujący musi umieścić tam statek lub wodę. 
i,j ϵ N, i,j <= n,m.
Dla wygody zakładam, że początkowa plansza wypełniona jest tylko znakami „?”.

C jest funkcją opisującą limity rozmieszczenia statków w kolumnach.
C: [Ci]1 x m = k, gdzie k,m ϵ N i k <=m, i ci-ta komórka macierzy opisuje limit statków w i-tej kolumnie.

R jest funkcją opisującą limity rozmieszczenia statków w wierszach.
C: [Ri]1 x n = j, gdzie j,n ϵ N i j <=n, i ri-ta komórka macierzy opisuje limit statków w j-tym wierszu.

Rozwiązaniem łamigłówki niech będzie J
J: {1..m} x {1..n}  {1,0} i na mocy powyższych warunków
Jeśli I(i,j) = J(i,j) i jeśli J(i,j) =/= ? oraz J spełnia zasady wypełnienia planszy.

Przykład:
m = 5, n = 5, I = {?,?,?,?,?} x {?,?,?,?,?}, C = [2,2,3,1,2], R = [3,1,3,1,3].
![image](https://github.com/bidonbidonbidon/battleship/assets/134869902/a5974ab8-bdb9-4e29-98fc-943d1c3fc7a0)


Rozwiązaniem jest

![image](https://github.com/bidonbidonbidon/battleship/assets/134869902/133badbf-bdc4-4d9d-a24b-efba88b503be)


## Klasyfikacja problemu:

Chcąc udowodnić, że łamigłówka statków jest problemem NP-trudnym, można przeprowadzić redukcję problemu pokrycia wierzchołkowego do łamigłówki statków. Przekształćmy instancję jednego problemu na instancję drugiego problemu w taki sposób, że rozwiązanie jednego problemu można skonstruować na podstawie rozwiązania drugiego.
Problem pokrycia wierzchołkowego, klasyfikujący się jako NP.-trudny, polega na znalezieniu minimalnego zbioru wierzchołków, które pokrywają wszystkie krawędzie w danym grafie. 
Załóżmy, że mamy instancję problemu pokrycia wierzchołkowego, która składa się z grafu G=(V, E) oraz parametru k. Chcemy przekształcić ją na instancję łamigłówki statków.
Tworzymy planszę o rozmiarze |V| x (k+1) (liczba wierzchołków x parametr k + 1).
Dla każdej krawędzi (u, v) w grafie G, umieszczamy statek (reprezentowany przez jedynki) o długości k+1 w wierszu odpowiadającym wierzchołkowi u, a kolumnie odpowiadającej krawędzi (u, v). 
Dla każdego wierzchołka w grafie G, umieszczamy ograniczenie na sumę jedynek dla danego wiersza planszy. Ograniczenie wynosi k, ponieważ szukamy minimalnego zbioru wierzchołków pokrywających wszystkie krawędzie.
Rozwiązanie łamigłówki statków będzie odpowiadało zbiorowi wierzchołków, które pokrywają wszystkie krawędzie w grafie G. Jeśli istnieje pokrycie wierzchołkowe o rozmiarze k, to można skonstruować poprawne rozwiązanie łamigłówki statków, w której suma różnicy dla każdego wiersza i kolumny będzie wynosić zero. Jeśli nie istnieje pokrycie wierzchołkowe o rozmiarze k, to nie istnieje poprawne rozwiązanie łamigłówki statków.
Ponieważ problem pokrycia wierzchołkowego jest NP-trudny, a łamigłówka statków może być zredukowana do problemu pokrycia wierzchołkowego, stąd łamigłówka statków jest również problemem NP-trudnym.

## CPLEX
Pełen kod w IBM CPLEX znajduje się pod battleship_cplex.

Na początku posłużę się solverem IBM LOG CPLEX. Modyfikuję, dla własnej wygody, rozmiar planszy, czyniąc ją o 2 większą i szerszą, w celu magazynowania ograniczeń. Z poziomu programu narzucam ograniczenia wierszy i kolumn (dbając o to, by pierwsza i ostatnia komórka tablicy była zerowa).
Zmienna decyzyjna jest binarna, a funkcją celu jest minimalizacja różnic sum po komórkach z wierszy z ograniczeniami wierszy oraz sum po kolumnach z ograniczeniami kolumn. Jeśli różnica ta wyniesie zero, spełniając wszystkie ograniczenia, łamigłówkę można uznać za rozwiązaną



Dla planszy 9x9 i ograniczeń
R = [0,5,3,4,0,5,1,3,3,3,0]
C = [0,5,2,2,2,4,2,4,1,5,0] 

Rozwiązanie otrzymane w 1,91 s.

0	0	0	0	0	0	0	0	0	0	0

0	1	1	1	0	1	0	0	0	1	0

0	0	0	0	0	1	0	1	0	1	0

0	1	0	1	0	0	0	1	0	1	0

0	0	0	0	0	0	0	0	0	0	0

0	1	0	0	1	1	1	0	1	0	0

0	1	0	0	0	0	0	0	0	0	0

0	0	0	0	0	1	1	1	0	0	0

0	1	1	0	0	0	0	0	0	1	0

0	0	0	0	1	0	0	1	0	1	0

0	0	0	0	0	0	0	0	0	0	0

# 

Dla planszy 3x3 i ograniczeń
R = [0,2,0,3,0]
C = [0,2,1,2,0]

Rozwiązanie otrzymane w 0,36s

0	0	0	0	0

0	1	0	1	0

0	0	0	0	0

0	1	1	1	0

0	0	0	0	0


# Algorytm SA w języku python
Pełen kod SA znajduje się pod battleship_sa_python.

Ograniczenia wierszy i rzędów, oraz binarna zmienna decyzyjna pozostają identyczne jak przy implementacji rozwiązania w programie CPLEX. Przed implementacją metaheurystyki symulowanego wyżarzania stworzyłem 4 funkcje pomocnicze.
Wypełnij_X ,która wypełnia losowo grywalny obszar planszy (pomijający jej obrzeża) co k jedynkami,  gdzie k jest sumą ograniczeń z kolumn. Oznacza to, że jeśli ograniczenia planszy 3x3 są równe [0,2,1,2,0], to grywalny obszar planszy zostanie zapełniony losowo pięcioma jedynkami.

Is_x_valid, która sprawdza, czy podany układ planszy X jest zgodny z zasadami o niestykaniu się rogami po skosie, oraz tworzeniu ortogonalnych „L-ek” pod kątem prostym

Generuj_X, która generowała prawidłowe, zgodne z zasadami gry propozycje zapełnienia planszy do gry

Policz_koszt, która sprawdzała wartość bezwzględną różnicy sum po komórkach z wierszy z ograniczeniami wierszy oraz sum po kolumnach z ograniczeniami kolumn.

W metaheurystyce SA nadałem wartość początkową trzem parametrom (To – temperaturze początkowej, Tk – dolnej granicy, temperaturze końcowej, alfa – współczynnik zmniejszania się temperatury.

Schemat algorytmu można przedstawić następująco
# 

Generuj zgodną z regułami planszę początkową X

Oblicz  koszt X i niech będzie on tymczasowym minimum

Dopóki To > Tk:

	Generuj nową planszę Xnowa
 
	Jeśli koszt Xnowa – X < 0 lub jeśli e ^ ( -(xnowa-x)/To ) to:
 
		X := Xnowa
  
		Koszt_X := koszt_Xnowa
  
	Jeśli koszt_X < minimum to:

		Minimum := koszt_X
  
	To = To * alfa


Zmienne o poszczególnych wartościach To, kosztu i minimum przechowywałem w tablicach dla poszczególnych iteracji oraz mierzyłem czas wykonywania się algorytmu dla danego przykładu

Implementacja SA dla planszy 9x9 i ograniczeń R = [0,5,3,4,0,5,1,3,3,3,0]
C = [0,5,2,2,2,4,2,4,1,5,0], funkcje pomocnicze, zapisy zmian temperatur i wizualizacja wyników.
 

Minimum dla rozmiaru planszy 9 x 9 :18 Minimalne rozwiązanie:

[[0 0 0 0 0 0 0 0 0 0 0]

[0 1 1 0 1 1 0 0 1 1 0]

[0 0 0 0 0 0 0 0 0 0 0]

[0 1 0 1 1 0 0 0 1 0 0]

[0 0 0 0 0 0 1 0 0 0 0]

[0 0 1 0 0 0 1 0 0 0 0]

[0 0 0 0 0 0 0 0 0 1 0]

[0 0 0 1 0 1 0 1 0 0 0]

[0 0 0 1 0 0 0 1 0 0 0]

[0 1 0 0 0 1 0 1 0 1 0]

[0 0 0 0 0 0 0 0 0 0 0]]

czas trwania SA dla rozmiaru planszy 9 x 9: 1447.0972390174866
# 

Implementacja SA dla planszy 3x3 i R = [0,2,0,3,0], C = [0,2,1,2,0], zapisy zmian temperatur i wizualizacja wyników.

Minimum dla rozmiaru planszy 3 x 3 :0 Minimalne rozwiązanie:

[[0 0 0 0 0]

[0 1 0 1 0]

[0 0 0 0 0]

[0 1 1 1 0]

[0 0 0 0 0]]

czas trwania SA dla rozmiaru planszy 3 x 3: 0.07295894622802734s


# Wnioski

Dla plansz 3x3 solver IBM CPLEX sprawił się nieporównywalnie lepiej niż algorytm SA. 

Czasy otrzymania rozwiązań są szybsze, a co więcej i same rozwiązania lepsze (przy planszy 9x9 SA dla zadanych parametrów nie znalazł lepszego rozwiązania, a solver uzyskał je bardzo szybko). 

Modyfikując parametry (zmniejszając alfę, zwiększając To, albo zmniejszając Tk), pozwalając programowi na dłuższe działanie i obliczanie prawdopodobnie moglibyśmy uzyskać podobnie dobre rozwiązania kosztem jednak złożoności czasowej.

Dla większych przykładów, wykraczających poza możliwości solvera, metaheurystyka SA mogłaby sprawdzić się jednak lepiej, znajdując dopuszczalne rozwiązanie po jakimś czasie.

Różnica czasów znajdywania rozwiązywania dla różnych rozmiarów planszy jest zaskakująco inna dla solvera i SA. W solverze, znalezienie rozwiązania dla bardziej rozbudowanego przykładu, zajęło tylko 5 razy dłużej czasu niż dla przykładu 3x3. S przypadku SA znalezienie rozwiązania dla bardziej rozbudowanego 20 671 razy dłużej. 

Gdyby chcieć zawrzeć, istniejący w pierwotnej i oryginalnej wersji łamigłówki dodatkowo ograniczenie rozmieszczenia całej floty (statków różnego rodzaju), czas rozwiązywania byłby jeszcze dłuższy.

Solver dobrze sprawdza się dla przypadków, które można rozwiązać, jednakże te wyższej złożoności prawdopodobnie lepiej rozwiązałaby metaheurystyka (kosztem dłuższego czasu szukania najlepszej odpowiedzi).


