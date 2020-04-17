#! /bin/bash

# Criando as pastas
echo "Digite o nome do cliente:"
read name
echo "Nome: $name"

mkdir $name
mkdir -p $name/data/raw
mkdir $name/data/processed
mkdir $name/docs
mkdir -p $name/output/figures
mkdir $name/output/tables
mkdir $name/R
sleep 1
echo "Pastas criadas!"

sleep 0.5
echo "Criando o Projeto $name.Rproj..."
PROJFILE="$name.Rproj"
cat > $name/$PROJFILE << EOF
Version: 1.0
RestoreWorkspace: Default
SaveWorkspace: Default
AlwaysSaveHistory: Default
EnableCodeIndexing: Yes
UseSpacesForTab: No
NumSpacesForTab: 4
Encoding: UTF-8
RnwWeave: Sweave
LaTeX: pdfLaTeX
AutoAppendNewline: Yes
StripTrailingWhitespace: Yes
EOF
sleep 1
echo "Projeto $PROJFILE criado!"

sleep 0.5
echo "Criando script principal..."
touch $name/R/main.R
sleep 1
echo "Arquivo '$name/R/main.R' criado!"

sleep 0.5
echo "Abrindo o novo projeto..."
sleep 1
xdg-open $name/$PROJFILE

