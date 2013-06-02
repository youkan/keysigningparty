#!/usr/bin/ruby -w

# keysigningparty.rb v0.3 (C) guido@demelo.de
# released under no license (it's free!)
# Download from: https://github.com/youkan/keysigningparty
#
# Dieses Script soll Keysigning-Parties leichter machen. Es benötigt
# eine Datei mit den zu verwendenden Schlüsseln und gpg. Es erzeugt 
# eine Markdown-Seite zum einfachen konvertieren und Ausdrucken.
# 
# Beispiel:
# 
# Die Datei keys enthält mehrere Schlüssel jeweils auf einer Zeile
# 1A512361
# 1EB5C816
#
# $ keysigningparty.rb -i keys -o liste.md
# 
# Anschließend kann die Liste in der Datei liste.md konvertiert, 
# gedruckt oder weiter verteilt werden.
#
# pandoc -o liste.html liste.md
# pandoc -o liste.pdf  liste.md
#
# Mit pandoc lassen sich z.B. HTML-Seiten oder PDFs erzeugen. 
# 

require 'optparse'

OptionParser.new do |o|
  o.banner = "Verwendung: keysigningparty.rb -i keys -o liste.md"
  
  o.on('-i KEYFILE', "Datei mit IDs der Schluessel der Teilnehmer") { |filename| $keyfile = filename }
  o.on('-o OUTFILE', "Markdown wird in diese Datei geschrieben") { |filename| $outfile = filename }
  o.on('-h') { puts o; exit }
  o.parse!
end

if $keyfile == nil
  puts "Mit -i KEYFILE eine Liste mit IDs angeben."
  exit 1
end

if $outfile == nil
  puts "Mit -o OUTFILE eine Liste fuer die Ausgabe angeben."
  exit 1
end


keyfile = ""
out = ""
begin
  keyfile = File.open($keyfile, "r") 
rescue Errno::ENOENT => e
  puts "Kann $keyfile nicht oeffnen"
  exit 1
end

begin
  out = File.open($outfile, "w")
rescue Errno::ENOENT => e
  puts "Kann $outfile nicht oeffnen, verwende STDOUT"
  out = STDOUT
end


head = <<'HEADER'
# Keysigning Party

## Vor der Party erledigen

Lege einen Schlüssel für dich an. Lade den Schlüssel auf einen (oder mehrere) Keyserver.

Bring etwas mit, womit du glaubhaft machen kannst, dass du <i>du</i> bist. Einen Ausweis oder Führerschein oder ähnliches.

Schau nach, was der Fingerprint deine Schlüssels ist und schreibe diesen hier auf. Dein Fingerprint:


## Schlüsselliste

Lass dir von anderen Party-Teilnehmern ihre Fingerprints zeigen. Vergleiche sie mit der Liste und mach dir ein Häkchen bei Übereinstimmung. Lass dir auch einen Ausweis oder ähnliches zeigen und markiere dies ebenfalls.

HEADER

foot = <<'FOOTER'

## Nach der Party

Es gibt zwei Möglichkeiten: Du bekommst vom Organisator eine Liste mit Schlüsseln und importierst sie oder du musst die Schlüssel von Keyservern oder Webseiten der Teilnehmer holen.

Überprüfe den Fingerprint der importierten Schlüssel mit dem abgedruckten Fingerprint. Bei Übereinstimmung unterschreibst du den Schlüssel. Nachdem du alle Schlüssel unterschrieben hast synchronisierst du sie mit dem Keyserver (zur Not mailst du sie an die Teilnehmer). Ab jetzt kannst du dir bei diesen Schlüsseln sicher sein, wem sie gehören.
FOOTER


out.puts head

keyfile.each_line { |key| 
  out.puts '> Fingerprint OK?  ID OK?  '
  text = `gpg --fingerprint #{key}`
  text = text.split(/\n/)

  text.shift # Zeile mit keyring weg
  text.shift # Zeile mit "-----" weg
  text.each{|l|
    unless l =~ /^sub/
#      l.gsub!(/_/,'\\_')
      out.puts "> " + l
    end
  }
  out.puts "\n\n"
}

out.puts foot

