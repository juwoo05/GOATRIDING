// Kakao Maps 기반 내비 (Google 코드 완전 대체)

const SEOUL_CITY_HALL = { lat: 37.5665, lng: 126.9780 };

// ---- 전역 상태 ----
let map;                          // kakao.maps.Map
let gpsWatchId = null;
let currentLocationMarker = null; // kakao.maps.Marker
let dangerousAreaMarkers = [];
let routePolyline = null;         // kakao.maps.Polyline
let startMarker = null;
let endMarker = null;

let hasJoinedRoute = false;       // 경로에 한번이라도 붙었는지
const JOIN_THRESHOLD_M = 120;     // 최초 합류 허용 거리
const OFF_ROUTE_THRESHOLD_M = 120;// 합류 이후 이탈 기준

// 검색/지오코더
let kakaoPlaces = null;           // kakao.maps.services.Places
let kakaoGeocoder = null;         // kakao.maps.services.Geocoder
let placesService = null;         // 별칭

// 지도를 자동으로 따라갈지 여부 (버튼으로 토글)
let followUser = false;

// ---- SDK 로드 후 초기화 -----
if (window.kakao && kakao.maps && kakao.maps.load) {
    kakao.maps.load(initKakao);
} else {
    window.addEventListener('load', () => kakao.maps.load(initKakao));
}

