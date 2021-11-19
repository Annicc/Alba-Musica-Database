#include <cstdio>
#include <iostream>
#include "dependencies/include/libpq-fe.h"
#include<iomanip>
#include<math.h>
#include <windows.h>

using namespace std;

#define PG_USER "postgres" // il vostro nome utente
#define PG_PASS "admin" // la vostra password
#define PG_DB "Alba" // il nome del database
#define PG_HOST "127.0.0.1"
#define PG_PORT 5432

/**
* @brief funzione per "pulire" lo schermo, copiata da cplusplus.com
*/
void ClearScreen()
  {
  HANDLE                     hStdOut;
  CONSOLE_SCREEN_BUFFER_INFO csbi;
  DWORD                      count;
  DWORD                      cellCount;
  COORD                      homeCoords = { 0, 0 };

  hStdOut = GetStdHandle( STD_OUTPUT_HANDLE );
  if (hStdOut == INVALID_HANDLE_VALUE) return;

  /* Get the number of cells in the current buffer */
  if (!GetConsoleScreenBufferInfo( hStdOut, &csbi )) return;
  cellCount = csbi.dwSize.X *csbi.dwSize.Y;

  /* Fill the entire buffer with spaces */
  if (!FillConsoleOutputCharacter(
    hStdOut,
    (TCHAR) ' ',
    cellCount,
    homeCoords,
    &count
    )) return;

  /* Fill the entire buffer with the current colors and attributes */
  if (!FillConsoleOutputAttribute(
    hStdOut,
    csbi.wAttributes,
    cellCount,
    homeCoords,
    &count
    )) return;

  /* Move the cursor home */
  SetConsoleCursorPosition( hStdOut, homeCoords );
};
  
/**
* @brief Funzione per controllare se la query ha prodotto risultati consistenti
* @param res => PGresult*, risultati della query da controllare
* @param 
*/
void checkResults (PGresult * res , const PGconn * conn) {
	if (PQresultStatus (res) != PGRES_TUPLES_OK) 
	{
 		cout << "Risultati inconsistenti!" << endl << PQerrorMessage(conn) << endl;
 		PQclear(res);
 		exit (1);
 	}
};

/**
* @brief Funzione per stampare a video i risulati di una query
* @param res => PGresult*, risultati della query da stampare
*/
void printResult(PGresult * res)
{
	int campi = PQnfields(res);
	int tuple = PQntuples(res);
    int colWidth=30;

    //table header 
	cout << setfill('-') << setw((campi+1)*colWidth) << "-" << endl;
	cout << setfill(' ') << fixed;

	for(int i=0; i<campi; i++)
		cout << setw(colWidth) << PQfname (res,i);
	cout << endl;

	cout << setfill('-') << setw((campi+1)*colWidth) << "-" << endl; 
	cout << setfill(' ') << fixed; 


	for(int i=0; i<tuple; i++)
	{
		for(int j=0; j<campi; j++)
		{
			cout << setprecision(0) << setw(colWidth) << PQgetvalue(res, i, j);
		}
		cout << endl;
	}
	cout << setfill('-') << setw((campi+1)*colWidth) << "-" << endl; 
};

/**
* @brief stampa la lista delle possibili query da eseguire
*/
void stampaListaQuery()
{
 	cout << "[1] Visualizza l" << char(39) << "importo totale guadagnato da un prodotto. (costo di vendita - costo di produzione - percentuale per artista)" << endl;
 	cout << "[2] Visualizza, per ogni genere, l" << char(39) << "artista che ha pi" << char(151) << " brani appartenenti al genere musicale" << endl;
 	cout << "[3] Visualizza il guadagno totale di un" << char(39) << "artista. (guadagno concessioni + guadagno vendite - costo prenotazioni)" << endl;
 	cout << "[4] Visualizza l" << char(39) << "artista che ha creato pi" << char(151) << " prodotti" << endl;
 	cout << "[5] Visualizzare i prodotti che hanno un maggior rapporto copie vendute/copie prodotte" << endl;
 	cout << "[6] Visualizzare il distributore che ha acquistato il maggior numero di prodotti fisici per ogni prodotto" << endl;
 	cout << "[0] exit" << endl;
 	cout << "Scelta: ";	
 };

