#!/bin/bash
# Detta är en demo
# Skriptet används för att skapar en användare, sätta upp en hemkatalog och tilldelar rätt grupp.

# Kontrollera att användare körs som root
if [[ $EUID -ne 0 ]]; then	# If $EUID motsvarar inte 0, visar error enligt nedan.
  echo "Error: Du har inte rättigheter för att köra skript!"
  exit 1
fi

:' >> Debugging...
 # Kontrollera att minst en användare skickats in till terminalen som argument.
if [[ "$#" -eq 0 ]]; then               # $# = används för att kontrollera antalet argument som skickats in till terminalen.
  echo "Error: Ange minst ett användarnamn."
  #exit 1
fi 


# Kontrollera om användaren redan finns i systemet.
for user in "$@"; do                   # $@ = alla argument
  if ! id "$user" &>/dev/null; then    # &>/dev/null; = används för att gömma alla output
  # Skapa en ny användare
  useradd -m "$user"		

  #Definiera path för hemkatalog
  hemKatalog="/home/$user"

  # Skapa undermappar, sättas deras ägare och ange deras rättigheter.
  mkdir -p "$hemKatalog"/{Documents,Downloads,Work}
  chown -R "$user:$user" "$hemKatalog"
  chmod 700 "$hemKatalog"/{Documents,Downloads,Work}  # Ändra rättigheter till 700, dvs. endast filägaren kan read, write och write.

  # Skriva ut meddelande till terminal
  echo "Användare '$user' och dess kataloger har skapats."

  # Skapa welcome.txt
 welcomeFile="$hemKatalog/welcome.txt" 
    {
      echo "Välkommen '$user'!"
      echo "Följande användare finns i systemet: "
  # cut = skriva ut alla användarnamn i systemet, ett per rad. 
  # -d: används för att bestämma en kolon (:) som avgränsare.
  # -f1 används för att hämta ut fält nummer 1, vilket motsvarar användarnamnet i filen /etc/passwd.     
      cut -d: -f1 /etc/passwd | sort	      # Sortera listan alfabetisk			
    } > "$welcomeFile" 											# Spara följande i welcome.txt

    chown "$user:$user" "$welcomeFile"			# Ändra filägaren för welcome.txt
    chmod 600 "$welcomeFile"								# Ändra rättigheter till 600, dvs. endast filägaren kan read och write.
else
  echo "Användaren '$user' finns redan."
  exit 1
fi
done
'