function initKakao() {

    var areas = [
        {
            name : '용산구',
            path : [
                new kakao.maps.LatLng(37.5548768201904, 126.96966524449994),
                new kakao.maps.LatLng(37.55308718044556, 126.97642899633566),
                new kakao.maps.LatLng(37.55522076659584, 126.97654602427454),
                new kakao.maps.LatLng(37.55320655210504, 126.97874667968763),
                new kakao.maps.LatLng(37.55368689494708, 126.98541456064552),
                new kakao.maps.LatLng(37.54722934282707, 126.995229135048),
                new kakao.maps.LatLng(37.549694559809545, 126.99832516302801),
                new kakao.maps.LatLng(37.550159406110104, 127.00436818301327),
                new kakao.maps.LatLng(37.54820235864802, 127.0061334023129),
                new kakao.maps.LatLng(37.546169758665414, 127.00499711608721),
                new kakao.maps.LatLng(37.54385947805103, 127.00727818360471),
                new kakao.maps.LatLng(37.54413326436179, 127.00898460651953),
                new kakao.maps.LatLng(37.539639030116945, 127.00959054834321),
                new kakao.maps.LatLng(37.537681185520256, 127.01726163044557),
                new kakao.maps.LatLng(37.53378887274516, 127.01719284893274),
                new kakao.maps.LatLng(37.52290225898471, 127.00614038053493),
                new kakao.maps.LatLng(37.51309192794448, 126.99070240960813),
                new kakao.maps.LatLng(37.50654651085339, 126.98553683648308),
                new kakao.maps.LatLng(37.50702053393398, 126.97524914998174),
                new kakao.maps.LatLng(37.51751820477105, 126.94988506562748),
                new kakao.maps.LatLng(37.52702918583156, 126.94987870367682),
                new kakao.maps.LatLng(37.534519656862926, 126.94481851935942),
                new kakao.maps.LatLng(37.537500243531994, 126.95335659960566),
                new kakao.maps.LatLng(37.54231338779177, 126.95817394011969),
                new kakao.maps.LatLng(37.54546318600178, 126.95790512689311),
                new kakao.maps.LatLng(37.548791603525764, 126.96371984820232),
                new kakao.maps.LatLng(37.55155543391863, 126.96233786542686),
                new kakao.maps.LatLng(37.5541513366375, 126.9657135934734),
                new kakao.maps.LatLng(37.55566236579088, 126.9691850696746),
                new kakao.maps.LatLng(37.5548768201904, 126.96966524449994)
            ]
        }, {
            name : '중구',
            path : [
                new kakao.maps.LatLng(37.544062989758594, 127.00854659142894),
                new kakao.maps.LatLng(37.54385947805103, 127.00727818360471),
                new kakao.maps.LatLng(37.546169758665414, 127.00499711608721),
                new kakao.maps.LatLng(37.54820235864802, 127.0061334023129),
                new kakao.maps.LatLng(37.550159406110104, 127.00436818301327),
                new kakao.maps.LatLng(37.549694559809545, 126.99832516302801),
                new kakao.maps.LatLng(37.54722934282707, 126.995229135048),
                new kakao.maps.LatLng(37.55368689494708, 126.98541456064552),
                new kakao.maps.LatLng(37.55320655210504, 126.97874667968763),
                new kakao.maps.LatLng(37.55522076659584, 126.97654602427454),
                new kakao.maps.LatLng(37.55308718044556, 126.97642899633566),
                new kakao.maps.LatLng(37.55487749311664, 126.97240854546743),
                new kakao.maps.LatLng(37.5548766923893, 126.9691718124876),
                new kakao.maps.LatLng(37.55566236579088, 126.9691850696746),
                new kakao.maps.LatLng(37.55155543391863, 126.96233786542686),
                new kakao.maps.LatLng(37.55498984534305, 126.96173858545431),
                new kakao.maps.LatLng(37.55695455613004, 126.96343068837372),
                new kakao.maps.LatLng(37.5590262922649, 126.9616731414449),
                new kakao.maps.LatLng(37.56197662569172, 126.96946316364357),
                new kakao.maps.LatLng(37.56582132960869, 126.96669525397355),
                new kakao.maps.LatLng(37.56824746386509, 126.96909838710842),
                new kakao.maps.LatLng(37.569485309984174, 126.97637402412326),
                new kakao.maps.LatLng(37.56810323716611, 126.98905202099309),
                new kakao.maps.LatLng(37.56961739576364, 127.00225936812329),
                new kakao.maps.LatLng(37.56966688588187, 127.0152677241078),
                new kakao.maps.LatLng(37.572022763755164, 127.0223363152772),
                new kakao.maps.LatLng(37.57190723475508, 127.02337770475695),
                new kakao.maps.LatLng(37.56973041414113, 127.0234585247501),
                new kakao.maps.LatLng(37.565200182350495, 127.02358387477513),
                new kakao.maps.LatLng(37.56505173515675, 127.02678930885806),
                new kakao.maps.LatLng(37.563390358462826, 127.02652159646888),
                new kakao.maps.LatLng(37.5607276739534, 127.02339232029838),
                new kakao.maps.LatLng(37.55779412537163, 127.0228934248264),
                new kakao.maps.LatLng(37.556850715898484, 127.01807638779917),
                new kakao.maps.LatLng(37.55264513061776, 127.01620129137214),
                new kakao.maps.LatLng(37.547466935106435, 127.00931996404753),
                new kakao.maps.LatLng(37.54502351209897, 127.00815187343248),
                new kakao.maps.LatLng(37.544062989758594, 127.00854659142894)
            ]
        }, {
            name : '종로구',
            path : [
                new kakao.maps.LatLng(37.631840777111364, 126.9749313865046),
                new kakao.maps.LatLng(37.632194205253654, 126.97609588529602),
                new kakao.maps.LatLng(37.629026103322374, 126.97496405167149),
                new kakao.maps.LatLng(37.6285585388996, 126.97992605309885),
                new kakao.maps.LatLng(37.626378096236195, 126.97960492198952),
                new kakao.maps.LatLng(37.6211493968146, 126.98365245774505),
                new kakao.maps.LatLng(37.6177725051378, 126.9837302191854),
                new kakao.maps.LatLng(37.613985109550605, 126.98658977758268),
                new kakao.maps.LatLng(37.611364924201304, 126.98565700183143),
                new kakao.maps.LatLng(37.60401657024552, 126.98665951539246),
                new kakao.maps.LatLng(37.60099164566844, 126.97852019816328),
                new kakao.maps.LatLng(37.59790270809407, 126.97672287261275),
                new kakao.maps.LatLng(37.59447673441787, 126.98544283754865),
                new kakao.maps.LatLng(37.59126960661375, 126.98919808879788),
                new kakao.maps.LatLng(37.592300831997434, 127.0009511248032),
                new kakao.maps.LatLng(37.58922302426079, 127.00228260552726),
                new kakao.maps.LatLng(37.586091007146834, 127.00667090686603),
                new kakao.maps.LatLng(37.58235007703611, 127.00677925856456),
                new kakao.maps.LatLng(37.58047228501006, 127.00863575242668),
                new kakao.maps.LatLng(37.58025588757531, 127.01058748333907),
                new kakao.maps.LatLng(37.582338528091164, 127.01483104096094),
                new kakao.maps.LatLng(37.581693162424465, 127.01673289259993),
                new kakao.maps.LatLng(37.57758802896556, 127.01812215416163),
                new kakao.maps.LatLng(37.5788668917658, 127.02140099081309),
                new kakao.maps.LatLng(37.578034045208426, 127.02313962015988),
                new kakao.maps.LatLng(37.57190723475508, 127.02337770475695),
                new kakao.maps.LatLng(37.56966688588187, 127.0152677241078),
                new kakao.maps.LatLng(37.56961739576364, 127.00225936812329),
                new kakao.maps.LatLng(37.5681357695346, 126.99014772014593),
                new kakao.maps.LatLng(37.569315246023024, 126.9732046364419),
                new kakao.maps.LatLng(37.56824746386509, 126.96909838710842),
                new kakao.maps.LatLng(37.56582132960869, 126.96669525397355),
                new kakao.maps.LatLng(37.57874076105342, 126.95354824618335),
                new kakao.maps.LatLng(37.581020184166476, 126.95812059678624),
                new kakao.maps.LatLng(37.59354736740056, 126.95750665936443),
                new kakao.maps.LatLng(37.595061575856455, 126.9590412421402),
                new kakao.maps.LatLng(37.59833350100327, 126.9576941779143),
                new kakao.maps.LatLng(37.59875701675023, 126.95306020161668),
                new kakao.maps.LatLng(37.602476031211225, 126.95237386792348),
                new kakao.maps.LatLng(37.60507154496655, 126.95404376087069),
                new kakao.maps.LatLng(37.60912809443569, 126.95032198271032),
                new kakao.maps.LatLng(37.615539700280216, 126.95072546923387),
                new kakao.maps.LatLng(37.62433621196653, 126.94900237336302),
                new kakao.maps.LatLng(37.62642708817027, 126.95037844036497),
                new kakao.maps.LatLng(37.629590994617104, 126.95881385457929),
                new kakao.maps.LatLng(37.629794440379136, 126.96376660599225),
                new kakao.maps.LatLng(37.632373740990175, 126.97302793692637),
                new kakao.maps.LatLng(37.631840777111364, 126.9749313865046)
            ]
        }, {
            name : '서대문구',
            path : [
                new kakao.maps.LatLng(37.59851932019209, 126.95347706883003),
                new kakao.maps.LatLng(37.5992407011344, 126.95499403097206),
                new kakao.maps.LatLng(37.59833350100327, 126.9576941779143),
                new kakao.maps.LatLng(37.595061575856455, 126.9590412421402),
                new kakao.maps.LatLng(37.59354736740056, 126.95750665936443),
                new kakao.maps.LatLng(37.581020184166476, 126.95812059678624),
                new kakao.maps.LatLng(37.57874076105342, 126.95354824618335),
                new kakao.maps.LatLng(37.56197662569172, 126.96946316364357),
                new kakao.maps.LatLng(37.5575156365052, 126.95991288916548),
                new kakao.maps.LatLng(37.55654562007193, 126.9413708153468),
                new kakao.maps.LatLng(37.555098093384, 126.93685861757348),
                new kakao.maps.LatLng(37.55884751347576, 126.92659242918415),
                new kakao.maps.LatLng(37.5633319104926, 126.92828128083327),
                new kakao.maps.LatLng(37.56510367293256, 126.92601582346325),
                new kakao.maps.LatLng(37.57082994377989, 126.9098094620638),
                new kakao.maps.LatLng(37.57599550420081, 126.902091747923),
                new kakao.maps.LatLng(37.587223103650295, 126.91284666446226),
                new kakao.maps.LatLng(37.58541570520177, 126.91531241017965),
                new kakao.maps.LatLng(37.585870567159255, 126.91638068573187),
                new kakao.maps.LatLng(37.583095195853055, 126.9159399866114),
                new kakao.maps.LatLng(37.583459593417196, 126.92175886498167),
                new kakao.maps.LatLng(37.587104600730505, 126.92388813813815),
                new kakao.maps.LatLng(37.588386594820484, 126.92800815682232),
                new kakao.maps.LatLng(37.59157595859555, 126.92776504133688),
                new kakao.maps.LatLng(37.59455434247408, 126.93027139545339),
                new kakao.maps.LatLng(37.59869748704149, 126.94088480070904),
                new kakao.maps.LatLng(37.60065830191363, 126.9414041615336),
                new kakao.maps.LatLng(37.60305781086164, 126.93995273804141),
                new kakao.maps.LatLng(37.610598531321436, 126.95037536795142),
                new kakao.maps.LatLng(37.6083605525023, 126.95056259057313),
                new kakao.maps.LatLng(37.60507154496655, 126.95404376087069),
                new kakao.maps.LatLng(37.602476031211225, 126.95237386792348),
                new kakao.maps.LatLng(37.59851932019209, 126.95347706883003)
            ]
        }, {
            name : '동대문구',
            path : [
                new kakao.maps.LatLng(37.607062869017085, 127.07111288773496),
                new kakao.maps.LatLng(37.60107201319839, 127.07287376670605),
                new kakao.maps.LatLng(37.59724304056685, 127.06949105186925),
                new kakao.maps.LatLng(37.58953367466315, 127.07030363208528),
                new kakao.maps.LatLng(37.58651213184981, 127.07264218709383),
                new kakao.maps.LatLng(37.5849555116177, 127.07216063016078),
                new kakao.maps.LatLng(37.58026781100598, 127.07619547037923),
                new kakao.maps.LatLng(37.571869232268774, 127.0782018408153),
                new kakao.maps.LatLng(37.559961773835425, 127.07239004251258),
                new kakao.maps.LatLng(37.56231553903832, 127.05876047165025),
                new kakao.maps.LatLng(37.57038253579033, 127.04794980454399),
                new kakao.maps.LatLng(37.572878529071055, 127.04263554582458),
                new kakao.maps.LatLng(37.57302061077518, 127.0381755492195),
                new kakao.maps.LatLng(37.56978273516453, 127.03099733100001),
                new kakao.maps.LatLng(37.57190723475508, 127.02337770475695),
                new kakao.maps.LatLng(37.57838361223621, 127.0232348231103),
                new kakao.maps.LatLng(37.58268174514337, 127.02953994610249),
                new kakao.maps.LatLng(37.58894739851823, 127.03553876830637),
                new kakao.maps.LatLng(37.5911852565689, 127.03621919708065),
                new kakao.maps.LatLng(37.59126734230753, 127.03875553445558),
                new kakao.maps.LatLng(37.5956815721534, 127.04062845365279),
                new kakao.maps.LatLng(37.5969637344377, 127.04302522879048),
                new kakao.maps.LatLng(37.59617641777492, 127.04734129391157),
                new kakao.maps.LatLng(37.60117358544485, 127.05101351973708),
                new kakao.maps.LatLng(37.600149587503246, 127.05209540476308),
                new kakao.maps.LatLng(37.60132672748398, 127.05508130598699),
                new kakao.maps.LatLng(37.6010580545608, 127.05917142337097),
                new kakao.maps.LatLng(37.605121767227374, 127.06219611364686),
                new kakao.maps.LatLng(37.607062869017085, 127.07111288773496)
            ]
        }, {
            name : '성북구',
            path : [
                new kakao.maps.LatLng(37.63654916557213, 126.98446028560235),
                new kakao.maps.LatLng(37.631446839436855, 126.99372381657889),
                new kakao.maps.LatLng(37.626192451322005, 126.99927047335905),
                new kakao.maps.LatLng(37.62382095469671, 127.00488450145781),
                new kakao.maps.LatLng(37.624026217174986, 127.00788862747375),
                new kakao.maps.LatLng(37.6205124078061, 127.00724034082933),
                new kakao.maps.LatLng(37.61679651952433, 127.01014412786792),
                new kakao.maps.LatLng(37.61472018601129, 127.01451127202589),
                new kakao.maps.LatLng(37.614629670135216, 127.01757841621624),
                new kakao.maps.LatLng(37.61137091590441, 127.02219857751122),
                new kakao.maps.LatLng(37.612692696824915, 127.02642583551054),
                new kakao.maps.LatLng(37.612367438936786, 127.03018593770908),
                new kakao.maps.LatLng(37.60896889076571, 127.0302525167858),
                new kakao.maps.LatLng(37.61279787695882, 127.03730791358603),
                new kakao.maps.LatLng(37.62426467261789, 127.04973339977498),
                new kakao.maps.LatLng(37.61449950127667, 127.06174181124696),
                new kakao.maps.LatLng(37.61561580859776, 127.06985247014711),
                new kakao.maps.LatLng(37.61351359068103, 127.07170798866412),
                new kakao.maps.LatLng(37.60762512162974, 127.07105453180604),
                new kakao.maps.LatLng(37.605121767227374, 127.06219611364686),
                new kakao.maps.LatLng(37.6010580545608, 127.05917142337097),
                new kakao.maps.LatLng(37.60132672748398, 127.05508130598699),
                new kakao.maps.LatLng(37.600149587503246, 127.05209540476308),
                new kakao.maps.LatLng(37.60117358544485, 127.05101351973708),
                new kakao.maps.LatLng(37.59617641777492, 127.04734129391157),
                new kakao.maps.LatLng(37.59644879095525, 127.04184728392097),
                new kakao.maps.LatLng(37.59126734230753, 127.03875553445558),
                new kakao.maps.LatLng(37.5911852565689, 127.03621919708065),
                new kakao.maps.LatLng(37.58894739851823, 127.03553876830637),
                new kakao.maps.LatLng(37.58268174514337, 127.02953994610249),
                new kakao.maps.LatLng(37.57782865303167, 127.02296295333255),
                new kakao.maps.LatLng(37.57889204835333, 127.02179043639809),
                new kakao.maps.LatLng(37.57758802896556, 127.01812215416163),
                new kakao.maps.LatLng(37.581693162424465, 127.01673289259993),
                new kakao.maps.LatLng(37.582338528091164, 127.01483104096094),
                new kakao.maps.LatLng(37.58025588757531, 127.01058748333907),
                new kakao.maps.LatLng(37.58047228501006, 127.00863575242668),
                new kakao.maps.LatLng(37.58235007703611, 127.00677925856456),
                new kakao.maps.LatLng(37.586091007146834, 127.00667090686603),
                new kakao.maps.LatLng(37.58922302426079, 127.00228260552726),
                new kakao.maps.LatLng(37.592300831997434, 127.0009511248032),
                new kakao.maps.LatLng(37.59126960661375, 126.98919808879788),
                new kakao.maps.LatLng(37.59447673441787, 126.98544283754865),
                new kakao.maps.LatLng(37.59790270809407, 126.97672287261275),
                new kakao.maps.LatLng(37.60099164566844, 126.97852019816328),
                new kakao.maps.LatLng(37.60451393107786, 126.98678626394351),
                new kakao.maps.LatLng(37.611364924201304, 126.98565700183143),
                new kakao.maps.LatLng(37.613985109550605, 126.98658977758268),
                new kakao.maps.LatLng(37.6177725051378, 126.9837302191854),
                new kakao.maps.LatLng(37.6211493968146, 126.98365245774505),
                new kakao.maps.LatLng(37.626378096236195, 126.97960492198952),
                new kakao.maps.LatLng(37.6285585388996, 126.97992605309885),
                new kakao.maps.LatLng(37.62980449548538, 126.97468284124939),
                new kakao.maps.LatLng(37.633657663246694, 126.97740053878216),
                new kakao.maps.LatLng(37.63476479485093, 126.98154674721893),
                new kakao.maps.LatLng(37.63780700422825, 126.9849494717052),
                new kakao.maps.LatLng(37.63654916557213, 126.98446028560235)
            ]
        }, {
            name : '성동구',
            path : [
                new kakao.maps.LatLng(37.57275246810175, 127.04241813085706),
                new kakao.maps.LatLng(37.57038253579033, 127.04794980454399),
                new kakao.maps.LatLng(37.56231553903832, 127.05876047165025),
                new kakao.maps.LatLng(37.5594131360664, 127.07373408220053),
                new kakao.maps.LatLng(37.52832388381049, 127.05621773388143),
                new kakao.maps.LatLng(37.53423885672233, 127.04604398310076),
                new kakao.maps.LatLng(37.53582328355087, 127.03979942567628),
                new kakao.maps.LatLng(37.53581367627865, 127.0211714455564),
                new kakao.maps.LatLng(37.53378887274516, 127.01719284893274),
                new kakao.maps.LatLng(37.537681185520256, 127.01726163044557),
                new kakao.maps.LatLng(37.53938672166098, 127.00993448922989),
                new kakao.maps.LatLng(37.54157804358092, 127.00879872996808),
                new kakao.maps.LatLng(37.54502351209897, 127.00815187343248),
                new kakao.maps.LatLng(37.547466935106435, 127.00931996404753),
                new kakao.maps.LatLng(37.55264513061776, 127.01620129137214),
                new kakao.maps.LatLng(37.556850715898484, 127.01807638779917),
                new kakao.maps.LatLng(37.55779412537163, 127.0228934248264),
                new kakao.maps.LatLng(37.5607276739534, 127.02339232029838),
                new kakao.maps.LatLng(37.563390358462826, 127.02652159646888),
                new kakao.maps.LatLng(37.56505173515675, 127.02678930885806),
                new kakao.maps.LatLng(37.565200182350495, 127.02358387477513),
                new kakao.maps.LatLng(37.57190723475508, 127.02337770475695),
                new kakao.maps.LatLng(37.56978273516453, 127.03099733100001),
                new kakao.maps.LatLng(37.57302061077518, 127.0381755492195),
                new kakao.maps.LatLng(37.57275246810175, 127.04241813085706)
            ]
        }, {
            name : '마포구',
            path : [
                new kakao.maps.LatLng(37.584651324803644, 126.88883849288884),
                new kakao.maps.LatLng(37.57082994377989, 126.9098094620638),
                new kakao.maps.LatLng(37.56510367293256, 126.92601582346325),
                new kakao.maps.LatLng(37.5633319104926, 126.92828128083327),
                new kakao.maps.LatLng(37.55884751347576, 126.92659242918415),
                new kakao.maps.LatLng(37.55675317809392, 126.93190919632814),
                new kakao.maps.LatLng(37.555098093384, 126.93685861757348),
                new kakao.maps.LatLng(37.55654562007193, 126.9413708153468),
                new kakao.maps.LatLng(37.557241466445234, 126.95913438471307),
                new kakao.maps.LatLng(37.55908394430372, 126.96163689468189),
                new kakao.maps.LatLng(37.55820141918588, 126.96305432966605),
                new kakao.maps.LatLng(37.554784413504734, 126.9617251098019),
                new kakao.maps.LatLng(37.548791603525764, 126.96371984820232),
                new kakao.maps.LatLng(37.54546318600178, 126.95790512689311),
                new kakao.maps.LatLng(37.54231338779177, 126.95817394011969),
                new kakao.maps.LatLng(37.539468942052544, 126.955731506394),
                new kakao.maps.LatLng(37.536292068277106, 126.95128907260018),
                new kakao.maps.LatLng(37.53569162926515, 126.94627494388307),
                new kakao.maps.LatLng(37.53377712226906, 126.94458373402794),
                new kakao.maps.LatLng(37.54135238063506, 126.93031191951576),
                new kakao.maps.LatLng(37.539036674424615, 126.9271006565075),
                new kakao.maps.LatLng(37.54143034750605, 126.9224138272872),
                new kakao.maps.LatLng(37.54141748538761, 126.90483000187002),
                new kakao.maps.LatLng(37.548015078285694, 126.89890097452322),
                new kakao.maps.LatLng(37.56300401736817, 126.86623824787709),
                new kakao.maps.LatLng(37.57178997971358, 126.85363039091744),
                new kakao.maps.LatLng(37.57379738998644, 126.85362646212587),
                new kakao.maps.LatLng(37.57747251471329, 126.864939928088),
                new kakao.maps.LatLng(37.5781913017327, 126.87625939970273),
                new kakao.maps.LatLng(37.57977132158497, 126.87767870371688),
                new kakao.maps.LatLng(37.584440882833654, 126.87653889183002),
                new kakao.maps.LatLng(37.59079311146897, 126.88205386700724),
                new kakao.maps.LatLng(37.584651324803644, 126.88883849288884)
            ]
        }
    ];
    var polygonPath = [
        new kakao.maps.LatLng(37.53004747, 126.85233806),
        new kakao.maps.LatLng(37.52976951, 126.85230354),
        new kakao.maps.LatLng(37.52950223, 126.8522013),
        new kakao.maps.LatLng(37.5292559, 126.85203528),
        new kakao.maps.LatLng(37.52903999, 126.85181184),
        new kakao.maps.LatLng(37.52886279, 126.85153959),
        new kakao.maps.LatLng(37.52873113, 126.85122898),
        new kakao.maps.LatLng(37.52865005, 126.85089194),
        new kakao.maps.LatLng(37.52862267, 126.85054143),
        new kakao.maps.LatLng(37.52865005, 126.85019093),
        new kakao.maps.LatLng(37.52873113, 126.84985389),
        new kakao.maps.LatLng(37.52886279, 126.84954328),
        new kakao.maps.LatLng(37.52903999, 126.84927102),
        new kakao.maps.LatLng(37.5292559, 126.84904759),
        new kakao.maps.LatLng(37.52950223, 126.84888156),
        new kakao.maps.LatLng(37.52976951, 126.84877933),
        new kakao.maps.LatLng(37.53004747, 126.8487448),
        new kakao.maps.LatLng(37.53032543, 126.84877933),
        new kakao.maps.LatLng(37.53059271, 126.84888156),
        new kakao.maps.LatLng(37.53083904, 126.84904759),
        new kakao.maps.LatLng(37.53105494, 126.84927102),
        new kakao.maps.LatLng(37.53123213, 126.84954328),
        new kakao.maps.LatLng(37.53136379, 126.84985389),
        new kakao.maps.LatLng(37.53144487, 126.85019093),
        new kakao.maps.LatLng(37.53147225, 126.85054143),
        new kakao.maps.LatLng(37.53144487, 126.85089194),
        new kakao.maps.LatLng(37.53136379, 126.85122898),
        new kakao.maps.LatLng(37.53123213, 126.85153959),
        new kakao.maps.LatLng(37.53105494, 126.85181184),
        new kakao.maps.LatLng(37.53083904, 126.85203528),
        new kakao.maps.LatLng(37.53059271, 126.8522013),
        new kakao.maps.LatLng(37.53032543, 126.85230354),
        new kakao.maps.LatLng(37.53004747, 126.85233806)

    ];

    var mapContainer = document.getElementById('map'), // 지도를 표시할 div
        mapOption = {
            center: new kakao.maps.LatLng(37.566826, 126.9786567), // 지도의 중심좌표
            level: 8 // 지도의 확대 레벨
        };

    var map = new kakao.maps.Map(mapContainer, mapOption),
        customOverlay = new kakao.maps.CustomOverlay({}),
        infowindow = new kakao.maps.InfoWindow({removable: true});

// 지도에 영역데이터를 폴리곤으로 표시합니다
    for (var i = 0, len = areas.length; i < len; i++) {
        displayArea(areas[i]);
    }

// 다각형을 생상하고 이벤트를 등록하는 함수입니다
    function displayArea(area) {

        // 다각형을 생성합니다
        var polygon = new kakao.maps.Polygon({
            map: map, // 다각형을 표시할 지도 객체
            path: area.path,
            strokeWeight: 2,
            strokeColor: '#004c80',
            strokeOpacity: 0.8,
            fillColor: '#fff',
            fillOpacity: 0.7
        });

        // 다각형에 mouseover 이벤트를 등록하고 이벤트가 발생하면 폴리곤의 채움색을 변경합니다
        // 지역명을 표시하는 커스텀오버레이를 지도위에 표시합니다
        kakao.maps.event.addListener(polygon, 'mouseover', function(mouseEvent) {
            polygon.setOptions({fillColor: '#09f'});

            customOverlay.setContent('<div class="area">' + area.name + '</div>');

            customOverlay.setPosition(mouseEvent.latLng);
            customOverlay.setMap(map);
        });

        // 다각형에 mousemove 이벤트를 등록하고 이벤트가 발생하면 커스텀 오버레이의 위치를 변경합니다
        kakao.maps.event.addListener(polygon, 'mousemove', function(mouseEvent) {

            customOverlay.setPosition(mouseEvent.latLng);
        });

        // 다각형에 mouseout 이벤트를 등록하고 이벤트가 발생하면 폴리곤의 채움색을 원래색으로 변경합니다
        // 커스텀 오버레이를 지도에서 제거합니다
        kakao.maps.event.addListener(polygon, 'mouseout', function() {
            polygon.setOptions({fillColor: '#fff'});
            customOverlay.setMap(null);
        });

        // 다각형에 click 이벤트를 등록하고 이벤트가 발생하면 다각형의 이름과 면적을 인포윈도우에 표시합니다
        kakao.maps.event.addListener(polygon, 'click', function(mouseEvent) {
            var content = '<div class="info">' +
                '   <div class="title">' + area.name + '</div>'

            infowindow.setContent(content);
            infowindow.setPosition(mouseEvent.latLng);
            infowindow.setMap(map);
        });
    }
//
// // 지도에 표시할 다각형을 생성합니다
//     var polygon = new kakao.maps.Polygon({
//         path:polygonPath, // 그려질 다각형의 좌표 배열입니다
//         strokeWeight: 3, // 선의 두께입니다
//         strokeColor: '#39DE2A', // 선의 색깔입니다
//         strokeOpacity: 0.8, // 선의 불투명도 입니다 1에서 0 사이의 값이며 0에 가까울수록 투명합니다
//         strokeStyle: 'longdash', // 선의 스타일입니다
//         fillColor: '#A2FF99', // 채우기 색깔입니다
//         fillOpacity: 0.7 // 채우기 불투명도 입니다
//     });
//
// // 지도에 다각형을 표시합니다
//     polygon.setMap(map);
    updateDangerousAreaMarkers();
    initRecommendedRoutes();
    initGeolocation();

    // 입력/버튼 바인딩
    bindPlaceSearch();
    bindAutocomplete('#startInput');
    bindAutocomplete('#endInput');
}