/**
* @brief query per ottenere l’importo totale guadagnato da un prodotto
* @param conn: connessione al database
*/
void queryGuadagnoProdotto(PGconn* conn)
{
 	string query= 	"select titolo as prodotto, sum(vendita_totale - (vendita_totale * percentuale_ricavo) - costo_totale) as totale\n"
					"from (\n"
					"\tselect titolo, percentuale_ricavo, sum(costo_vendita*n_copie_vendute) as vendita_totale, sum(costo_produzione_per_copia*n_copie_prodotte) as costo_totale\n"
					"\tfrom prodotto\n"
					"\t\tjoin prodotto_fisico on (prodotto_fisico.prodotto = prodotto.id)\n"
					"\t\tjoin vendita on (prodotto_fisico.prodotto = vendita.prodotto \n"
					"\t\t\t\t\t\t and prodotto_fisico.tipo = vendita.prodottofisico)\n"
					"\t\tjoin produzione on (prodotto_fisico.prodotto = produzione.prodotto \n"
					"\t\t\t\t\t\t\tand prodotto_fisico.tipo = produzione.prodottofisico)\n"
					"\tgroup by titolo, percentuale_ricavo\n"
					") as costi\n"
					"group by prodotto\n"
					"order by totale desc";

 	PGresult * res= PQexec (conn, query.c_str());
 	checkResults(res, conn);
	printResult(res);
};

/**
* @brief query che stampa, per ogni genere, l’artista che ha più brani appartenenti al genere musicale
* @param conn: connessione al database
*/
void queryArtistiGeneri(PGconn* conn)
{
 	string query=	"drop view if exists artisti_per_canzone;\n"
					"create view artisti_per_canzone as\n"
					"select nome_arte as artista, brano.id as brano, titolo\n"
					"from brano\n"
					"\tjoin compone_brano on (brano.id = compone_brano.brano)\n"
					"\tjoin traccia on (traccia.id = compone_brano.traccia)\n"
					"\tleft join prodotta on (traccia.id = prodotta.traccia)\n"
					"\tjoin artista on (artista.nome_arte = prodotta.artista)\n"
					"\tleft join scritta on (artista.nome_arte = scritta.artista)\n"
					"\tleft join cantata on (artista.nome_arte = cantata.artista)\n"
					"group by nome_arte, brano.id, titolo;\n"
					"\n"
					"select distinct nome, artista, max(totale) as massimo\n"
					"from (\n"
					"\tselect artista, nome, count(titolo)as totale\n"
					"\tfrom artisti_per_canzone\n"
					"\t\tjoin appartiene_brano on (artisti_per_canzone.brano = appartiene_brano.brano)\n"
					"\t\tjoin genere_musicale on (genere_musicale.nome = appartiene_brano.nomegenere)\n"
					"\tgroup by artista, nome\n"
					"\t) as generi_canzoni\n"
					"group by nome, artista";

 	PGresult * res= PQexec (conn, query.c_str());
 	checkResults(res, conn);
	printResult(res);
};

