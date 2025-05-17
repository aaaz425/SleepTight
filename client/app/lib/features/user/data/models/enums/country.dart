enum Country {
  // enum 멤버 이름은 lowerCamelCase로 작성합니다.
  // (영어 국가명, 한국어 국가명) 순서로 생성자에 전달합니다.
  ghana('Ghana', '가나', 'GH'),
  gabon('Gabon', '가봉', 'GA'),
  guyana('Guyana', '가이아나', 'GY'),
  gambia('Gambia', '감비아', 'GM'),
  guernsey('Guernsey', '건지섬', 'GG'),
  guadeloupe('Guadeloupe', '과들루프', 'GP'),
  guatemala('Guatemala', '과테말라', 'GT'),
  guam('Guam', '괌', 'GU'),
  grenada('Grenada', '그레나다', 'GD'),
  greece('Greece', '그리스', 'GR'),
  greenland('Greenland', '그린란드', 'GL'),
  guinea('Guinea', '기니', 'GN'),
  guineaBissau('Guinea-Bissau', '기니비사우', 'GW'),
  namibia('Namibia', '나미비아', 'NA'),
  nauru('Nauru', '나우루', 'NR'),
  nigeria('Nigeria', '나이지리아', 'NG'),
  antarctica('Antarctica', '남극', 'AQ'),
  southSudan('South Sudan', '남수단', 'SS'),
  southAfrica('South Africa', '남아프리카 공화국', 'ZA'),
  netherlands('Netherlands', '네덜란드', 'NL'),
  nepal('Nepal', '네팔', 'NP'),
  norway('Norway', '노르웨이', 'NO'),
  norfolkIsland('Norfolk Island', '노퍽섬', 'NF'),
  newCaledonia('New Caledonia', '누벨칼레도니', 'NC'),
  newZealand('New Zealand', '뉴질랜드', 'NZ'),
  niue('Niue', '니우에', 'NU'),
  niger('Niger', '니제르', 'NE'),
  nicaragua('Nicaragua', '니카라과', 'NI'),
  southKorea('South Korea', '대한민국', 'KR'),
  denmark('Denmark', '덴마크', 'DK'),
  dominicanRepublic('Dominican Republic', '도미니카 공화국', 'DO'),
  dominica('Dominica', '도미니카 연방', 'DM'),
  timorLeste('Timor-Leste', '동티모르', 'TL'),
  germany('Germany', '독일', 'DE'),
  laos('Laos', '라오스', 'LA'),
  liberia('Liberia', '라이베리아', 'LR'),
  latvia('Latvia', '라트비아', 'LV'),
  russia('Russia', '러시아', 'RU'),
  lebanon('Lebanon', '레바논', 'LB'),
  lesotho('Lesotho', '레소토', 'LS'),
  reunion('Reunion', '레위니옹', 'RE'),
  romania('Romania', '루마니아', 'RO'),
  luxembourg('Luxembourg', '룩셈부르크', 'LU'),
  rwanda('Rwanda', '르완다', 'RW'),
  libya('Libya', '리비아', 'LY'),
  lithuania('Lithuania', '리투아니아', 'LT'),
  liechtenstein('Lichtenstein', '리히텐슈타인', 'LI'),
  madagascar('Madagascar', '마다가스카르', 'MG'),
  martinique('Martinique', '마르티니크', 'MQ'),
  marshallIslands('Marshall Islands', '마셜 제도', 'MH'),
  mayotte('Mayotte', '마요트', 'YT'),
  macao('Macao', '마카오', 'MO'),
  malawi('Malawi', '말라위', 'MW'),
  malaysia('Malaysia', '말레이시아', 'MY'),
  mali('Mali', '말리', 'ML'),
  isleOfMan('Isle of Man', '맨섬', 'IM'),
  mexico('Mexico', '멕시코', 'MX'),
  monaco('Monaco', '모나코', 'MC'),
  morocco('Morocco', '모로코', 'MA'),
  mauritius('Mauritius', '모리셔스', 'MU'),
  mauritania('Mauritania', '모리타니', 'MR'),
  mozambique('Mozambique', '모잠비크', 'MZ'),
  montenegro('Montenegro', '몬테네그로', 'ME'),
  montserrat('Montserrat', '몬트세랫', 'MS'),
  moldova('Moldova', '몰도바', 'MD'),
  maldives('Maldives', '몰디브', 'MV'),
  malta('Malta', '몰타', 'MT'),
  mongolia('Mongolia', '몽골', 'MN'),
  unitedStates('United States', '미국', 'US'),
  usMinorOutlyingIslands('US Minor Outlying Islands', '미국령 군소 제도', 'UM'),
  usVirginIslands('US Virgin Islands', '미국령 버진아일랜드', 'VI'),
  myanmar('Myanmar', '미얀마', 'MM'),
  micronesia('Federated States of Micronesia', '미크로네시아 연방', 'FM'),
  vanuatu('Vanuatu', '바누아투', 'VU'),
  bahrain('Bahrain', '바레인', 'BH'),
  barbados('Barbados', '바베이도스', 'BB'),
  vaticanCity('Vatican City', '바티칸 시국', 'VA'),
  bahamas('Bahamas', '바하마', 'BS'),
  bangladesh('Bangladesh', '방글라데시', 'BD'),
  bermuda('Bermuda', '버뮤다', 'BM'),
  benin('Benin', '베냉', 'BJ'),
  venezuela('Venezuela', '베네수엘라', 'VE'),
  vietnam('Vietnam', '베트남', 'VN'),
  belgium('Belgium', '벨기에', 'BE'),
  belarus('Belarus', '벨라루스', 'BY'),
  belize('Belize', '벨리즈', 'BZ'),
  bonaireIsland('Bonaire Island', '보네르섬', 'BQ'),
  bosniaAndHerzegovina('Bosnia and Herzegovina', '보스니아 헤르체고비나', 'BA'),
  botswana('Botswana', '보츠와나', 'BW'),
  bolivia('Bolivia', '볼리비아', 'BO'),
  burundi('Burundi', '부룬디', 'BI'),
  burkinaFaso('Burkina Faso', '부르키나파소', 'BF'),
  bouvetIsland('Bouvet Island', '부베섬', 'BV'),
  bhutan('Bhutan', '부탄', 'BT'),
  northernMarianaIslands('Northern Mariana Islands', '북마리아나 제도', 'MP'),
  macedonia('Macedonia', '북마케도니아', 'MK'),
  bulgaria('Bulgaria', '불가리아', 'BG'),
  brazil('Brazil', '브라질', 'BR'),
  bruneiDarussalam('Brunei Darussalam', '브루나이', 'BN'),
  samoa('Samoa', '사모아', 'WS'),
  saudiArabia('Saudi Arabia', '사우디아라비아', 'SA'),
  southGeorgiaAndSouthSandwich(
    'South Georgia and the South Sandwich Islands',
    '사우스조지아 사우스샌드위치 제도',
    'GS',
  ),
  sanMarino('San Marino', '산마리노', 'SM'),
  saoTomeAndPrincipe('Sao Tome and Principe', '상투메 프린시페', 'ST'),
  saintMartin('Saint Martin', '생마르탱', 'MF'),
  saintBarthelemy('Saint Barthelemy', '생바르텔레미', 'BL'),
  saintPierreAndMiquelon('Saint Pierre and Miquelon', '생피에르 미클롱', 'PM'),
  westernSahara('Western Sahara', '서사하라', 'EH'),
  senegal('Senegal', '세네갈', 'SN'),
  serbia('Serbia', '세르비아', 'RS'),
  seychelles('Seychelles', '세이셸', 'SC'),
  saintLucia('Saint Lucia', '세인트루시아', 'LC'),
  saintVincentAndGrenadines(
    'Saint Vincent and the Grenadines',
    '세인트빈센트 그레나딘',
    'VC',
  ),
  saintKittsAndNevis('Saint Kitts and Nevis', '세인트키츠 네비스', 'KN'),
  saintHelena('Saint Helena', '세인트헬레나', 'SH'),
  somalia('Somalia', '소말리아', 'SO'),
  solomonIslands('Solomon Islands', '솔로몬 제도', 'SB'),
  sudan('Sudan', '수단', 'SD'),
  suriname('Suriname', '수리남', 'SR'),
  sriLanka('Sri Lanka', '스리랑카', 'LK'),
  svalbardAndJanMayen('Svalbard and Jan Mayen', '스발바르 얀마옌 제도', 'SJ'),
  sweden('Sweden', '스웨덴', 'SE'),
  switzerland('Switzerland', '스위스', 'CH'),
  spain('Spain', '스페인', 'ES'),
  slovakia('Slovakia', '슬로바키아', 'SK'),
  slovenia('Slovenia', '슬로베니아', 'SI'),
  syria('Syria', '시리아', 'SY'),
  sierraLeone('Sierra Leone', '시에라리온', 'SL'),
  sintMaarten('Sint Maarten', '신트마르턴', 'SX'),
  singapore('Singapore', '싱가포르', 'SG'),
  unitedArabEmirates('United Arab Emirates', '아랍에미리트', 'AE'),
  aruba('Aruba', '아루바', 'AW'),
  armenia('Armenia', '아르메니아', 'AM'),
  argentina('Argentina', '아르헨티나', 'AR'),
  americanSamoa('American Samoa', '아메리칸사모아', 'AS'),
  iceland('Iceland', '아이슬란드', 'IS'),
  haiti('Haiti', '아이티', 'HT'),
  ireland('Ireland', '아일랜드', 'IE'),
  azerbaijan('Azerbaijan', '아제르바이잔', 'AZ'),
  afghanistan('Afghanistan', '아프가니스탄', 'AF'),
  andorra('Andorra', '안도라', 'AD'),
  albania('Albania', '알바니아', 'AL'),
  algeria('Algeria', '알제리', 'DZ'),
  angola('Angola', '앙골라', 'AO'),
  antiguaAndBarbuda('Antigua and Barbuda', '앤티가 바부다', 'AG'),
  anguilla('Anguilla', '앵귈라', 'AI'),
  eritrea('Eritrea', '에리트레아', 'ER'),
  eswatini('Eswatini', '에스와티니', 'SZ'),
  estonia('Estonia', '에스토니아', 'EE'),
  ecuador('Ecuador', '에콰도르', 'EC'),
  ethiopia('Ethiopia', '에티오피아', 'ET'),
  elSalvador('El Salvador', '엘살바도르', 'SV'),
  unitedKingdom('United Kingdom', '영국', 'GB'),
  britishVirginIslands('British Virgin Islands', '영국령 버진아일랜드', 'VG'),
  britishIndianOceanTerritory(
    'British Indian Ocean Territory',
    '영국령 인도양 지역',
    'IO',
  ),
  yemen('Yemen', '예멘', 'YE'),
  oman('Oman', '오만', 'OM'),
  australia('Australia', '오스트레일리아', 'AU'),
  austria('Austria', '오스트리아', 'AT'),
  honduras('Honduras', '온두라스', 'HN'),
  alandIslands('Aland Islands', '올란드 제도', 'AX'),
  wallisAndFutuna('Wallis and Futuna', '왈리스 푸투나', 'WF'),
  jordan('Jordan', '요르단', 'JO'),
  uganda('Uganda', '우간다', 'UG'),
  uruguay('Uruguay', '우루과이', 'UY'),
  uzbekistan('Uzbekistan', '우즈베키스탄', 'UZ'),
  ukraine('Ukraine', '우크라이나', 'UA'),
  iraq('Iraq', '이라크', 'IQ'),
  iran('Iran', '이란', 'IR'),
  israel('Israel', '이스라엘', 'IL'),
  egypt('Egypt', '이집트', 'EG'),
  italy('Italy', '이탈리아', 'IT'),
  india('India', '인도', 'IN'),
  indonesia('Indonesia', '인도네시아', 'ID'),
  japan('Japan', '일본', 'JP'),
  jamaica('Jamaica', '자메이카', 'JM'),
  zambia('Zambia', '잠비아', 'ZM'),
  jersey('Jersey', '저지섬', 'JE'),
  equatorialGuinea('Equatorial Guinea', '적도 기니', 'GQ'),
  northKorea('North Korea', '조선민주주의인민공화국', 'KP'),
  georgia('Georgia', '조지아', 'GE'),
  china('China', '중국', 'CN'),
  centralAfricanRepublic('Central African Republic', '중앙아프리카 공화국', 'CF'),
  taiwan('Taiwan', '중화민국', 'TW'),
  djibouti('Djibouti', '지부티', 'DJ'),
  gibraltar('Gibraltar', '지브롤터', 'GI'),
  zimbabwe('Zimbabwe', '짐바브웨', 'ZW'),
  chad('Chad', '차드', 'TD'),
  czechRepublic('Czech Republic', '체코', 'CZ'),
  chile('Chile', '칠레', 'CL'),
  cameroon('Cameroon', '카메룬', 'CM'),
  caboVerde('Cabo Verde', '카보베르데', 'CV'),
  kazakhstan('Kazakhstan', '카자흐스탄', 'KZ'),
  qatar('Qatar', '카타르', 'QA'),
  cambodia('Cambodia', '캄보디아', 'KH'),
  canada('Canada', '캐나다', 'CA'),
  kenya('Kenya', '케냐', 'KE'),
  caymanIslands('Cayman Islands', '케이맨 제도', 'KY'),
  comoros('Comoros', '코모로', 'KM'),
  costaRica('Costa Rica', '코스타리카', 'CR'),
  cocosIslands('Cocos Islands', '코코스 제도', 'CC'),
  coteDIvoire('Cote d\'Ivoire', '코트디부아르', 'CI'),
  colombia('Colombia', '콜롬비아', 'CO'),
  congo('Congo', '콩고 공화국', 'CG'),
  democraticRepublicOfCongo('Democratic Republic of Congo', '콩고 민주 공화국', 'CD'),
  cuba('Cuba', '쿠바', 'CU'),
  kuwait('Kuwait', '쿠웨이트', 'KW'),
  cookIslands('Cook Islands', '쿡 제도', 'CK'),
  curacao('Curacao', '퀴라소', 'CW'),
  croatia('Croatia', '크로아티아', 'HR'),
  christmasIsland('Christmas Island', '크리스마스섬', 'CX'),
  kyrgyzstan('Kyrgyzstan', '키르기스스탄', 'KG'),
  kiribati('Kiribati', '키리바시', 'KI'),
  cyprus('Cyprus', '키프로스', 'CY'),
  tajikistan('Tajikistan', '타지키스탄', 'TJ'),
  tanzania('Tanzania', '탄자니아', 'TZ'),
  thailand('Thailand', '태국', 'TH'),
  turksAndCaicosIslands('Turks and Caicos Islands', '터크스 케이커스 제도', 'TC'),
  turkey('Turkey', '튀르키예', 'TR'),
  togo('Togo', '토고', 'TG'),
  tokelau('Tokelau', '토켈라우', 'TK'),
  tonga('Tonga', '통가', 'TO'),
  turkmenistan('Turkmenistan', '투르크메니스탄', 'TM'),
  tuvalu('Tuvalu', '투발루', 'TV'),
  tunisia('Tunisia', '튀니지', 'TN'),
  trinidadAndTobago('Trinidad and Tobago', '트리니다드 토바고', 'TT'),
  panama('Panama', '파나마', 'PA'),
  paraguay('Paraguay', '파라과이', 'PY'),
  pakistan('Pakistan', '파키스탄', 'PK'),
  papuaNewGuinea('Papua New Guinea', '파푸아뉴기니', 'PG'),
  palau('Palau', '팔라우', 'PW'),
  palestine('Palestine', '팔레스타인', 'PS'),
  faroeIslands('Faroe Islands', '페로 제도', 'FO'),
  peru('Peru', '페루', 'PE'),
  portugal('Portugal', '포르투갈', 'PT'),
  falklandIslands('Falkland Islands', '포클랜드 제도', 'FK'),
  poland('Poland', '폴란드', 'PL'),
  puertoRico('Puerto Rico', '푸에르토리코', 'PR'),
  france('France', '프랑스', 'FR'),
  frenchGuiana('French Guiana', '프랑스령 기아나', 'GF'),
  frenchSouthernTerritories(
    'French Southern Territories',
    '프랑스령 남방 및 남극 지역',
    'TF',
  ),
  frenchPolynesia('French Polynesia', '프랑스령 폴리네시아', 'PF'),
  fiji('Fiji', '피지', 'FJ'),
  finland('Finland', '핀란드', 'FI'),
  philippines('Philippines', '필리핀', 'PH'),
  pitcairnIslands('Pitcairn Islands', '핏케언 제도', 'PN'),
  heardAndMcDonaldIslands(
    'Heard Island and McDonald Islands',
    '허드 맥도널드 제도',
    'HM',
  ),
  hungary('Hungary', '헝가리', 'HU'),
  hongKong('Hong Kong', '홍콩', 'HK');

  // 생성자
  const Country(this.englishName, this.koreanName, this.countryCode);

  // 속성
  final String englishName;
  final String koreanName;
  final String countryCode;

  // 현재 언어 설정에 따라 표시할 이름을 반환하는 메소드
  // 실제 앱에서는 Flutter의 국제화 기능 (AppLocalizations) 사용을 강력히 권장합니다.
  // 예시: String getDisplayName(BuildContext context) => AppLocalizations.of(context)!.countryName(this);
  String getDisplayName(String languageCode) {
    // languageCode는 'en', 'ko' 등으로 가정
    switch (languageCode.toLowerCase()) {
      case 'ko':
        return koreanName;
      case 'en':
      default:
        return englishName;
    }
  }

  // API 응답 값(영어 이름)으로부터 Country enum 멤버를 찾는 정적 메소드
  static Country? findByCountryCode(String? countryCode) {
    if (countryCode == null) return null;
    for (final country in values) {
      // 대소문자 구분 없이 비교 (API 응답이 일관되지 않을 수 있으므로)
      if (country.countryCode.toLowerCase() == countryCode.toLowerCase()) {
        return country;
      }
    }
    print('Warning: Unknown Country API value encountered: $countryCode');
    return null; // 일치하는 국가가 없으면 null 반환 또는 예외 처리
  }

  // ko로 en을 찾는 함수
  static String? findByKoreanName(String? koreanName) {
    if (koreanName == null) return null;
    for (final country in values) {
      // 대소문자 구분 없이 비교 (API 응답이 일관되지 않을 수 있으므로)
      if (country.koreanName.toLowerCase() == koreanName.toLowerCase()) {
        return country.englishName;
      }
    }
    return null; // 일치하는 국가가 없으면 null 반환 또는 예외 처리
  }
}

// --- 사용 예시 ---
// Country myCountry = Country.southKorea;
// print(myCountry.englishName); // "South Korea"
// print(myCountry.koreanName);  // "대한민국"
// print(myCountry.apiValue);    // "South Korea" (API 전송용)
// print(myCountry.getDisplayName('ko')); // "대한민국" (UI 표시용 - 한국어)
// print(myCountry.getDisplayName('en')); // "South Korea" (UI 표시용 - 영어)

// Country? foundCountry = Country.findByCountryCode("US");
// if (foundCountry != null) {
//   print(foundCountry.getDisplayName('ko')); // "미국"
// }