/* ---------------- 장소 검색 버튼 ---------------- */
function bindPlaceSearch() {
    const sIn = document.getElementById('startInput');
    const eIn = document.getElementById('endInput');
    const btnS = document.getElementById('searchStart');
    const btnE = document.getElementById('searchEnd');

    // 엔터로도 찾기
    [sIn, eIn].forEach((el, idx) => {
        el?.addEventListener('keydown', (e) => {
            if (e.key !== 'Enter') return;
            (idx === 0 ? btnS?.click() : btnE?.click());
        });
    });

    // 첫 결과를 dataset에 채우는 헬퍼
    function fillFirstResultOf(inputEl, onDone) {
        const q = inputEl?.value.trim();
        if (!q) { alert('검색어를 입력하세요.'); return; }

        kakaoPlaces.keywordSearch(q, (data, status) => {
            if (status === kakao.maps.services.Status.OK && data.length) {
                const d = data[0];
                inputEl.dataset.lat = d.y;
                inputEl.dataset.lng = d.x;
                inputEl.value       = d.place_name || inputEl.value;
                if (onDone) onDone({ lat: parseFloat(d.y), lng: parseFloat(d.x), name: d.place_name });
            } else {
                kakaoGeocoder.addressSearch(q, (a, s2) => {
                    if (s2 === kakao.maps.services.Status.OK && a.length) {
                        inputEl.dataset.lat = a[0].y;
                        inputEl.dataset.lng = a[0].x;
                        inputEl.value       = a[0].road_address?.address_name || a[0].address?.address_name || inputEl.value;
                        if (onDone) onDone({ lat: parseFloat(a[0].y), lng: parseFloat(a[0].x), name: inputEl.value });
                    } else {
                        alert('검색 결과가 없습니다.');
                    }
                });
            }
        });
    }

    if (btnS && !btnS.__wired) {
        btnS.__wired = true;
        btnS.addEventListener('click', () => fillFirstResultOf(sIn, setStartMarker));
    }
    if (btnE && !btnE.__wired) {
        btnE.__wired = true;
        btnE.addEventListener('click', () => fillFirstResultOf(eIn, setEndMarker));
    }

    // 경로 탐색 버튼이 호출하는 전역 함수
    window.searchRoute = async function () {
        try {
            const start = await resolvePlace(sIn.value, sIn?.dataset?.lat, sIn?.dataset?.lng);
            const end   = await resolvePlace(eIn.value, eIn?.dataset?.lat, eIn?.dataset?.lng);

            // 캐시
            sIn.dataset.lat = start.lat; sIn.dataset.lng = start.lng;
            eIn.dataset.lat = end.lat;   eIn.dataset.lng = end.lng;

            setStartMarker(start);
            setEndMarker(end);

            drawRoute({ start, end });
        } catch (err) {
            alert('출발지/도착지 해석 실패: ' + err.message);
        }
    };
}

