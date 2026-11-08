extends Node

const REGION_LIST : Dictionary[String, Array] = {
	"Afrika": ["Westafrika", "Ostafrika", "Sahara", "Südafrika", "Zentralafrika"],
	"Europa": ["Westeuropa", "Osteuropa"],
	"Amerika": ["Nordamerika", "Karibik", "Sudamerika"],
	"Ozeanien": [],
	"Asien": ["Ostasien", "Himalaya", "Orient"]
}

var countries : Dictionary = {}
var countries_by_region : Dictionary = {}
var language : String = "German"

var selected_regions_big : Dictionary[String, bool] = {
	"Afrika": true,
	"Europa": true,
	"Amerika": true,
	"Ozeanien": true,
	"Asien": true
}

var selected_regions_small : Dictionary[String, bool] = {
	"Westafrika": true,
	"Ostafrika": true,
	"Sahara": true,
	"Südafrika": true,
	"Zentralafrika": true,
	"Westeuropa": true,
	"Osteuropa": true,
	"Nordamerika": true,
	"Karibik": false,
	"Sudamerika": true,
	"Ozeanien": true,
	"Ostasien": true,
	"Himalaya": true,
	"Orient": true
}

func _ready() -> void:
	load_country_list()

func get_countries_in_regions(regions : Array[String]) -> Array[String]:
	var allowed_countries : Array[String] = []
	for country in countries.keys():
		if countries[country]["Region"] in regions:
			allowed_countries.append(country)
	return allowed_countries

func get_country_name(load_country_name : String) -> String:
	if countries.has(load_country_name) and countries[load_country_name].has(language):
		return countries[load_country_name][language]
	else:
		return load_country_name

func load_country_list() -> void:
	var file = LänderCSV #FileAccess.open("res://karten/Länder.csv.res", FileAccess.READ).get_as_text()
	var file_text : PackedStringArray = file.split("\n", false)
	var ländergrößen : Dictionary[String, Rect2i] = get_ländergrößen()
	var keys = file_text[0].split(";")
	file_text.remove_at(0)
	countries = {}
	countries_by_region = {}
	for row in file_text:
		var row_split = row.split(";", true)
		var this_name : String = row_split[0]
		countries[this_name] = {}
		for i in range(1,len(keys)):
			if keys[i] != "Neighbors":
				countries[this_name][keys[i]] = row_split[i]
			else:
				countries[this_name][keys[i]] = Array(row_split[i].split(","))
		# add ländergrößen
		if this_name in ländergrößen.keys():
			countries[this_name]["Rect"] = ländergrößen[this_name]
		else:
			print("ERROR in Global.load_country_list: Country named ", this_name, " has no Ländergröße")
			countries[this_name]["Rect"] = Rect2i(0,0,0,0)
		# add to countries_by_region
		var this_region : String = countries[this_name]["Region"]
		if not this_region in countries_by_region.keys():
			countries_by_region[this_region] = {}
		countries_by_region[this_region][this_name] = countries[this_name]

func get_ländergrößen() -> Dictionary[String, Rect2i]:
	var file = LänderGrößenCSV.split("\n", false) #FileAccess.open("res://karten/Ländergrößen.csv.res", FileAccess.READ).get_as_text().split("\n", false)
	var dict : Dictionary[String, Rect2i] = {}
	for row in file:
		var array : Array = row.split(";", false)
		var rect_array : Array = array[1].split(",", false)
		if len(rect_array) == 4:
			dict[array[0]] = Rect2i(int(rect_array[0]), int(rect_array[1]), int(rect_array[2]), int(rect_array[3]))
		else:
			print("ERROR in Global.gd.get_ländergrößen: ", array, " too long or short")
	return dict

func wait(wait_time: float = 1.0) -> void:
	if wait_time > 0:
		await await get_tree().create_timer(wait_time).timeout
		return
	else:
		await get_tree().process_frame
		return

