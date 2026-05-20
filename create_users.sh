#!/bin/bash 

# Kontrollera att användare körs som root
if [[ $EUID -ne 0 ]]; then	# If false, visar error nedan
  echo "Error: Du har inte rättigheter för att köra skript!"
  exit 1
fi

# En list av undermappar
Sub_dir=("Documents" "Downloads" "Work")

Users=("Anna" "Bjorn" "Charlie")

# Loop genom varje användare
for User in "${Users[@]}"; do
    # Skapa ny användare
    useradd "$User"		
    echo "User '$User' lyckades skapat."

    # Skapa ett hemkatalog för ny användare manuellt
    Hemkatalog="/home/$User"
	mkdir -p "$Hemkatalog"
    chown "$User:$User" "$Hemkatalog"	# Ändra filägaren på hemkatalog till användare som precis skapat
    chmod 700 "$Hemkatalog"				# Ändra hemkatalog rättigheter till 700, dvs. endast filägaren kan read, write, execute.

    # Skapa undermappar Documents, Downloads och Work
    for Dir in "${Sub_dir[@]}"; do
      mkdir -p "$Hemkatalog/$Dir"
      chown "$User:$User" "$Hemkatalog/$Dir"	# Ändra filägaren på undermappar till användare som precis skapat
      chmod 700 "$Hemkatalog/$Dir"				# Ändra på undermappars rättigheter till 700, dvs. endast filägaren kan read, write, execute.
    done

    # Skapa welcome_file.txt i hemkatalog,
    Welcome_file="$Hemkatalog/welcome.txt"

    {
      echo "Välkommen $User"
      echo "Följande är alla användare i systemet:"
      cut -d: -f1 /etc/passwd								# Skriva ut alla användarnamn i systemet, ett per rad. -d: för att bestämma en kolon (:) som avgränsare, eftersom information i etc/passwd sparar på detta sättet t.ex (jdoe:x:1001:1000:John Doe,Room 1007:/home/jdoe:/bin/bash). -f1 används för att hämta ut fält nummer 1, vilket motsvarar användarnamnet i filen /etc/passwd
    } > "$Welcome_file"											# Spara följande i Welcome_file.txt

    chown "$User:$User" "$Welcome_file"			# Ändra filägaren på Welcome_file och dess undermappar till användare som precis skapat
    chmod 644 "$Welcome_file"								# Ändra rättigheter till 644, dvs. filägaren kan read och write, grupper kan endast läsa och alla och andra kan endast läsa.

done