/* ---------------- 자동완성(키워드+주소 혼합) ---------------- */
function bindAutocomplete(selector) {
    const input = document.querySelector(selector);
    if (!input) return;

    input.parentElement.classList.add('relative');
    const box = document.createElement('div');
    box.className = 'absolute z-50 left-0 right-0 mt-1 bg-white text-black rounded shadow max-h-56 overflow-auto hidden';
    input.parentElement.appendChild(box);

    let typingTimer = null;

    input.addEventListener('input', () => {
        input.dataset.lat = ''; input.dataset.lng = '';
        const q = input.value.trim();
        if (typingTimer) clearTimeout(typingTimer);
        if (!q) { box.innerHTML = ''; box.classList.add('hidden'); return; }
        typingTimer = setTimeout(() => runSearch(q, render), 220);
    });

    input.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') { e.preventDefault(); const first = box.querySelector('button'); first?.click(); }
    });

    input.addEventListener('focus', () => { if (box.innerHTML) box.classList.remove('hidden'); });
    input.addEventListener('blur',  () => setTimeout(() => box.classList.add('hidden'), 150));

    function runSearch(query, done) {
        const results = [];
        const push = (arr, mapFn) => (arr || []).forEach(x => { const r = mapFn(x); if (r && isFinite(r.lat) && isFinite(r.lng)) results.push(r); });

        // 1) 키워드
        kakaoPlaces.keywordSearch(query, (data, status) => {
            if (status === kakao.maps.services.Status.OK) {
                push(data.slice(0,5), p => ({
                    name: p.place_name, lat: parseFloat(p.y), lng: parseFloat(p.x),
                    desc: p.road_address_name || p.address_name || '', src: 'place'
                }));
            }
            // 2) 주소
            kakaoGeocoder.addressSearch(query, (addrData, status2) => {
                if (status2 === kakao.maps.services.Status.OK) {
                    push(addrData.slice(0,5), a => {
                        const road = a.road_address?.address_name;
                        const jibun = a.address?.address_name;
                        const name = road || jibun; if (!name) return null;
                        return { name, lat: parseFloat(a.y), lng: parseFloat(a.x), desc: road && jibun ? `지번: ${jibun}` : '', src: 'addr' };
                    });
                }
                done(dedupe(results).slice(0,8));
            });
        });
    }

    function dedupe(items) {
        const set = new Set();
        return items.filter(it => { const k = `${it.name}|${it.lat}|${it.lng}`; if (set.has(k)) return false; set.add(k); return true; });
    }

    function render(items) {
        if (!items.length) {
            box.innerHTML = '<div class="px-3 py-2 text-sm text-gray-500">검색 결과 없음</div>';
            box.classList.remove('hidden'); return;
        }
        box.innerHTML = '';
        items.forEach(it => {
            const btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'w-full text-left px-3 py-2 hover:bg-gray-100';
            btn.innerHTML = `<div class="text-sm">${it.name}</div>${it.desc ? `<div class="text-xs text-gray-500">${it.desc}</div>`:''}`;
            btn.addEventListener('click', () => {
                input.value = it.name;
                input.dataset.lat = it.lat;
                input.dataset.lng = it.lng;
                box.classList.add('hidden');
                try { map.panTo(new kakao.maps.LatLng(it.lat, it.lng)); } catch(_) {}
            });
            box.appendChild(btn);
        });
        box.classList.remove('hidden');
    }
}