const LänderCSV : String = "Key;German;Region;Neighbors
Aegypten;Ägypten;Sahara;Libyen,Israel,Sudan,Gaza
Aequatorialguinea;Äquatorialguinea;Ostafrika;Gabun,Kamerun
Aethiopien;Äqthiopien;Westafrika;Eritrea,Somaliland,Somalia,Kenia,Suedsudan,Sudan,Dschibuti
Afghanistan;Afghanistan;Ostasien;Pakistan,Iran,Turkmenistan,Usbekistan,Tadschikistan
Albanien;Albanien;Osteuropa;Montenegro,Kosovo,Nordmazedonien,Griechenland
Algerien;Algerien;Sahara;Tunesien,Libyen,Niger,Mali,Mauretanien,Marokko
Andorra;Andorra;Westeuropa;Spanien,Frankreich
Angola;Angola;Sudafrika;DemokratischeRepublikKongo,Kongo,Sambia,Namibia
Anguilla;Anguilla;;
AntiguaBarbuda;Antigua und Barbuda;Karibik;
ArabischeEmirate;Vereinigte Arabische Emirate;Orient;SaudiArabien,Oman
Argentinien;Argentinien;Sudamerika;Chile,Bolivien,Paraguay,Uruguay,Brasilien
Armenien;Armenien;Orient;Iran,Aserbaidschan,Turkei,Georgien
Aruba;Aruba;Karibik;
Aserbaidschan;Aserbaidschan;Orient;Armenien,Georgien,Russland,Iran
AshoreCartierinseln;Ashore und Cartierinseln;Ozeanien;
Australien;Australien;Ozeanien;
Bahamas;Bahamas;Karibik;
Bahrain;Bahrain;Orient;SaudiArabien,Katar
Bangladesch;Bangladesch;Ostasien;Indien,Myanmar
Barbados;Barbados;Karibik;
Belarus;Belarus;Osteuropa;Russland,Lettland,Litauen,Polen,Ukraine
Belgien;Belgien;Westeuropa;Niederlande,Deutschland,Luxemburg,Frankreich
Belize;Belize;Karibik;Guatemala,Mexiko
Benin;Benin;Ostafrika;Nigeria,Niger,BurkinaFaso,Togo
Bermuda;Bermuda;Nordamerika;
Bhutan;Bhutan;Ostasien;Indien,China
Bolivien;Bolivien;Sudamerika;Brasilien,Paraguay,Argentinien,Chile,Peru
BosnienHerzegowina;Bosnien-Herzegowina;Osteuropa;Kroatien,Serbien,Montenegro
Botswana;Botswana;Südafrika;Namibia,Simbabwe,Suedafrika
Brasilien;Brasilien;Sudamerika;FranzGuyana,Guyana,Venezuela,Suriname,Kolumbien,Peru,Bolivien,Paraguay,Uruguay,Argentinien
Brunei;Brunai;Ostasien;Malaysia
Bulgarien;Bulgarien;Osteuropa;Rumanien,Serbien,Nordmazedonien,Griechenland,Turkei
BurkinaFaso;Burkina Faso;Sahara;Benin,Togo,Ghana,Elfenbeinkueste,Mali,Niger
Burundi;Burundi;Zentralafrika;DemokratischeRepublikKongo,Ruanda,Tansania
Chile;Chile;Sudamerika;Peru,Bolivien,Argentinien
China;China;Ostasien;Bhutan,Indien,Kirgisistan,Laos,Myanmar,Nepal,Nordkorea,Russland,Tadschikistan,Vietnam,Mongolei,Kasachstan
Cookinseln;Cook-Inseln;;
CostaRica;Costa Rica;Karibik;Nicaragua,Panama
Danemark;Danemark;Westeuropa;Schweden,Deutschland
DemokratischeRepublikKongo;Demokratische Republik Kongo;Zentralafrika;Suedsudan,Uganda,Ruanda,Tansania,ZentralafrikanischeRepublik,Kongo,Angola,Sambia,Burundi
Deutschland;Deutschland;Westeuropa;Danemark,Polen,Tschechien,Osterreich,Schweiz,Frankreich,Luxemburg,Belgien,Niederlande
Dominica;Dominica;Karibik;
DominikanischeRepublik;DominikanischeRepublik;Karibik;
Dschibuti;Dschibuti;Westafrika;Eritrea,Aethiopien,Somaliland
Ecuador;Ecuador;Sudamerika;Kolumbien,Peru
Elfenbeinkueste;Elfenbeinküste;Ostafrika;Ghana,BurkinaFaso,Mali,Guinea,Liberia
ElSalvador;El Salvador;Karibik;Honduras,Guatemala
Eritrea;Eritrea;Westafrika;Dschibuti,Aethiopien,Sudan
Estland;Estland;Osteuropa;Russland,Lettland
Eswatini;Eswatini;Südafrika;Suedafrika,Mosambik
Falklandinseln;Falklandinseln;Sudamerika;
Faroer;Färöer-Inseln;Europa;
Fidschi;Fidschi;Ozeanien;
Finnland;Finnland;Westeuropa;Norwegen,Schweden,Russland
Frankreich;Frankreich;Westeuropa;Belgien,Luxemburg,Deutschland,Schweiz,Italien,Andorra,Spanien,Monaco
FranzGuyana;Französisch-Guyana;Sudamerika;Suriname,Brasilien
FranzPolynesien;Französch-Polynesien;Ozeanien;
Gabun;Gabun;Ostafrika;Aequatorialguinea,Kongo,Kamerun
Galapagos;Galapagos-Inseln;Sudamerika;
Gambien;Gambien;Ostafrika;Senegal
Gaza;Gaza;Orient;Israel,Aegypten
GB;GB;Westeuropa;Irland
Georgien;Georgien;Orient;Russland,Turkei,Armenien,Aserbaidschan
Ghana;Ghana;Ostafrika;Togo,BurkinaFaso,Elfenbeinkueste
Gibraltar;Gibraltar;Europa;
Grenada;Grenada;Karibik;
Griechenland;Griechenland;Osteuropa;Turkei,Bulgarien,Nordmazedonien,Albanien
Gronland;Grönland;Westeuropa;
Guadeloupe;Guadeloupe;Karibik;
Guatemala;Guatemala;Karibik;Mexiko,Belize,ElSalvador,Honduras
Guinea;Guinea;Ostafrika;Mali,GuineaBissau,Senegal,SierraLeone,Liberia,Elfenbeinkueste
GuineaBissau;Guinea-Bissau;Ostafrika;Guinea,Senegal
Guyana;Guyana;Sudamerika;Venezuela,Brasilien,Suriname
Haiti;Haiti;Karibik;
HeardMyCDonaldinseln; Heard und McDonaldinseln;Karibik;
Honduras;Honduras;Karibik;Guatemala,ElSalvador,Nicaragua
Indien;Indien;Ostasien;Pakistan,China,Nepal,Myanmar,Bangladesch,Bhutan
Indonesien;Indonesien;Ostasien;Malaysia,Osttimor,PapuaNeuguinea
Irak;Irak;Orient;Iran,Kuwait,SaudiArabien,Jordanien,Syrien,Turkei,Rojava
Iran;Iran;Orient;Aserbaidschan,Armenien,Turkei,Irak,Pakistan,Afghanistan,Turkmenistan
Irland;Irland;Westeuropa;GB
Island;Island;Westeuropa;
Israel;Israel;Orient;Gaza,Libanon,Syrien,Jordanien,Aegypten
Italien;Italien;Westeuropa;Frankreich,Schweiz,Osterreich,Slowenien,Monaco
Jamaika;Jamaika;Karibik;
Japan;Japan;Ostasien;
Jemen;Jemen;Orient;Oman,SaudiArabien
Jordanien;Jordanien;Orient;Israel,Syrien,Irak,SaudiArabien
Jungferninseln;Jungferninseln;Karibik;
Kaimaninseln;Kaimaninseln;Karibik;
Kambodscha;Kambodscha;Ostasien;Thailand,Laos,Vietnam
Kamerun;Kamerun;Ostafrika;ZentralafrikanischeRepublik,Tschad,Nigeria,Gabun,Kongo,Aequatorialguinea
Kanada;Kanada;Nordamerika;USA
KapVerde;Kap Verde;Ostafrika;
Kasachstan;Kasachstan;Himalaya;Kirgisistan,Russland,China,Usbekistan,Turkmenistan
Katar;Katar;Orient;SaudiArabien,Bahrain
Kenia;Kenia;Westafrika;Somalia,Aethiopien,Suedsudan,Uganda,Tansania
Kirgisistan;Kirgistan;Ostasien;Kasachstan,Usbekistan,Tadschikistan,China
Kiribati;Kiribati;Ozeanien;
Kolumbien;Kolumbien;Südamerika;Panama,Venezuela,Brasilien,Ecuador,Peru
Komoren;Komoren;Westafrika;
Kongo;Kongo;Ostafrika;DemokratischeRepublikKongo,ZentralafrikanischeRepublik,Kamerun,Gabun,Angola
Kosovo;Kosovo;Osteuropa;Serbien,Nordmazedonien,Albanien,Montenegro
Kroatien;Kroatien;Osteuropa;Slowenien,Ungarn,Serbien,BosnienHerzegowina
Kuba;Kuba;Karibik;
Kuwait;Kuwait;Orient;Irak,SaudiArabien
Laos;Laos;Ostasien;Thailand,China,Vietnam,Kambodscha,Myanmar
Lesotho;Lesotho;Südafrika;Suedafrika
Lettland;Lettland;Osteuropa;Russland,Estland,Belarus,Litauen
Libanon;Libanon;Orient;Syrien,Israel
Liberia;Liberia;Ostafrika;Elfenbeinkueste,Guinea,SierraLeone
Libyen;Libyen;Sahara;Algerien,Tunesien,Aegypten,Sudan,Tschad,Niger
Liechtenstein;Liechtenstein;Westeuropa;Schweiz,Osterreich
Litauen;Litauen;Osteuropa;Lettland,Belarus,Russland,Polen
Luxemburg;Luxemburg;Westeuropa;Belgien,Deutschland,Frankreich
Madagaskar;Madagaskar;Sudafrika;
Malawi;Malawi;Sudafrika;Tansania,Mosambik,Sambia
Malaysia;Malaysia;Ostasien;Thailand,Indonesien,Brunei
Malediven;Malediven;Ostasien;
Mali;Mali;Sahara;Algerien,Mauretanien,Niger,Senegal,Guinea,Elfenbeinkueste,BurkinaFaso
Man;Insel Man;Europa;
Marokko;Marokko;Sahara;Westsahara,Algerien,Mauretanien
Marshallinseln;Marshallinseln;Ozeanien;
Martinique;Martinique;Karibik;
Mauretanien;Mauretanien;Sahara;Mali,Algerien,Westsahara,Senegal,Mali,Marokko
Mauritius;Mauritius;Sudafrika;
Mexiko;Mexiko;Nordamerika;USA,Guatemala,Belize
Mikronesien;Mikronesien;Ozeanien;
Moldau;Moldau;Osteuropa;Ukraine,Rumanien
Monaco;Monaco;Westeuropa;Frankreich,Italien
Mongolei;Mongolei;Ostasien;Russland,China
Montenegro;Montenegro;Osteuropa;Kosovo,Albanien,BosnienHerzegowina,Serbien
Montserrat;Montserrat;Karibik;
Mosambik;Mosambik;Sudafrika;Tansania,Malawi,Sambia,Simbabwe,Suedafrika,Eswatini
Myanmar;Myanmar;Ostasien;Indien,Bangladesch,Thailand,Laos,China
Namibia;Namibia;Sudafrika;Angola,Botswana,Sambia,Suedafrika
Nauru;Nauru;Ozeanien;
Nepal;Nepal;Ostasien;Indien,China
Neukaledonien;Neukaledonien;Ozeanien;
Neuseeland;Neuseeland;Ozeanien;
Nicaragua;Nicaragua;Karibik;Honduras,CostaRica
Niederlande;Niederlande;Westeuropa;Deutschland,Belgien
Niger;Niger;Sahara;Libyen,Tschad,Nigeria,Benin,BurkinaFaso,Mali,Algerien
Nigeria;Nigeria;Ostafrika;Kamerun,Tschad,Niger,Benin
Niue;Niue;Ozeanien;
Nordkorea;Nordkorea;Ostasien;China,Sudkorea
NordlicheMarianen;Nördliche Marianen ;Ozeanien;
Nordmazedonien;Nordmazedonien;Osteuropa;Kosovo,Serbien,Bulgarien,Griechenland,Albanien
Norfolkinsel;Norfolkinsel;Ozeanien;
Norwegen;Norwegen;Westeuropa;Schweden,Finnland
Oman;Oman;Orient;ArabischeEmirate,SaudiArabien,Jemen
Osterreich;Osterreich;Westeuropa;Deutschland,Liechtenstein,Italien,Tschechien,Schweiz,Slowakei,Ungarn,Slowenien
Osttimor;Timor-Leste;Ostasien;Indonesien
Pakistan;Pakistan;Ostasien;Indien,Iran,Afghanistan
Palau;Palau;Ozeanien;
Palau;Palau;Ozeanien;
Panama;Panama;Karibik;CostaRica,Kolumbien
PapuaNeuguinea;Papua-Neuguinea;Ostasien;Indonesien
Paraguay;Paraguay;Sudamerika;Brasilien,Argentinien,Bolivien
Peru;Peru;Sudamerika;Ecuador,Kolumbien,Brasilien,Bolivien,Chile
Philippinen;Philippinen;Ostasien;
Polen;Polen;Osteuropa;Russland,Litauen,Belarus,Ukraine,Slowakei,Tschechien,Deutschland
Portugal;Portugal;Westeuropa;Spanien
PuertoRico;Puerto Rico;Karibik;
Rojava;Rojava;Orient;Syrien,Irak,Turkei
Ruanda;Ruanda;Zentralafrika;DemokratischeRepublikKongo,Burundi,Uganda,Tansania
Rumanien;Rumanien;Osteuropa;Moldau,Ukraine,Bulgarien,Serbien,Ungarn
Russland;Russland;Osteuropa;Finnland,Estland,Lettland,Litauen,Belarus,Ukraine,Aserbaidschan,Georgien,China,Mongolei,Kasachstan,Mongolei,Polen
Salomonen;Salomonen;Ozeanien;
Sambia;Sambia;Zentralafrika;DemokratischeRepublikKongo,Angola,Namibia,Simbabwe,Mosambik,Malawi,Tansania
Samoa;Samoa;Ozeanien;
Samoa;Samoa;Ozeanien;
SaoTomeUndPrincipe;Sao Tome Und Principe;Ostafrika;
SaudiArabien;Saudi-Arabien;Orient;Jordanien,Irak,Kuwait,Katar,ArabischeEmirate,Katar,Jemen,Oman,Bahrain
Schweden;Schweden;Westeuropa;Norwegen,Danemark,Finnland
Schweiz;Schweiz;Westeuropa;Deutschland,Frankreich,Liechtenstein,Frankreich,Italien,Osterreich
Senegal;Senegal;Ostafrika;Gambien,Mauretanien,Mali,Guinea,GuineaBissau
Serbien;Serbien;Osteuropa;Ungarn,Rumanien,Bulgarien,Nordmazedonien,Kosovo,Montenegro,BosnienHerzegowina,Kroatien
Seychellen;Seychellen;Südafrika;
SierraLeone;Sierra Leone;Ostafrika;Liberia,Guinea
Simbabwe;Simbabwe;Sudafrika;Sambia,Botswana,Suedafrika,Mosambik
Slowakei;Slowakei;Osteuropa;Polen,Tschechien,Osterreich,Ungarn,Ukraine
Slowenien;Slowenien;Osteuropa;Italien,Osterreich,Kroatien,Ungarn
Somalia;Somalia;Westafrika;Somaliland,Aethiopien,Kenia
Somaliland;Somaliland;Westafrika;Somalia,Aethiopien,Dschibuti
Spanien;Spanien;Westeuropa;Portugal,Andorra,Frankreich
Spitzbergen;Spitzbergen;Europa;
SriLanka;Sri Lanka;Ostasien;
StKittsNevis;St. Kitts und Nevis;Karibik;
StLucia;St. Lucia;Karibik;
StVincentGrenadinen;St. Vincent und Grenadinen;Karibik;
Sudan;Sudan;Sahara;Aegypten,Libyen,Tschad,ZentralafrikanischeRepublik,Suedsudan,Eritrea,Aethiopien
Sudkorea;Südkorea;Ostasien;Nordkorea
Suedafrika;Südafrika;Südafrika;Lesotho,Eswatini,Mosambik,Namibia,Botswana,Simbabwe
Suedsudan;Südsudan;Zentralafrika;Sudan,Aethiopien,Kenia,Uganda,ZentralafrikanischeRepublik,DemokratischeRepublikKongo
Suriname;Suriname;Sudamerika;Guyana,FranzGuyana,Brasilien
Syrien;Syrien;Orient;Turkei,Rojava,Libanon,Israel,Jordanien,Irak
Tadschikistan;Tadschikistan;Ostasien;Usbekistan,Kirgisistan,China,Afghanistan
Taiwan;Taiwan;Ostasien;
Tansania;Tansania;Westafrika;DemokratischeRepublikKongo,Kenia,Ruanda,Burundi,Sambia,Malawi,Mosambik
Thailand;Thailand;Ostasien;Myanmar,Malaysia,Laos,Kambodscha
Togo;Togo;Ostafrika;Benin,BurkinaFaso,Ghana
Tokelau;Tokelau;Ozeanien;
Tonga;Tonga;Ozeanien;
TrinidadTobago;Trinidad und Tobago;Karibik;Venezuela
Tschad;Tschad;Sahara;ZentralafrikanischeRepublik,Sudan,Libyen,Niger,Nigeria,Kamerun
Tschechien;Tschechien;Osteuropa;Polen,Deutschland,Osterreich,Slowakei
Tunesien;Tunesien;Sahara;Algerien,Libyen
Turkei;Turkei;Orient;Bulgarien,Griechenland,Georgien,Armenien,Iran,Irak,Syrien,Rojava
Turkmenistan;Turkmenistan;Ostasien;Kasachstan,Iran,Afghanistan,Usbekistan
Turks;Turks- und Caicosinseln;Ozeanien;
Tuvalu;Tuvalu;Ozeanien;
Uganda;Uganda;Zentralafrika;DemokratischeRepublikKongo,Suedsudan,Kenia,Ruanda
Ukraine;Ukraine;Osteuropa;Russland,Moldau,Rumanien,Ungarn,Slowakei,Polen,Belarus
Ungarn;Ungarn;Osteuropa;Slowakei,Ukraine,Rumanien,Serbien,Kroatien,Slowenien,Osterreich
Ungarn;Ungarn;Osteuropa;Rumanien,Serbien,Kroatien,Slowenien,Osterreich,Slowakei,Ukraine
Uruguay;Uruguay;Sudamerika;Brasilien,Argentinien
USA;USA;Nordamerika;Kanada,Mexiko
Usbekistan;Usbekistan;Ostasien;Kasachstan,Turkmenistan,Afghanistan,Tadschikistan,Kirgisistan
Vanuatu;Vanuatu;Ozeanien;
Venezuela;Venezuela;Sudamerika;Kolumbien,TrinidadTobago,Guyana,Brasilien
Vietnam;Vietnam;Ostasien;China,Laos,Kambodscha
WallisFutuna;Wallis und Futuna;Ozeanien;
Weihnachtsinsel;Weihnachtsinsel;Ozeanien;
Westsahara;West-Sahara;Sahara;Marokko,Mauretanien
ZentralafrikanischeRepublik;Zentralafrikanische Republik;Zentralafrika;DemokratischeRepublikKongo,Suedsudan,Tschad,Sudan,Kamerun,Kongo
Zypern;Zypern;Osteuropa;
Curacao;Curaçao;Ozeanien;
"

