#!/usr/bin/env bash
curl -sS "https://wikimania.wikimedia.org/w/index.php?title=2019:Program&action=raw" \
  | grep -Po "Program item\|title=[^|]+\|\Kdisplayname=([^|]+)\|presenters=([^|}]+)" \
  | sed 's/displayname=//' | sed 's/|presenters=/\t/' \
  > "2019:Program.txt"

rm -rf slides && mkdir -p slides/svg slides/png

cat "2019:Program.txt" | while read -r talk; do
  title=$(echo -n "$talk" | cut -f1)

  # File name tweaks : remove slash, 100 characters maximum
  fileName=${title/\//-}
  fileName=${fileName:0:100}

  # Title tweak : escape ampersand
  title=${title/&/\\&}

  titleLength=${#title}

  speakers=$(echo -n "$talk" | cut -f2)

  cp "Wikimania video - Title slide.svg" "slides/svg/$fileName - front slide.svg"
  sed -i "s#Title#$title#" "slides/svg/$fileName - front slide.svg"
  sed -i "s#Speaker names, and names#$speakers#" "slides/svg/$fileName - front slide.svg"
  if [ $titleLength -gt 65 ]; then
    sed -i "s#y: 20%;#y: 10%;#" "slides/svg/$fileName - front slide.svg"
  elif [ $titleLength -lt 45 ]; then
    sed -i "s#y: 20%;#y: 35%;#" "slides/svg/$fileName - front slide.svg"
  fi

  if [ $titleLength -gt 110 ]; then
    sed -i "s#font-size: 140px;#font-size: 100px;#" "slides/svg/$fileName - front slide.svg"
  elif [ $titleLength -gt 80 ]; then
    sed -i "s#font-size: 140px;#font-size: 120px;#" "slides/svg/$fileName - front slide.svg"
  fi
  ./node_modules/convert-svg-to-png/bin/convert-svg-to-png "slides/svg/$fileName - front slide.svg" && \
  mv "slides/svg/$fileName - front slide.png" "slides/png/$fileName - front slide.png"
done

