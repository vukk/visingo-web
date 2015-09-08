% GraphicalModels.asp hs-edge-n0-min-v16.asp
% Postprocessing script

% Pass edge through
_pp(edge(X,Y),S) :- _as(edge(X,Y),S).

% Remove singletons (nodes that are never connected)
% all nodes
nodes(X) :- _as(node(X),_).
% get nodes that are connected
conn(X) :- nodes(X), nodes(Y), _as(edge(X,Y),_).
conn(X) :- nodes(X), nodes(Y), _as(edge(Y,X),_).
% pass through nodes that are connected
_pp(node(X),S) :- _as(node(X),S), conn(X).
_pp(nodeAttr(X,A,B),S) :- _as(nodeAttr(X,A,B),S), conn(X).

% Label nodes and add full question to the node title
nodeAttr(1,label,"IncDiff").
nodeAttr(1,title,"Tuloerot ovat kasvaneet Suomessa 1990-luvun puolivälin jälkeen nopeasti.<br>Miten siihen pitäisi suhtautua?").
nodeAttr(4,label,"ChSup").
nodeAttr(4,title,"Lapsilisää maksetaan jokaisesta Suomessa asuvasta lapsesta 17 ikävuoteen asti riippumatta vanhempien tulotasosta.<br>Mitä lapsilisille pitäisi tehdä?").
nodeAttr(5,label,"Seniors").
nodeAttr(5,title,"Sosiaali- ja terveysministeriössä valmistellaan parhaillaan niin sanottua ikälakia, johon<br> mahdollisesti kirjataan yhtenäisiä ikäihmisten hoidon laatuvaatimuksia ja<br> palvelutakuu.<br>Pitäisikö ikäihmisten hoivatakuu kirjata lakiin ja velvoittaa kunnat tarjoamaan vanhuksille subjektiivinen oikeus hoivaan?").
nodeAttr(6,label,"RetAge").
nodeAttr(6,title,"Vanhuuseläkkeelle siirtymisen ikä on nyt 63–68 vuotta.<br>Eläkeiän alarajaa pitäisi mielestäni ").
nodeAttr(7,label,"LongerW").
nodeAttr(7,title,"Suomalaiset jäävät nykyään eläkkeelle keskimäärin alle 60-vuotiaina. Keskeisin syy <br> ennenaikaiseen eläkkeeseen on työkyvyttömyys. Työssäjaksamisen ja työhyvinvoinnin <br> kehittämisen lisäksi eläkeiän nostamiseksi on esitetty myös muita keinoja.<br> Mitä seuraavista käyttäisit ensisijaisesti työurien pidentämiseksi?").
nodeAttr(9,label,"Cuts").
nodeAttr(9,title,"Vaalien jälkeen valittava hallitus saattaa päättää karsia valtion menoja.<br> Seuraavassa on lueteltu joukko mittaluokaltaan erisuuruisia säästöehdotuksia, joita<br> vaalikeskustelussa on jo esitetty. Minkä näistä valitsisit ensimmäisenä? (Valitse yksi.)").
nodeAttr(11,label,"FinTax").
nodeAttr(11,title,"Finanssikriisin myötä on vauhdittunut keskustelu rahoitusalan verottamisesta ja<br> osallistumisesta kriisin kustannusten maksuun.<br>EU-komissio on esittänyt maailmanlaajuista<br> pörssi- eli transaktioveroa, jolla verotettaisiin joukkovelkakirjalaina-,osake-, valuutta-<br> ja johdannaiskauppoja.<br>Mikä seuraavista väittämistä vastaa parhaiten näkemystäsi?").
nodeAttr(13,label,"TaxBen").
nodeAttr(13,title,"Valtio käyttää verotusta rahan keräämisen lisäksi myös erilaisten yhteiskunnallisten<br> tavoitteiden edistämiseen. Kansalaisten toimintaa voidaan ohjata erilaisilla<br> verohuojennuksilla. Vuonna 2009 näiden verohuojennusten takia valtiolta jäi saamatta 13<br> miljardia euroa. Summa vastaa noin neljännestä valtion budjetista. Verotukiin käytettyä rahaa<br> joudutaan keräämään kiristämällä verotusta toisaalla. Mitä seuraavista verotuista olisit<br> valmis leikkaamaan ensimmäiseksi? (Valitse yksi.)").
nodeAttr(14,label,"AptLTaxB").
nodeAttr(14,title,"Mitä asuntolainojen korkojen verovähennysoikeudelle pitäisi tehdä?").
nodeAttr(15,label,"AgFoTax").
nodeAttr(15,title,"Rakennetusta ja rakentamattomasta tonttimaasta maksetaan kiinteistöveroa.<br> Pitäisikö myös metsä- ja peltomaalle asettaa kiinteistövero?").
nodeAttr(18,label,"FrgnHum").
nodeAttr(18,title,"Pitääkö Suomen tuoda Kiinan- ja Venäjän-politiikassaan voimakkaammin esiin myös ihmisoikeudet<br> sekä demokratian tila kyseisissä maissa?").
nodeAttr(19,label,"RusReEs").
nodeAttr(19,title,"Venäjä kielsi alkuvuodesta ulkomaalaisten maanomistuksen raja-alueiltaan. Suomesta venäläiset<br> voivat ostaa maata ja kiinteistöjä lähes rajoituksetta. Venäläiset ovat ostaneet viime vuosina<br> Suomesta tuhansia kiinteistöjä.<br> Mitä asialle pitäisi tehdä?").
nodeAttr(21,label,"FinInFB").
nodeAttr(21,title,"Jos Suomi olisi Facebookissa, mitkä kolme tässä listatuista maista sen pitäisi ensimmäisenä<br> pyytää ystävikseen? (Valitse kolme.)").
nodeAttr(23,label,"SweReq").
nodeAttr(23,title,"Peruskoulussa on kaksi pakollista vierasta kieltä, joista jommankumman pitää olla toinen<br> kotimainen kieli.<br>Pitäisikö toisen kotimaisen kielen opiskelu muuttaa vapaaehtoiseksi?").
nodeAttr(24,label,"Suvi").
nodeAttr(24,title,"Sopiiko Suvivirren laulaminen koulujen kevätjuhlaan?").
nodeAttr(25,label,"Immi").
nodeAttr(25,title,"Vaalikaudella 2007–2011 Suomen maahanmuuttopolitiikkaa kiristettiin useilla eri päätöksillä.<br> Millaista on mielestäsi Suomen nykyinen maahanmuuttopolitiikka?").



%nodeAttr(1,label,"").
%nodeAttr(1,title,"").

_pp(nodeAttr(X,A,B),1) :- nodeAttr(X,A,B).
