#!/bin/bash 

# Kontrollera att användare kör som root
if [[ $EUID -ne 0 ]]; then	# If false, visar error
  echo "Error: Du har inte rättigheter för att köra skript!"
  exit 1
fi

# Läsa in användarens input
read -p "Skriv in ditt/dina användarnamn: " -a Users

# Loop genom varje användare
for User in "${Users[@]}"; do

  # Kontrollera om användaren redan finns
	# If true, skriva ut en text att användare redan finns.
  if grep -q "^$User:" /etc/passwd; then	# /etc/passwd är filem som innehåller alla användare på systemet.
    echo "User '$User' finns redan."
  else
    # If false, skapa ny användare
    useradd -m "$User"
    echo "User '$User' lyckades att skapas."

    # Skapa ett hemkatalog för ny användare
    Hemkatalog="/home/$User"

    # Skapa undermappar Documents, Downloads och Work
    for dir in Documents Downloads Work; do
      mkdir -p "$Hemkatalog/$dir"
      chown "$User:$User" "$Hemkatalog/$dir"	# Ändra filägaren på hemkatalog och dess undermappar till användare som precis skapat
      chmod 700 "$Hemkatalog/$dir"						# Ändra rättigheter till 700, dvs. endast filägaren kan read, write, execute.
    done

    # Skapa welcome_file.txt i hemkatalog
    Welcome_file="$Hemkatalog/welcome.txt"

    {
      echo "Välkommen $User"
      echo "Följande är alla användare i systemet:"
      cut -d: -f1 /etc/passwd								# Skriva ut alla användarnamn i systemet, ett per rad. -d: för att bestämma en kolon (:) som avgränsare. -f1 används för att hämta ut fält nummer 1, vilket motsvarar användarnamnet i filen /etc/passwd
    } > "$Welcome_file"											# Spara följande i Welcome_file.txt

    chown "$User:$User" "$Welcome_file"			# Ändra filägaren på Welcome_file och dess undermappar till användare som precis skapat
    chmod 644 "$Welcome_file"								# Ändra rättigheter till 644, dvs. filägaren kan read och write, grupper kan endast läsa och alla och andra kan endast läsa.
  fi

done
