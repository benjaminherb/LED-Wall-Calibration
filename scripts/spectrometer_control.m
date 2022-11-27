% list = serialportlist;

OUTPUT_DIR = "./out";

%% Seriellen Port aktivieren
% ein serielles Objekt wird angelegt. Über serialportlist konnte der
% Anschluss identifiziert werden
% Mac: SM = serialport("/dev/cu.usbmodem11301",115200);

SM = serialport("/dev/ttyACM0",115200);

%Damit beim auslesen der Daten nicht vor Abschluss der Messung geendet
%wird, muss das Attribut Timeout auf eine längere Zeit gesetzt werden (30
%sek)
SM.Timeout = 30;

%% Aktivierung des Remote-Modes
%Der Befehl muss als einzelne Chars gesendet werden.
write(SM, 'P',"uint8");
write(SM, 'H',"uint8");
write(SM, 'O',"uint8");
write(SM, 'T',"uint8");
write(SM, 'O',"uint8");

disp("Ich habe den RemoteMode erreicht")

measureIndex = 1;
measure = zeros(17,201);

%% Messung durchführen (Funktioniert vorerst nur bei "Run and Advance")

disp("Ich fang jetzt mal mit messen an")

%Der Befehl M5 sorgt für die für uns am sinnvollste Messung (Return: WL, Spectral
%Data at each WL) (PR670 Manual p. 125)
write(SM, 'M',"uint8");
write(SM, '5',"uint8");

%Zur Eingabe des Befehls muss [CR] ausgeführt werden. Dies ist in der
%Tabelle der "Chars" Eintrag 13, -> sozusagen Neue Zeile
write(SM, char(13),"uint8");


% Nun werden zwei Arrays angelegt. in refWfl werden die Wellenlängen
% eingetragen, in mySPD die Spektralen Daten. Die Arrays werden zunächst
% leer erstellt. 201, da wir wir in 2er Schritten messen und von 380-780 nm
% Messen (-> 400/2=200) und der erste Wert noch die Fehlercode Rückgabe ist
% dieser wird durch readline(SM) verworfen.
refWfl = NaN(201,1);
mySPD = NaN(201,1);

readline(SM) %erster Wert wird verworfen

%Mit der for-schleife werden nun alle werte nach einander abgefragt und in
%mit strsplit auf die richtigen Variablen aufgeteilt.
for i=1:1:201
    disp(i);
    str = strsplit(readline(SM),',');
    str;
    
    refWfl(i,1) = str2num(str(1));
mySPD(i,1) = str2num(str(2));
end

% Alle restlichen Daten werden verworfen
flush(SM)


disp("ich bin fertig mit messen")

%Ausgabe der Grafik
plot(refWfl, mySPD)
%Begrenzung auf 380 - 720 nm
xlim([380,720])

% Messung Speicher

measure(measureIndex,:) = mySPD;
 measureIndex = measureIndex+1;
%% Write to file
%MES_DIR = OUTPUT_DIR + "/MEASUREMENTS/";
%if not(isfolder(MES_DIR))
%    mkdir(MES_DIR)
%end

%output_file = fopen(MES_DIR + 'MEASUREMENTS_RED.csv', 'w');
    
%for i=1:1:201
%    fprintf(output_file, string(refWfl(i)) + ',' + string(mySPD(i)) + '\n\r');
%end


%% Einzelne Werte ausgeben 
%Der x-wert von measure(x,y) ist die X.-Messung
plot(refWfl, measure(1,:))
hold on
plot(refWfl, measure(3,:))
plot(refWfl, measure(7,:))
plot(refWfl, measure(10,:))
plot(refWfl, measure(13,:))
%Begrenzung auf 380 - 720 nm
xlim([380,720])

hold off


refWfl;
%% Remote Mode verlassen und Port schließen
write(SM, 'Q',"uint8");

clear("");