/* ---------------- 위험지역 마커 ---------------- */
function updateDangerousAreaMarkers() {
    dangerousAreaMarkers.forEach(m => m.setMap(null));
    dangerousAreaMarkers = [];
    if (!Array.isArray(window.dangerousAreas)) return;

    const listEl = document.getElementById('dangerousAreaList');
    if (listEl) listEl.innerHTML = '';

    window.dangerousAreas.forEach(a => {
        const m = new kakao.maps.Marker({ position: new kakao.maps.LatLng(a.lat, a.lng), map });
        const iw = new kakao.maps.InfoWindow({
            content: `<div style="padding:6px 10px"><div style="font-weight:700">${a.name}</div><div style="font-size:12px;color:#666">${a.description||''}</div></div>`
        });
        kakao.maps.event.addListener(m, 'click', ()=> iw.open(map, m));
        dangerousAreaMarkers.push(m);

        if (listEl) {
            const row = document.createElement('div');
            row.className = 'text-sm text-gray-300';
            row.textContent = `${a.name} • ${a.riskLevel}`;
            listEl.appendChild(row);
        }
    });
}

/* ---------------- 현재 위치 ---------------- */
function updateCurrentLocationMarker(location, accuracy = 0, { center = false } = {}) {
    const pos = new kakao.maps.LatLng(location.lat, location.lng);
    if (currentLocationMarker) currentLocationMarker.setPosition(pos);
    else currentLocationMarker = new kakao.maps.Marker({ position: pos, map });

    if (center || (window.followUser === true)) map.panTo(pos);

    const pad = n => String(n).padStart(2, '0');
    const t = new Date();
    const ts = `${pad(t.getHours())}:${pad(t.getMinutes())}:${pad(t.getSeconds())}`;
    const L = (id, v) => { const el = document.getElementById(id); if (el) el.innerText = v; };
    L('lat', location.lat.toFixed(6));
    L('lng', location.lng.toFixed(6));
    L('time', ts);
}

