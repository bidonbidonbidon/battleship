/*********************************************
 * OPL 22.1.1.0 Model
 * Author: akr
 * Creation Date: 16 maj 2023 at 15:31:52
 *********************************************/

 using CP;
 int c = 8; // kolumn jest zawsze o 2 wiecej niz w planszy do gry
 int r = 8; //rzedów jest zawsze o 2 wiecej niz w planszy do gry
 range crange = 1..c;
 range rrange = 1..r;
 range crangemodified = 2..(c-1); //zmienna przechowująca zasięg "grywalnych pól" w kolumnach
 range rrangemodified = 2..(r-1); //zmienna przechowująca zasięg "grywalnych pól" w rzedach
 int rlimit[rrange] = [0,4,1,3,1,0,4,0]; //ograniczenia rzedów
 int climit[crange] = [0,3,2,1,3,3,1,0]; //ograniczenia kolumn
 dvar boolean x[rrange][crange]; //binarna zmienna decyzyjna

 
 
 minimize sum(i in crange) climit[i] + sum(j in rrange) rlimit[j] - sum(j in rrange) sum (i in crange) x[j][i] - sum (j in rrange) sum(i in crange) x[i][j];
 
subject to
{
  sum(i in crange) climit[i] + sum(j in rrange) rlimit[j] - sum(j in rrange) sum(i in crange) x[j][i] - sum(j in rrange) sum(i in crange) x[i][j] == 0; 
  //nie można umieścić więcej niż potrzebną liczbę pól statków
  forall (i in crange) sum(j in rrange) x[i][j] - climit[i] == 0; //ograniczenia kolumn
  forall (j in rrange) sum(i in crange) x[i][j] - rlimit[j] == 0; //ograniczenia wierszy
  forall (i in 1..1) sum(j in 1..r) x[i][j] == 0; //zagwarantowanie by "obramowania pozostały puste"
  forall (i in r..r) sum(j in 1..r) x[i][j] == 0;
  forall (j in 1..1) sum(i in 1..c) x[i][j] == 0;
  forall (j in c..c) sum(i in 1..c) x[i][j] == 0;
  forall (i in crangemodified) { forall (j in rrangemodified) (x [i][j]+ x[i+1][j+1]) <= 1;} //ograniczenia braku sąsiedctwa po skosie
  forall (i in crangemodified) { forall (j in rrangemodified) (x [i][j]+ x[i+1][j-1]) <= 1;}
  forall (i in rrangemodified) { forall (j in crangemodified) (x [i][j]+ x[i-1][j+1]) <= 1;}
  forall (i in rrangemodified) { forall (j in crangemodified) (x [i][j]+ x[i-1][j-1]) <= 1;}

}