/**
* @brief query per ottenere il guadagno totale di un’artista
* @param conn: connessione al database
*/
void queryGuadagnoArtista(PGconn* conn)
{
	string query=	"select ricavi_concessione.artista, ricavo_concessioni + coalesce(ricavo_vendita, 0::money) - coalesce(costo_prenotazioni, 0::money) as guadagno\n"
					"from (\n"
					"\tselect nome_arte as artista, sum(((DATE_PART('year', CURRENT_DATE) - DATE_PART('year', concessione.data_inizio)) * 12 +\n"
					"\t\t\t(DATE_PART('month', CURRENT_DATE) - DATE_PART('month', concessione.data_inizio))) * (costo_mensile * percentuale_ricavo)) as ricavo_concessioni\n"
					"\tfrom artista\n"
					"\t\tjoin detiene on (artista.nome_arte = detiene.artista)\n"
					"\t\tjoin diritto_autore on (detiene.doi = diritto_autore.doi)\n"
					"\t\tjoin concessione on (diritto_autore.doi = concessione.doi)\n"
					"\tgroup by nome_arte\n"
					") as ricavi_concessione\n"
					"left join (\n"
					"\tselect nome_arte as artista, sum(ricevuta.importo) as costo_prenotazioni\n"
					"\tfrom artista\n"
					"\t\tjoin prenotazione on (prenotazione.artista = artista.nome_arte)\n"
					"\t\tjoin ricevuta on (ricevuta.id = prenotazione.ricevuta)\n"
					"\tgroup by nome_arte\n"
					") as costi_prenotazioni on (ricavi_concessione.artista = costi_prenotazioni.artista)\n"
					"left join (\n"
					"\tselect artista, sum(costo_vendita*n_copie_vendute*percentuale_ricavo) as ricavo_vendita\n"
					"\tfrom prodotto\n"
					"\t\tjoin prodotto_fisico on (prodotto_fisico.prodotto = prodotto.id)\n"
					"\t\tjoin vendita on (prodotto_fisico.prodotto = vendita.prodotto \n"
					"\t\t\t\t\t\t and prodotto_fisico.tipo = vendita.prodottofisico)\n"
					"\t\tjoin(\n"
					"\t\t\tselect nome_arte as artista, forma_prodotto.prodotto as prodotto\n"
					"\t\t\tfrom forma_prodotto \n"
					"\t\t\t\tjoin compone_brano on (compone_brano.brano = forma_prodotto.brano)\n"
					"\t\t\t\tleft join prodotta on (compone_brano.traccia = prodotta.traccia)\n"
					"\t\t\t\tjoin artista on (artista.nome_arte = prodotta.artista)\n"
					"\t\t\t\tleft join scritta on (artista.nome_arte = scritta.artista)\n"
					"\t\t\t\tleft join cantata on (artista.nome_arte = cantata.artista)\n"
					"\t\t\tgroup by nome_arte, forma_prodotto.prodotto\n"
					"\t\t) as art_prod on (prodotto.id = art_prod.prodotto)\n"
					"\tgroup by artista\n"
					") as ricavi_vendita on (ricavi_vendita.artista = ricavi_concessione.artista)\n"
					"order by guadagno desc";

	PGresult * res= PQexec (conn, query.c_str());
 	checkResults(res, conn);
	printResult(res);
};

/**
* @brief query per ottenere l’artista che ha creato più prodotti
* @param conn: connessione al database
*/
void queryArtistaProdotti(PGconn* conn)
{

	string query=	"drop view if exists artisti_per_prodotto;\n"
					"create view artisti_per_prodotto as\n"
					"select nome_arte as artista, compone_brano.brano as brano\n"
					"from forma_prodotto \n"
					"\tjoin compone_brano on (compone_brano.brano = forma_prodotto.brano)\n"
					"\tleft join prodotta on (compone_brano.traccia = prodotta.traccia)\n"
					"\tjoin artista on (artista.nome_arte = prodotta.artista)\n"
					"\tleft join scritta on (artista.nome_arte = scritta.artista)\n"
					"\tleft join cantata on (artista.nome_arte = cantata.artista)\n"
					"group by nome_arte, compone_brano.brano;\n"
					"\n"
					"select massimo_prodotti.artista, massimo_prodotti.massimo\n"
					"from(\n"
					"\tselect artista, max(numero_prodotti) as massimo\n"
					"\tfrom(\n"
					"\t\tselect artista, count(brano) as numero_prodotti\n"
					"\t\tfrom artisti_per_prodotto\n"
					"\t\tgroup by artista\n"
					"\t\t) as conto_prodotti\n"
					"\tgroup by artista\n"
					"\t) as massimo_prodotti\n"
					"where massimo_prodotti.massimo = (\n"
					"\tselect max(numero_prodotti)\n"
					"\tfrom(\n"
					"\t\tselect artista, count(brano) as numero_prodotti\n"
					"\t\tfrom artisti_per_prodotto\n"
					"\t\tgroup by artista\n"
					"\t\t) as conto_prodotti\n"
					"\t)\n"
					"group by artista, massimo_prodotti.massimo\n"
					"order by artista asc";

	PGresult * res= PQexec (conn, query.c_str());
 	checkResults(res, conn);
	printResult(res);
};