function initGeolocation() {
    if (!navigator.geolocation) { enableManualLocation(); return; }
    navigator.geolocation.getCurrentPosition(
        pos => {
            updateCurrentLocationMarker({ lat: pos.coords.latitude, lng: pos.coords.longitude }, 0, { center: false });
        },
        _ => enableManualLocation(),
        { enableHighAccuracy: true, timeout: 20000, maximumAge: 5000 }
    );
}

function enableManualLocation() {
    kakao.maps.event.addListener(map,'click',e=>{
        const p=e.latLng; updateCurrentLocationMarker({lat:p.getLat(), lng:p.getLng()});
        alert('수동 위치 설정 완료');
    });
}

// 위치 추적 on/off/이동
window.startGPSTracking = function () {
    followUser = true;
    if (gpsWatchId) navigator.geolocation.clearWatch(gpsWatchId);
    gpsWatchId = navigator.geolocation.watchPosition(
        pos => updateCurrentLocationMarker({ lat: pos.coords.latitude, lng: pos.coords.longitude }),
        err => console.error('GPS 오류:', err),
        { enableHighAccuracy: true, maximumAge: 0, timeout: 20000 }
    );
};
window.stopGPSTracking = function () {
    followUser = false;
    if (gpsWatchId) navigator.geolocation.clearWatch(gpsWatchId);
    gpsWatchId = null;
};
window.toggleGPSTrack = function (btnEl) {
    if (gpsWatchId) { window.stopGPSTracking(); btnEl && (btnEl.textContent = '위치 추적 시작'); }
    else { followUser = true; window.startGPSTracking(); btnEl && (btnEl.textContent = '위치 추적 중지'); }
};
window.recenterToMe = function () {
    if (!currentLocationMarker) return;
    map.panTo(currentLocationMarker.getPosition());
};

