#!/bin/bash

# -c			= permet la reprise du dl en cas de coupure de la connexion

# --restrict-filenames	= force l'utilisation de caractères ascii pour les noms de fichiers enregistrés
#			  empêche l'utilisation d'espaces et d'esperluettes

# %(title)s.%(ext)s	= syntaxe de noms de fichiers : titre.extension

# Génération d'un log pour le script.

exec 3>&1 4>&2
[[ -d "${HOME}/log" ]] || mkdir "${HOME}/log"
exec 1>"${HOME}/log/$(basename "$0" .sh).log" 2>&1


dest=$(zenity --file-selection --directory --title "Choose a save destination") && cd "$dest" || exit 1

youtube-dl -c --restrict-filenames -o "$dest"/"%(title)s.%(ext)s" "$1"

notify-send "La vidéo a été téléchargée."
