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
	var ländergrößen : Dictionary[String, Vector2i] = get_ländergrößen()
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
			countries[this_name]["Rect"] = Vector2i.ZERO
		# add to countries_by_region
		var this_region : String = countries[this_name]["Region"]
		if not this_region in countries_by_region.keys():
			countries_by_region[this_region] = {}
		countries_by_region[this_region][this_name] = countries[this_name]

func get_ländergrößen() -> Dictionary[String, Vector2i]:
	var file = LänderGrößenCSV.split("\n", false) #FileAccess.open("res://karten/Ländergrößen.csv.res", FileAccess.READ).get_as_text().split("\n", false)
	var dict : Dictionary[String, Vector2i] = {}
	for row in file:
		var array = row.split(";", false)
		dict[array[0]] = Vector2i(int(array[1]), int(array[2]))
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

const LänderGrößenCSV : String = "Aegypten;1037;451
Aequatorialguinea;956;617
Aethiopien;1082;581
Afghanistan;1229;436
Albanien;1008;384
Algerien;858;469
Andorra;907;381
Angola;969;709
AntiguaBarbuda;572;529
ArabischeEmirate;1183;496
Argentinien;512;914
Armenien;1138;393
Aserbaidschan;1143;400
Australien;1512;756
Bahamas;485;489
Bahrain;1173;481
Barbados;581;552
Belarus;1030;316
Belgien;919;326
Belize;428;528
Benin;909;567
Bhutan;1380;475
Bolivien;533;717
BosnienHerzegowina;989;367
Botswana;1011;746
Brasilien;510;664
Bulgarien;1025;374
BurkinaFaso;876;564
Burundi;1061;641
Chile;498;912
China;1299;403
CostaRica;446;570
Danemark;948;282
DemokratischeRepublikKongo;972;653
Deutschland;937;326
Dominica;573;539
DominikanischeRepublik;520;524
Dschibuti;1128;563
Ecuador;473;631
ElSalvador;424;550
Elfenbeinkueste;860;585
Eritrea;1100;543
Estland;1031;266
Eswatini;1069;770
Falklandinseln;577;929
Fidschi;1850;717
Finnland;1017;181
Frankreich;882;343
FranzGuyana;613;598
GB;859;296
Gabun;953;629
Gambien;814;553
Gaza;1086;452
Georgien;1125;379
Ghana;888;588
Grenada;571;559
Griechenland;1012;400
Gronland;514;84
Guadeloupe;572;537
Guatemala;411;545
Guinea;826;564
GuineaBissau;818;559
Guyana;577;593
Haiti;506;525
Honduras;428;544
Indien;1272;497
Indonesien;1414;596
Irak;1113;440
Iran;1142;402
Irland;852;303
Island;776;210
Israel;1089;448
Italien;942;362
Jamaika;487;525
Japan;1599;440
Jemen;1133;540
Jordanien;1091;460
Jungferninseln;556;525
Kambodscha;1452;553
Kamerun;951;598
Kanada;150;176
KapVerde;760;535
Kasachstan;1155;342
Katar;1176;483
Kenia;1086;625
Kolumbien;483;617
Komoren;1130;686
Kongo;966;646
Kosovo;1012;381
Kroatien;976;364
Kuba;454;502
Kuwait;1156;462
Laos;1441;513
Lesotho;1051;787
Lettland;1017;283
Libanon;1094;437
Liberia;844;586
Libyen;955;459
Liechtenstein;954;352
Litauen;1018;289
Luxemburg;935;334
Madagaskar;1136;744
Malawi;1080;697
Malaysia;1441;591
Mali;840;547
Marokko;815;505
Martinique;574;541
Mauretanien;815;510
Mauritius;1188;738
Mexiko;280;446
Mikronesien;1642;572
Moldau;1051;345
Monaco;940;373
Mongolei;1374;340
Montenegro;1003;379
Montserrat;569;534
Mosambik;1067;707
Myanmar;1398;510
Namibia;968;719
Nauru;1794;627
Nepal;1334;464
Neukaledonien;1781;736
Neuseeland;1791;921
Nicaragua;438;555
Niederlande;927;319
Niger;906;545
Nigeria;920;578
Nordkorea;1571;398
Nordmazedonien;1014;388
Norwegen;930;242
Oman;1183;523
Osterreich;956;351
Osttimor;1566;674
Pakistan;1235;464
Palau;1603;607
Panama;461;575
PapuaNeuguinea;1658;640
Paraguay;571;743
Peru;471;648
Philippinen;1528;582
Polen;981;309
Portugal;856;401
PuertoRico;544;526
Rojava;1100;422
Ruanda;1060;637
Rumanien;1015;360
Russland;1011;299
Salomonen;1741;661
Sambia;1023;695
Samoa;1903;696
SaoTomeUndPrincipe;933;622
SaudiArabien;1091;467
Schweden;965;268
Schweiz;937;355
Senegal;814;545
Serbien;1006;361
Seychellen;1139;661
SierraLeone;835;577
Simbabwe;1041;723
Slowakei;996;343
Slowenien;976;358
Somalia;1124;611
Somaliland;1133;568
Spanien;856;379
StKittsNevis;566;531
StLucia;575;546
StVincentGrenadinen;574;551
Sudan;1023;554
Sudkorea;1581;427
Suedafrika;994;782
Suedsudan;1034;578
Suriname;594;602
Syrien;1097;425
Tadschikistan;1266;402
Taiwan;1546;495
Tansania;1062;650
Thailand;1426;524
Togo;905;567
Tonga;1888;711
TrinidadTobago;570;568
Tschad;976;548
Tschechien;971;331
Tunesien;945;436
Turkei;1045;392
Turkmenistan;1191;399
Tuvalu;1855;666
USA;9;211
Uganda;1063;627
Ukraine;1024;343
Ungarn;993;351
Uruguay;593;806
Usbekistan;1205;368
Vanuatu;1789;682
Venezuela;513;574
Vietnam;1450;503
WestSahara;827;505
ZentralafrikanischeRepublik;983;592
Zypern;1077;430
"