/* ---------------- 추천 경로 UI ---------------- */
function initRecommendedRoutes() {
    const listEl = document.getElementById('routeList');
    window.toggleRoutes = () => {
        if (listEl.classList.toggle('hidden')) return;
        listEl.innerHTML = '';
        (window.recommendedRoutes || []).forEach(r => {
            const item = document.createElement('div');
            item.className = 'border p-2 rounded bg-gray-700 cursor-pointer hover:bg-gray-600 transition';
            item.innerHTML = `<strong>${r.name}</strong><br/>거리: ${r.distance}, 시간: ${r.duration}`;
            item.addEventListener('click', () => {
                const route = { ...r };
                if ((!route.start || !route.end) && Array.isArray(route.points) && route.points.length >= 2) {
                    route.start = { lat: route.points[0].lat,     lng: route.points[0].lng };
                    route.end   = { lat: route.points.at(-1).lat, lng: route.points.at(-1).lng };
                }
                drawRoute(route);
            });
            listEl.appendChild(item);
        });
    };
}

/* ---------------- 카카오 길찾기 ---------------- */
function setStartMarker(p){
    const ll=new kakao.maps.LatLng(p.lat,p.lng);
    if (!startMarker) startMarker = new kakao.maps.Marker({ position: ll, map });
    else startMarker.setPosition(ll);
}
function setEndMarker(p){
    const ll=new kakao.maps.LatLng(p.lat,p.lng);
    if (!endMarker) endMarker = new kakao.maps.Marker({ position: ll, map });
    else endMarker.setPosition(ll);
}
function decodeVertexes(vs){
    const out=[]; for(let i=0;i<vs.length;i+=2){ out.push(new kakao.maps.LatLng(vs[i+1], vs[i])); } // [x,y]=[lng,lat]
    return out;
}
function drawPath(path) {
    if (routePolyline) routePolyline.setMap(null);
    routePolyline = new kakao.maps.Polyline({ map, path, strokeWeight: 6, strokeColor: '#22c55e', strokeOpacity: 0.9 });
    const b = new kakao.maps.LatLngBounds();
    path.forEach(p => b.extend(p));
    map.setBounds(b);
}
async function fetchDirections(start,end){
    if (!window.KAKAO_REST_KEY) throw new Error('Kakao REST 키가 없습니다.');
    const origin=`${start.lng},${start.lat}`;
    const dest  =`${end.lng},${end.lat}`;
    const url=`https://apis-navi.kakaomobility.com/v1/directions?origin=${origin}&destination=${dest}&priority=RECOMMEND`;
    const res=await fetch(url,{ headers:{ Authorization:'KakaoAK '+window.KAKAO_REST_KEY }});
    if(!res.ok) throw new Error('Kakao API HTTP '+res.status);
    return res.json();
}

// 카카오 응답에서 간단 안내(steps) 추출
function extractStepsFromKakao(data){
    const steps = [];
    const routes = data?.routes || [];
    routes.forEach(r =>
        (r.sections || []).forEach(sec => {
            if (sec.guides && sec.guides.length) {
                sec.guides.forEach(g => {
                    const t = g.name || g.instructions || g.description || g.message || g.road_name;
                    if (t) steps.push({ instructions: String(t) });
                });
                return;
            }
            (sec.roads || []).forEach(rd => {
                const t = rd.name || rd.description;
                if (t) steps.push({ instructions: String(t) });
            });
        })
    );
    return steps;
}

/* ---------------- 경로 탐색 메인 ---------------- */
async function drawRoute(route){
    try{
        const start = route?.start || (currentLocationMarker
            ? { lat: currentLocationMarker.getPosition().getLat(), lng: currentLocationMarker.getPosition().getLng() }
            : SEOUL_CITY_HALL);
        const end   = route?.end || { lat: 37.5410, lng: 126.9860 }; // 서울역 근방

        setStartMarker(start); setEndMarker(end);

        const data = await fetchDirections(start, end);
        if (!data?.routes?.length) {
            hasJoinedRoute = false;
            document.getElementById('offRouteWarning')?.classList.add('hidden');

            drawPath([ new kakao.maps.LatLng(start.lat,start.lng),
                new kakao.maps.LatLng(end.lat,end.lng) ]);
            alert('경로를 찾지 못해 직선 경로를 표시합니다.');
            return;
        }

        const path=[];
        (data.routes[0].sections||[]).forEach(sec=>{
            (sec.roads||[]).forEach(r=>{ path.push(...decodeVertexes(r.vertexes||[])); });
        });

        if (!path.length) {
            drawPath([ new kakao.maps.LatLng(start.lat,start.lng),
                new kakao.maps.LatLng(end.lat,end.lng) ]);
            return;
        }

        drawPath(path);

        // 안내/칩 갱신
        window.currentRouteSteps = extractStepsFromKakao(data);
        window.currentStepIndex  = 0;
        showSmallVoiceUI();

        // 내비 감시 시작
        startNavigationWatch();
    }catch(e){
        console.error('[Directions] error:', e);
        alert('길찾기 오류: '+e.message);
    }
}