const LänderGrößenCSV : String = "Aegypten;1037,451,60,54
Aequatorialguinea;956,614,8,5
Aethiopien;1082,548,75,57
Afghanistan;1229,410,58,53
Albanien;1008,383,8,16
Algerien;858,419,109,103
Andorra;907,380,4,4
Angola;969,657,62,65
Anguilla;564,525,5,4
AntiguaBarbuda;572,528,4,7
ArabischeEmirate;1183,484,22,17
Argentinien;512,745,104,210
Armenien;1138,392,16,14
Aruba;529,556,3,6
Aserbaidschan;1143,387,28,21
AshoreCartierinseln;1554,690,8,10
Australien;1512,684,212,188
Bahamas;485,487,6,10
Bahrain;1173,480,4,5
Bangladesch;1376,481,22,28
Barbados;581,550,8,7
Belarus;1030,290,48,32
Belgien;919,323,17,13
Belize;428,527,3,10
Benin;909,559,14,31
Bermuda;553,442,8,10
Bhutan;1380,471,14,7
Bolivien;533,679,62,69
BosnienHerzegowina;989,367,18,14
Botswana;1011,723,47,48
Brasilien;510,599,206,210
Brunei;1514,598,7,6
Bulgarien;1025,373,29,18
BurkinaFaso;876,545,40,27
Burundi;1061,638,7,10
Chile;498,724,47,232
China;1299,309,325,200
Cookinseln;91,713,17,9
CostaRica;446,566,14,12
Curacao;532,556,6,6
Danemark;948,276,23,21
DemokratischeRepublikKongo;972,598,98,94
Deutschland;937,298,47,52
Dominica;573,537,6,5
DominikanischeRepublik;520,517,17,11
Dschibuti;1128,558,6,7
Ecuador;473,620,27,31
ElSalvador;424,549,10,4
Elfenbeinkueste;860,570,30,30
Eritrea;1100,530,32,28
Estland;1031,263,21,14
Eswatini;1069,767,7,8
Falklandinseln;577,925,16,8
Faroer;864,239,7,8
Fidschi;1850,711,28,30
Finnland;1017,172,55,86
Frankreich;882,327,73,64
FranzGuyana;613,596,14,17
FranzPolynesien;124,671,53,68
GB;859,251,54,79
Gabun;953,613,27,31
Galapagos;410,621,19,13
Gambien;814,551,17,3
Gaza;1086,451,4,4
Georgien;1125,379,26,13
Ghana;888,567,20,31
Gibraltar;872,419,6,6
Grenada;571,557,7,7
Griechenland;1012,388,34,43
Gronland;514,17,328,242
Guadeloupe;572,535,5,4
Guatemala;411,529,18,21
Guinea;826,558,35,27
GuineaBissau;818,558,12,5
Guyana;577,581,23,37
Haiti;506,518,15,10
HeardMyCDonaldinseln;1293,937,8,4
Honduras;428,540,27,14
Indien;1272,428,151,152
Indonesien;1414,595,243,90
Irak;1113,417,47,47
Iran;1142,402,98,85
Irland;852,301,18,20
Island;776,206,54,24
Israel;1089,440,7,20
Italien;942,345,56,74
Jamaika;487,525,8,4
Japan;1599,365,82,86
Jemen;1133,524,53,33
Jordanien;1091,441,22,23
Jungferninseln;556,524,5,8
Kaimaninseln;466,516,9,9
Kambodscha;1452,548,27,20
Kamerun;951,562,38,52
Kanada;150,25,455,363
KapVerde;760,523,31,30
Kasachstan;1155,295,213,99
Katar;1176,482,5,9
Kenia;1086,597,40,52
Kirgisistan;1281,380,50,23
Kiribati;1800,634,100,38
Kolumbien;483,562,61,77
Komoren;1130,679,21,21
Kongo;966,606,36,44
Kosovo;1012,379,8,6
Kroatien;976,357,30,24
Kuba;454,501,52,16
Kuwait;1156,460,6,8
Laos;1441,504,37,43
Lesotho;1051,784,9,8
Lettland;1017,274,36,17
Libanon;1094,433,6,7
Liberia;844,580,20,21
Libyen;955,443,82,75
Liechtenstein;954,350,6,6
Litauen;1018,288,27,17
Luxemburg;935,333,4,4
Madagaskar;1136,692,37,72
Malawi;1080,678,15,36
Malaysia;1441,591,80,29
Malediven;1289,577,13,33
Mali;840,489,85,80
Man;876,300,6,6
Marokko;815,426,81,81
Marshallinseln;1804,583,21,13
Martinique;574,540,5,4
Mauretanien;815,477,59,68
Mauritius;1188,726,37,23
Mexiko;280,446,159,98
Mikronesien;1642,571,137,27
Moldau;1051,345,12,16
Monaco;940,371,6,6
Mongolei;1374,320,170,68
Montenegro;1003,377,8,10
Montserrat;569,533,4,4
Mosambik;1067,683,54,88
Myanmar;1398,471,43,95
Namibia;968,718,70,65
Nauru;1794,626,7,5
Nepal;1334,458,41,22
Neukaledonien;1781,734,24,17
Neuseeland;1791,815,97,109
Nicaragua;438,546,20,19
Niederlande;927,308,18,16
Niger;906,499,82,60
Nigeria;920,552,61,49
Niue;1893,721,10,10
Nordkorea;1571,385,28,26
NordlicheMarianen;1676,519,13,33
Nordmazedonien;1014,385,12,10
Norfolkinsel;1798,778,14,17
Norwegen;930,161,138,112
Oman;1183,491,40,42
Osterreich;956,341,38,16
Osttimor;1566,669,19,8
Pakistan;1235,419,81,75
Palau;1603,582,24,29
Panama;461,575,29,10
PapuaNeuguinea;1658,638,79,42
Paraguay;571,730,41,45
Peru;471,628,64,95
Philippinen;1528,520,53,75
Polen;981,299,50,40
Portugal;856,386,13,31
PuertoRico;544,525,10,3
Rojava;1100,417,30,14
Ruanda;1060,632,9,7
Rumanien;1015,346,42,28
Russland;1011,91,905,300
Salomonen;1741,660,58,30
Sambia;1023,670,59,52
Samoa;1903,695,14,9
SaoTomeUndPrincipe;933,604,23,30
SaudiArabien;1091,449,109,84
Schweden;965,181,66,113
Schweiz;937,349,21,12
Senegal;814,536,28,22
Serbien;1006,360,19,24
Seychellen;1139,634,85,48
SierraLeone;835,573,11,13
Simbabwe;1041,710,38,35
Slowakei;996,338,27,9
Slowenien;976,355,16,8
Somalia;1124,562,53,69
Somaliland;1133,566,32,15
Spanien;856,376,72,47
Spitzbergen;963,60,85,42
SriLanka;1332,575,8,17
StKittsNevis;566,530,5,4
StLucia;575,545,7,4
StVincentGrenadinen;574,549,8,9
Sudan;1023,506,85,72
Sudkorea;1581,411,15,20
Suedafrika;994,747,85,71
Suedsudan;1034,561,56,43
Suriname;594,594,21,20
Syrien;1097,422,26,23
Tadschikistan;1266,394,38,25
Taiwan;1546,488,10,16
Tansania;1062,631,56,56
Thailand;1426,515,42,79
Togo;905,567,7,24
Tokelau;1911,673,5,5
Tonga;1888,710,13,34
TrinidadTobago;570,563,12,9
Tschad;976,499,55,84
Tschechien;971,327,31,15
Tunesien;945,418,20,39
Turkei;1045,387,97,36
Turkmenistan;1191,384,68,44
Turks;516,504,7,5
Tuvalu;1855,661,8,14
USA;9,160,535,361
Uganda;1063,604,27,27
Ukraine;1024,318,93,52
Ungarn;993,345,31,16
Uruguay;593,792,25,27
Usbekistan;1205,365,87,51
Vanuatu;1789,681,25,57
Venezuela;513,564,70,57
Vietnam;1450,500,38,78
WallisFutuna;1871,693,19,12
Weihnachtsinsel;1466,680,4,3
Westsahara;827,477,30,31
ZentralafrikanischeRepublik;983,567,66,41
Zypern;1077,425,12,8
"
