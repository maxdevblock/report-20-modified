# report-20-modified
Tentativo di parametrizzazione di Rt COVID-19 su mobilità Google e compliance della popolazione alle norme di igiene e sicurezza nelle regioni italiane.

# WORK IN PROGRESS

# Requisiti di sistema
Sono stati usati

- MacOS Sierra 10.12 su iMac fine 2013 (3.1 GHz Intel Core i7, 8GB RAM)
- `R` version 3.6.3 (2020-02-29)
- `Python` v3.7

I modelli sono stati lanciati con `source` da `R studio` dopo aver installato i packages necessari direttamente da `R studio` (senza compilazione).

Data l'elevata dipendenza dei packages `R` dal sistema operativo e dalla versione di `R` non si assicura che i modelli possano girare correttamente con altre specifiche senza debite modifiche.

`Python` è stato utilizzato per preparare i dati `csv` dei gruppi di compliance.

# Istruzioni
Solo al primo utilizzo:

- Lanciare `R studio`, aprire la directory corrispondente al modello _originale_ e renderla working directory
- Aprire ciascun file `.r` (nella directory principale e nelle sottodirectory _Italy/code/utils_ e _Italy/code/plotting_) e installare i packages mancanti (vengono mostrati nella barra gialla superiore). ATTENZIONE: tutti i pacchetti sono necessari.

Per lanciare il modello:

- Lanciare `R studio`, aprire la directory corrispondente al modello scelto e renderla working directory
- Impostare variabili di `DEBUG` e `FULL` alle righe `29` e `35` di _base-italy.r_
  - `DEBUG = "TRUE"` e `FULL = "FALSE"`: solo 40 iterazioni di controllo
  - `DEBUG = "FALSE"` e `FULL = "FALSE"`: preliminare, 600 iterazioni, solo dati misurati senza previsioni
  - `DEBUG = "FALSE"` e `FULL = "TRUE"`: completa, 2000 iterazioni, dati misurati e previsioni
- cliccare su `source` e attendere i risultati nelle subdirectories _Italy/figures_ e _Italy/results_