/* ---------------- 경로 이탈 감지 ---------------- */
function llToMeters(lat, lng) {
    const R = 6378137;
    const x = (lng * Math.PI / 180) * R;
    const y = Math.log(Math.tan(Math.PI / 4 + (lat * Math.PI / 360))) * R;
    return { x, y };
}
function pointSegDistMeters(px, py, ax, ay, bx, by) {
    const p = { x: px, y: py }, a = { x: ax, y: ay }, b = { x: bx, y: by };
    const abx = b.x - a.x, aby = b.y - a.y;
    const apx = p.x - a.x, apy = p.y - a.y;
    const ab2 = abx * abx + aby * aby;
    let t = ab2 === 0 ? 0 : (apx * abx + apy * aby) / ab2;
    t = Math.max(0, Math.min(1, t));
    const projx = a.x + abx * t, projy = a.y + aby * t;
    const dx = px - projx, dy = py - projy;
    return Math.hypot(dx, dy);
}
function distanceToPolylineMeters(lat, lng, path) {
    if (!path || path.length < 2) return Infinity;
    const p = llToMeters(lat, lng);
    let min = Infinity;
    for (let i = 0; i < path.length - 1; i++) {
        const a = llToMeters(path[i].getLat(),   path[i].getLng());
        const b = llToMeters(path[i+1].getLat(), path[i+1].getLng());
        const d = pointSegDistMeters(p.x, p.y, a.x, a.y, b.x, b.y);
        if (d < min) min = d;
    }
    return min;
}

function startNavigationWatch() {
    if (!routePolyline) return;
    const path = routePolyline.getPath();
    if (!path || path.length < 2) return;

    if (gpsWatchId) navigator.geolocation.clearWatch(gpsWatchId);

    gpsWatchId = navigator.geolocation.watchPosition(
        pos => {
            const { latitude: lat, longitude: lng, accuracy } = pos.coords;
            if (typeof accuracy === 'number' && accuracy > 100) {
                updateCurrentLocationMarker({ lat, lng }); // 표시만
                return;
            }

            updateCurrentLocationMarker({ lat, lng });

            const dist = distanceToPolylineMeters(lat, lng, path);

            // 아직 합류 전이면 합류만 체크
            if (!hasJoinedRoute) {
                if (dist <= JOIN_THRESHOLD_M) hasJoinedRoute = true;
                return;
            }

            // 합류 후엔 이탈 체크
            const warn = document.getElementById('offRouteWarning');
            if (dist > OFF_ROUTE_THRESHOLD_M) warn?.classList.remove('hidden');
            else warn?.classList.add('hidden');

            // 칩 업데이트(선택)
            onGpsTickForVoice();
        },
        err => {
            console.error('내비게이션 오류:', err);
            alert('내비게이션 오류: ' + err.message);
        },
        { enableHighAccuracy: true, maximumAge: 5000, timeout: 20000 }
    );
}
window.handleReroute = function () {
    document.getElementById('offRouteWarning')?.classList.add('hidden');
    hasJoinedRoute = false;
    if (!startMarker || !endMarker) return;
    const s = { lat: startMarker.getPosition().getLat(), lng: startMarker.getPosition().getLng() };
    const e = { lat: endMarker.getPosition().getLat(),   lng: endMarker.getPosition().getLng() };
    drawRoute({ start: s, end: e });
};
window.stopNavigation = function(){
    if (gpsWatchId) navigator.geolocation.clearWatch(gpsWatchId);
    gpsWatchId=null;
    document.getElementById('offRouteWarning')?.classList.add('hidden');
};

/* ---------------- 검색 보조 ---------------- */
let placesServiceStub; // (미사용) 이름 충돌 방지용
function resolvePlace(text, datasetLat, datasetLng) {
    return new Promise((resolve, reject) => {
        if (!isNaN(parseFloat(datasetLat)) && !isNaN(parseFloat(datasetLng))) {
            return resolve({ lat: parseFloat(datasetLat), lng: parseFloat(datasetLng) });
        }
        if (!text || !text.trim()) return reject(new Error('검색어가 없습니다.'));

        placesService.keywordSearch(text, (data, status) => {
            if (status !== kakao.maps.services.Status.OK || !data.length) {
                return reject(new Error('검색 결과가 없습니다.'));
            }
            const t = data[0];
            resolve({ lat: parseFloat(t.y), lng: parseFloat(t.x), name: t.place_name });
        }, { size: 5 });
    });
}

/* ---------------- 하단 도크(작은 안내) ---------------- */
function _stepText(step) {
    if (!step) return '';
    if (typeof step === 'string') return step;
    const raw = step.instructions || step.text || step.description || '';
    return String(raw).replace(/<[^>]+>/g, '');
}
function renderVoiceList() {
    const itemsEl = document.getElementById('voiceItems');
    if (!itemsEl) return;
    itemsEl.innerHTML = '';
    (window.currentRouteSteps || []).forEach((step, i) => {
        const div = document.createElement('div');
        div.textContent = `${i + 1}. ${_stepText(step)}`;
        itemsEl.appendChild(div);
    });
}
function updateVoiceChip() {
    const chipEl = document.getElementById('voiceChip');
    if (!chipEl) return;
    const next = (window.currentRouteSteps || [])[window.currentStepIndex || 0];
    chipEl.textContent = `다음: ${_stepText(next) || '안내 없음'}`;
    chipEl.classList.remove('hidden');
}
window.toggleVoicePanel = function () {
    const panel = document.getElementById('voiceList');
    if (!panel) return;
    panel.classList.toggle('hidden');
};
window.showSmallVoiceUI = function () {
    renderVoiceList();
    updateVoiceChip();
};
window.onGpsTickForVoice = function () {
    updateVoiceChip();
};
