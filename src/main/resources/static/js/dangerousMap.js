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

// ---- SDK 로드 후 초기화 ----
if (window.kakao && kakao.maps && kakao.maps.load) {
    kakao.maps.load(initKakao);
} else {
    window.addEventListener('load', () => kakao.maps.load(initKakao));
}

function initKakao() {
    map = new kakao.maps.Map(document.getElementById('map'), {
        center: new kakao.maps.LatLng(SEOUL_CITY_HALL.lat, SEOUL_CITY_HALL.lng),
        level: 4
    });
    map.addControl(new kakao.maps.ZoomControl(), kakao.maps.ControlPosition.RIGHT);

    kakaoPlaces   = new kakao.maps.services.Places();
    kakaoGeocoder = new kakao.maps.services.Geocoder();
    placesService = kakaoPlaces;

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