/**
* @brief query per ottenere i prodotti che hanno un maggior rapporto copie vendute/copie prodotte
* @param conn: connessione al database
*/
void queryRapportoVenditaProduzione(PGconn* conn)
{
	string query=	"select prodotto.titolo as prodotto, to_char((cast((sum(n_copie_vendute))as float)/cast((sum(n_copie_prodotte))as float)), '0.999') as rapporto\n"
					"from prodotto\n"
					"\tjoin prodotto_fisico on (prodotto.id = prodotto_fisico.prodotto)\n"
					"\tjoin vendita on (prodotto_fisico.prodotto = vendita.prodotto \n"
					"\t\t\t\t\t and prodotto_fisico.tipo = vendita.prodottofisico)\n"
					"\tjoin produzione on (prodotto_fisico.prodotto = produzione.prodotto \n"
					"\t\t\t\t\t\tand prodotto_fisico.tipo = produzione.prodottofisico)\n"
					"group by prodotto.titolo\n"
					"order by rapporto desc";

	PGresult * res= PQexec (conn, query.c_str());
 	checkResults(res, conn);
	printResult(res);
};

/**
* @brief query per ottenere il distributore che ha acquistato il maggior numero di prodotti fisici per ogni prodotto
* @param conn: connessione al database
*/
void queryDistributoreProdotti(PGconn* conn)
{
	string query=	"select v1.prodotto, v1.azienda, v1.massimo as copie_acquistate\n"
					"from (\n"
					"\tselect totale_copie.prodotto as prodotto, totale_copie.azienda, max(totale_copie.numero_copie) as massimo\n"
					"\tfrom(\n"
					"\t\tselect prodotto.titolo as prodotto, distributore.nome as azienda, sum(n_copie_vendute) as numero_copie\n"
					"\t\tfrom prodotto\n"
					"\t\t\tjoin prodotto_fisico on (prodotto.id = prodotto_fisico.prodotto)\n"
					"\t\t\tjoin vendita on (prodotto_fisico.prodotto = vendita.prodotto \n"
					"\t\t\t\t\t\t\t and prodotto_fisico.tipo = vendita.prodottofisico)\n"
					"\t\t\tjoin distributore on (vendita.azienda = distributore.codice_univoco_fatturazione)\n"
					"\t\tgroup by prodotto.titolo, distributore.nome\n"
					"\t\t) as totale_copie\n"
					"\tgroup by totale_copie.prodotto, totale_copie.azienda\n"
					") as v1\n"
					"join (\n"
					"\tselect totale_copie.prodotto as prodotto, max(totale_copie.numero_copie) as massimo\n"
					"\tfrom(\n"
					"\t\tselect prodotto.titolo as prodotto, distributore.nome as azienda, sum(n_copie_vendute) as numero_copie\n"
					"\t\tfrom prodotto\n"
					"\t\t\tjoin prodotto_fisico on (prodotto.id = prodotto_fisico.prodotto)\n"
					"\t\t\tjoin vendita on (prodotto_fisico.prodotto = vendita.prodotto \n"
					"\t\t\t\t\t\t\t and prodotto_fisico.tipo = vendita.prodottofisico)\n"
					"\t\t\tjoin distributore on (vendita.azienda = distributore.codice_univoco_fatturazione)\n"
					"\t\tgroup by prodotto.titolo, distributore.nome\n"
					"\t\t) as totale_copie\n"
					"\tgroup by totale_copie.prodotto\n"
					") as v2\n"
					"on (v1.massimo = v2.massimo)\n"
					"order by copie_acquistate desc";

	PGresult * res= PQexec (conn, query.c_str());
 	checkResults(res, conn);
	printResult(res);
};

int main(int argc, char** argv)
{
	char conninfo [250];
	sprintf(conninfo, "user =%s password =%s dbname =%s hostaddr =%s port =%d", PG_USER, PG_PASS, PG_DB, PG_HOST, PG_PORT);

	PGconn* conn= PQconnectdb(conninfo);

	if(PQstatus(conn) != CONNECTION_OK)
	{
		cout << "Errore di connessione" << PQerrorMessage ( conn );
		PQfinish (conn);
		exit(1);
	}

	cout << "Connessione avvenuta correttamente" << endl;
	
	int input=0;
	do {
		stampaListaQuery();
		cin >> input;
		cout << endl;
		ClearScreen();
		switch(input)
		{
			case 1:
				queryGuadagnoProdotto(conn);
				break;
			case 2:
				queryArtistiGeneri(conn);
				break;
			case 3:
				queryGuadagnoArtista(conn);
				break;
			case 4:
				queryArtistaProdotti(conn);
				break;
			case 5:
				queryRapportoVenditaProduzione(conn);
				break;
			case 6:
				queryDistributoreProdotti(conn);
				break;	
			default:
				break;
		}
	}while(input!=0);
		
	PQfinish (conn);	
	return 0;
}