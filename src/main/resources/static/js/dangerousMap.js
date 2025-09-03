/* Kakao Maps 기반 내비 + RG 다크 UI + 위험구간 색분할 오버레이 (경로찾기 즉시 반영 버전)
   - 경로 포함 지점만 표시: SHOW_ONLY_ROUTE_HAZARDS=true
   - 말풍선(타이틀/배지) 색상 = riskColorOf(사고건수 규칙)과 동기화
*/

/* ───────────────────────────── 기본 상수/상태 ───────────────────────────── */
const SEOUL_CITY_HALL = { lat: 37.5665, lng: 126.9780 };

let map;                          // kakao.maps.Map
let gpsWatchId = null;
let currentLocationMarker = null; // kakao.maps.Marker
let dangerousAreaMarkers = [];
let dangerousAreaOverlays = [];
let routePolyline = null;         // 기본(초록) 경로
let routeHazardPolylines = [];    // 위험구간 오버레이(주황/빨강)
let startMarker = null;
let endMarker = null;

let hasJoinedRoute = false;
const JOIN_THRESHOLD_M = 120;
const OFF_ROUTE_THRESHOLD_M = 120;

// 검색/지오코더
let kakaoPlaces = null;           // kakao.maps.services.Places
let kakaoGeocoder = null;         // kakao.maps.services.Geocoder
let placesService = null;         // 별칭

// 지도를 자동으로 따라갈지 여부
let followUser = false;

// ★ 경로 포함 지점만 보여줄지 여부 + 버퍼(m)
const SHOW_ONLY_ROUTE_HAZARDS = true;
const ROUTE_HAZARD_BUFFER_M = 10;

/* ───────────────────────────── SDK 로드/초기화 ───────────────────────────── */
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

    // 첫 렌더
    updateDangerousAreaMarkers();
    initRecommendedRoutes();
    initGeolocation();

    // 입력/버튼
    bindPlaceSearch();
    bindAutocomplete('#startInput');
    bindAutocomplete('#endInput');

    // RG UI
    injectMapUiCss();
    mountMapUI();
}

/* ───────────────────────────── Hotspot 공통 스타일 ───────────────────────────── */
(function injectHotspotCss(){
    if (document.getElementById('rg-hotspot-style')) return;
    const css = '\
  .rg-hotspot{position:relative;min-width:240px;border-radius:10px;background:#fff;color:#111;border:1px solid #1e293b;box-shadow:0 8px 24px rgba(0,0,0,.25)}\
  .rg-hotspot .rg-title{background:#2563eb;color:#fff;font-weight:800;font-size:14px;padding:8px 10px;border-radius:10px 10px 0 0}\
  .rg-hotspot .rg-body{padding:8px 10px;font-size:12px;color:#111;display:flex;align-items:center;gap:8px}\
  .rg-hotspot *{color:inherit!important}\
  .rg-hotspot::after{content:"";position:absolute;left:22px;bottom:-10px;border-width:10px;border-style:solid;border-color:#fff transparent transparent transparent;filter:drop-shadow(0 -1px 0 rgba(0,0,0,.2))}\
  .rg-badge{display:inline-block;background:#2563eb;color:#fff;border-radius:6px;padding:2px 6px;font-size:11px;font-weight:700}';
    const s = document.createElement('style');
    s.id = 'rg-hotspot-style';
    s.textContent = css;
    document.head.appendChild(s);
})();

/* ───────────────────────────── 유틸/공통 ───────────────────────────── */
function _esc(s){ return String(s == null ? '' : s).replace(/[&<>\"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m])); }

function isFiniteNumber(v){ v = Number(v); return Number.isFinite(v); }

// ✅ 사고 건수 → 위험레벨: 6+ high, 5 medium, 4- low
function riskLevelFromIncidents(inc) {
    const n = Number(inc) || 0;
    if (n >= 6) return 'high';
    if (n === 5) return 'medium';
    return 'low';
}

function riskColorOf(level) {
    switch (String(level || '').toLowerCase()) {
        case 'high':   return '#ef4444';
        case 'medium': return '#f59e0b';
        default:       return '#22c55e';
    }
}

function smallDotMarkerImage(color, size=12) {
    const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${size}" height="${size}"><circle cx="${size/2}" cy="${size/2}" r="${(size/2)-1}" fill="${color}" stroke="#111" stroke-width="1"/></svg>`;
    const url = 'data:image/svg+xml;charset=UTF-8,' + encodeURIComponent(svg);
    return new kakao.maps.MarkerImage(url, new kakao.maps.Size(size, size));
}
function metersBetween(lat1,lng1,lat2,lng2){
    const R=6371000, toRad=d=>d*Math.PI/180;
    const dLat=toRad(lat2-lat1), dLng=toRad(lat2-lng1?lng1:lng1); // no-op guard
    const dLng2=toRad(lat2?lng2:lng2); /* keep structure */
    const dLat2=toRad(lat2-lat1);
    // 원본 수식
    const dLatX=toRad(lat2-lat1), dLngX=toRad(lng2-lng1);
    const a=Math.sin(dLatX/2)**2 + Math.cos(toRad(lat1))*Math.cos(toRad(lat2))*Math.sin(dLngX/2)**2;
    return 2*R*Math.asin(Math.sqrt(a));
}
function normalizeDangerAreas(arr){
    if (!Array.isArray(arr)) return [];
    return arr.map(d=>{
        const lat = [d.lat,d.latitude,d.Lat,d.LAT,d.y].find(isFiniteNumber);
        const lng = [d.lng,d.long,d.longitude,d.Lng,d.LNG,d.x].find(isFiniteNumber);
        const incidents = [d.incidents,d.accidentCount,d.accidents,d.cnt,d.count].find(v=>v!=null);
        const risk = riskLevelFromIncidents(incidents); // 서버 riskLevel 무시하고 재계산
        return {
            id: d.id || d.uid || ((d.name||'지점')+'@'+lat+','+lng),
            name: d.name || d.title || d.placeName || d.road_name || '지점',
            description: d.description || d.desc || d.memo || '',
            incidents: Number(incidents||0),
            riskLevel: String(risk||'low').toLowerCase(),
            lat: Number(lat), lng: Number(lng)
        };
    }).filter(a=>isFiniteNumber(a.lat)&&isFiniteNumber(a.lng));
}

/* ───────────────────────────── 위험지역 마커 렌더 ───────────────────────────── */
// 🔄 말풍선 색상을 위험레벨에 맞춰 동적으로 적용
function showHotspotOverlay(map, lat, lng, name, description, incidents, riskLevel){
    const level = (riskLevel && String(riskLevel).toLowerCase()) || riskLevelFromIncidents(incidents);
    const color = riskColorOf(level);

    const s = String(description || '');
    const i = s.indexOf('사고건수');
    const cleanDesc = i > -1 ? s.slice(0, i).replace(/[|•]\s*$/,'').trim() : s;

    const wrap = document.createElement('div');
    wrap.className = 'rg-hotspot';
    wrap.innerHTML = `
    <div class="rg-title" style="background:${color}">${_esc(name)}</div>
    <div class="rg-body">
      ${cleanDesc ? `<span>${_esc(cleanDesc)}</span>` : ''}
      ${Number.isFinite(incidents) ? `<span class="rg-badge" style="background:${color}">사고건수 ${incidents}</span>` : ''}
    </div>`;
    return new kakao.maps.CustomOverlay({
        position: new kakao.maps.LatLng(lat, lng),
        content: wrap,
        xAnchor: 0.15, yAnchor: 1.15, zIndex: 80
    });
}

function updateDangerousAreaMarkers() {
    // 제거
    dangerousAreaMarkers.forEach(m=>m.setMap(null));
    dangerousAreaOverlays.forEach(o=>o.setMap && o.setMap(null));
    dangerousAreaMarkers = [];
    dangerousAreaOverlays = [];

    // 데이터(정규화)
    const src = normalizeDangerAreas(window.dangerousAreas || []);
    const listEl = document.getElementById('dangerousAreaList');

    if (!src.length){
        if (listEl) listEl.innerHTML = '<div class="text-sm text-gray-400">데이터 없음</div>';
        setDangerCount?.(0);
        if (routePolyline) drawColoredRoute(routePolyline.getPath());
        return;
    }

    // ★ 경로 포함 필터 우선 적용
    let dataset = hazardsNearRouteOnly(src);

    // 경로가 없거나, 경로 필터가 꺼져있으면 지도 중심 반경으로 대체
    let filtered;
    const path = (routePolyline && routePolyline.getPath) ? routePolyline.getPath() : null;
    if (SHOW_ONLY_ROUTE_HAZARDS && path && path.length >= 2) {
        filtered = dataset;
    } else {
        const center = map.getCenter();
        const RADIUS_M = 3000;
        filtered = dataset.filter(a => metersBetween(center.getLat(),center.getLng(), a.lat,a.lng) <= RADIUS_M);
        if (!filtered.length) filtered = dataset.slice(0, Math.min(20, dataset.length));
    }

    if (listEl) listEl.innerHTML = '';

    const bounds = new kakao.maps.LatLngBounds();
    const closeAll = () => dangerousAreaOverlays.forEach(ov => ov.setMap && ov.setMap(null));

    filtered.forEach(a=>{
        const pos = new kakao.maps.LatLng(a.lat, a.lng);
        const color = riskColorOf(a.riskLevel);
        const image = smallDotMarkerImage(color, 12);

        const marker = new kakao.maps.Marker({ position: pos, image, zIndex: 60 });
        marker.setMap(map);
        dangerousAreaMarkers.push(marker);
        bounds.extend(pos);

        // ✅ riskLevel 전달하여 말풍선 색 동기화
        const overlay = showHotspotOverlay(map, a.lat, a.lng, a.name, a.description, a.incidents, a.riskLevel);
        dangerousAreaOverlays.push(overlay);

        kakao.maps.event.addListener(marker, 'click', ()=>{
            const opened = overlay.getMap();
            closeAll();
            overlay.setMap(opened ? null : map);
            requestAnimationFrame(()=>map.relayout());
        });

        if (listEl){
            const row = document.createElement('div');
            row.className = 'text-sm text-gray-200 flex items-center gap-2';
            row.innerHTML = `
        <span style="display:inline-block;width:10px;height:10px;border-radius:50%;background:${color};border:1px solid #111"></span>
        <button type="button" class="hover:underline">${_esc(a.name)} · ${_esc(a.riskLevel)}</button>`;
            row.querySelector('button').addEventListener('click', ()=>{
                map.panTo(pos);
                const opened = overlay.getMap();
                closeAll();
                overlay.setMap(opened ? null : map);
                requestAnimationFrame(()=>map.relayout());
            });
            listEl.appendChild(row);
        }
    });

    if (filtered.length){
        map.setBounds(bounds);
        setTimeout(()=>{ try{ map.setLevel(Math.max(1, map.getLevel()-1)); }catch(e){} },0);
    }
    kakao.maps.event.addListener(map,'click',()=>closeAll());

    // 좌하단 상태카드 갱신 + 경로 재색칠
    setDangerCount?.(dangerousAreaMarkers.length);
    if (routePolyline) drawColoredRoute(routePolyline.getPath());
}

/* ───────────────────────────── 서버/DB 로드 ───────────────────────────── */
function _basePath() {
    return document.documentElement.getAttribute('data-context-path') || '';
}
window.loadDangerousAreasFromDb = async function (radiusM=3000, limit=300) {
    try {
        if (!window.map) throw new Error('지도 초기화 전입니다.');
        const c = map.getCenter();
        const url = _basePath()+`/map/hotspots/near?lat=${c.getLat()}&lng=${c.getLng()}&radiusM=${radiusM}&limit=${limit}`;

        const res = await fetch(url);
        if (!res.ok) throw new Error('서버 오류 '+res.status+' '+(await res.text().catch(()=>'')));

        const data = await res.json();
        window.dangerousAreas = normalizeDangerAreas(data);

        // ★ 경로가 있으면 경로 인접만 유지
        applyRouteHazardFilter();

        updateDangerousAreaMarkers();
        if (routePolyline) drawColoredRoute(routePolyline.getPath());
    } catch (e) {
        console.error('DB 로드 실패:', e);
        alert('사고다발지역 로드 실패: ' + e.message);
    }
};

// ★★★ 경로찾기 즉시 반영용: 경로를 따라 위험지역 프리로드 유틸들
function mergeAreas(base = [], add = []) {
    const key = a => a.id || `${a.lat.toFixed(5)},${a.lng.toFixed(5)}`;
    const m = new Map();
    normalizeDangerAreas(base).forEach(a => m.set(key(a), a));
    normalizeDangerAreas(add).forEach(a => m.set(key(a), a));
    return Array.from(m.values());
}
// 경로상의 임의 지점(lat,lng) 기준으로 조회
async function loadDangerousAreasAt(lat, lng, radiusM = 1200, limit = 200) {
    const url = _basePath() + `/map/hotspots/near?lat=${lat}&lng=${lng}&radiusM=${radiusM}&limit=${limit}`;
    const res = await fetch(url);
    if (!res.ok) throw new Error('서버 오류 ' + res.status + ' ' + (await res.text().catch(()=>'')));
    const data = await res.json();
    const norm = normalizeDangerAreas(data);
    window.dangerousAreas = mergeAreas(window.dangerousAreas || [], norm);

    // ★ 경로가 있으면 경로 인접만 유지
    applyRouteHazardFilter();

    return norm;
}
// Polyline path를 따라 일정 간격으로 서버 다건 조회 후 합치기
async function preloadHazardsAlongRoute(path) {
    if (!path || path.length < 2) return;

    const SPACING_M = 800; // 800m마다 한 번씩 조회
    const picks = [];
    let last = path[0];
    picks.push(last);

    for (let i = 1; i < path.length; i++) {
        const cur = path[i];
        const d = metersBetween(last.getLat(), last.getLng(), cur.getLat(), cur.getLng());
        if (d >= SPACING_M) {
            picks.push(cur);
            last = cur;
        }
    }
    // 시작/끝 보장
    if (picks[0] !== path[0]) picks.unshift(path[0]);
    const end = path[path.length - 1];
    if (picks[picks.length - 1] !== end) picks.push(end);

    // 병렬 로딩
    await Promise.all(
        picks.map(p => loadDangerousAreasAt(p.getLat(), p.getLng(), 1000, 180).catch(()=>{}))
    );

    // 마커/리스트 갱신
    updateDangerousAreaMarkers();
}

/* ───────────────────────────── 현재 위치/GPS ───────────────────────────── */
function updateCurrentLocationMarker(location, accuracy=0, opts={}) {
    const pos = new kakao.maps.LatLng(location.lat, location.lng);
    if (currentLocationMarker) currentLocationMarker.setPosition(pos);
    else currentLocationMarker = new kakao.maps.Marker({ position: pos, map });

    if (opts.center || (window.followUser === true)) map.panTo(pos);

    const pad = n => (String(n).length<2 ? '0'+n : String(n));
    const t = new Date();
    const ts = `${pad(t.getHours())}:${pad(t.getMinutes())}:${pad(t.getSeconds())}`;
    const L = (id,v)=>{ const el=document.getElementById(id); if(el) el.innerText=v; };
    L('lat', location.lat.toFixed(6));
    L('lng', location.lng.toFixed(6));
    L('time', ts);
}
function initGeolocation() {
    if (!navigator.geolocation) { enableManualLocation(); return; }
    navigator.geolocation.getCurrentPosition(
        pos => updateCurrentLocationMarker({ lat: pos.coords.latitude, lng: pos.coords.longitude }, 0, { center: false }),
        ()  => enableManualLocation(),
        { enableHighAccuracy: true, timeout: 20000, maximumAge: 5005 }
    );
}
function enableManualLocation() {
    kakao.maps.event.addListener(map,'click',e=>{
        const p=e.latLng; updateCurrentLocationMarker({lat:p.getLat(), lng:p.getLng()});
        alert('수동 위치 설정 완료');
    });
}
window.startGPSTracking = function () {
    followUser = true;
    if (gpsWatchId) navigator.geolocation.clearWatch(gpsWatchId);
    gpsWatchId = navigator.geolocation.watchPosition(
        pos => {
            const lat = pos.coords.latitude;
            const lng = pos.coords.longitude;
            updateCurrentLocationMarker({ lat, lng });

            // 경로 유무와 상관없이 안내/색칠 유지
            const path = routePolyline && routePolyline.getPath ? routePolyline.getPath() : null;
            ensureFreshHazards(lat, lng, path);
            checkAndNotifyHazard(lat, lng, path);
        },
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

/* ───────────────────────────── 추천 경로 UI ───────────────────────────── */
function initRecommendedRoutes() {
    const listEl = document.getElementById('routeList');
    window.toggleRoutes = function(){
        if (listEl.classList.toggle('hidden')) return;
        listEl.innerHTML = '';
        (window.recommendedRoutes || []).forEach(r=>{
            const item = document.createElement('div');
            item.className = 'border p-2 rounded bg-gray-700 cursor-pointer hover:bg-gray-600 transition';
            item.innerHTML = `<strong>${r.name}</strong><br/>거리: ${r.distance}, 시간: ${r.duration}`;
            item.addEventListener('click', ()=>{
                const route = { ...r };
                if ((!route.start || !route.end) && Array.isArray(route.points) && route.points.length >= 2) {
                    route.start = { lat: route.points[0].lat, lng: route.points[0].lng };
                    route.end   = { lat: route.points[route.points.length-1].lat, lng: route.points[route.points.length-1].lng };
                }
                drawRoute(route);
            });
            listEl.appendChild(item);
        });
    };
}

/* ───────────────────────────── 길찾기/경로 ───────────────────────────── */
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
    routePolyline = new kakao.maps.Polyline({ map, path, strokeWeight: 6, strokeColor: '#22c55e', strokeOpacity: 0.9, zIndex: 40 });
    const b = new kakao.maps.LatLngBounds();
    path.forEach(p=>b.extend(p));
    map.setBounds(b);
}
async function fetchDirections(start,end){
    if (!window.KAKAO_REST_KEY) throw new Error('Kakao REST 키가 없습니다.');
    const origin= `${start.lng},${start.lat}`;
    const dest  = `${end.lng},${end.lat}`;
    const url='https://apis-navi.kakaomobility.com/v1/directions?origin='+origin+'&destination='+dest+'&priority=RECOMMEND';
    const res=await fetch(url,{ headers:{ Authorization:'KakaoAK '+window.KAKAO_REST_KEY }});
    if(!res.ok) throw new Error('Kakao API HTTP '+res.status);
    return res.json();
}
function extractStepsFromKakao(data){
    const steps = [];
    const routes = data && data.routes ? data.routes : [];
    routes.forEach(r=>{
        (r.sections || []).forEach(sec=>{
            if (sec.guides && sec.guides.length) {
                sec.guides.forEach(g=>{
                    const t = g.name || g.instructions || g.description || g.message || g.road_name;
                    if (t) steps.push({ instructions: String(t) });
                });
                return;
            }
            (sec.roads || []).forEach(rd=>{
                const t = rd.name || rd.description;
                if (t) steps.push({ instructions: String(t) });
            });
        });
    });
    return steps;
}

async function drawRoute(route){
    try{
        const start = (route && route.start) || (currentLocationMarker
            ? { lat: currentLocationMarker.getPosition().getLat(), lng: currentLocationMarker.getPosition().getLng() }
            : SEOUL_CITY_HALL);
        const end   = (route && route.end) || { lat: 37.5410, lng: 126.9860 }; // 서울역 근방

        setStartMarker(start); setEndMarker(end);

        const data = await fetchDirections(start, end);
        if (!(data && data.routes && data.routes.length)) {
            hasJoinedRoute = false;
            const w = document.getElementById('offRouteWarning'); if (w) w.classList.add('hidden');

            const fallback = [ new kakao.maps.LatLng(start.lat,start.lng), new kakao.maps.LatLng(end.lat,end.lng) ];
            drawPath(fallback);

            // ★ 경로가 직선이라도 프리로드 → 경로 필터 → 색칠
            await preloadHazardsAlongRoute(fallback);
            applyRouteHazardFilter();
            drawColoredRoute(fallback);

            alert('경로를 찾지 못해 직선 경로를 표시합니다.');
            return;
        }

        const path=[];
        (data.routes[0].sections||[]).forEach(sec=>{
            (sec.roads||[]).forEach(r=>{ path.push(...decodeVertexes(r.vertexes||[])); });
        });
        if (!path.length) {
            const fallback = [ new kakao.maps.LatLng(start.lat,start.lng), new kakao.maps.LatLng(end.lat,end.lng) ];
            drawPath(fallback);
            await preloadHazardsAlongRoute(fallback);
            applyRouteHazardFilter();
            drawColoredRoute(fallback);
            return;
        }

        // ① 기본(초록) 경로 먼저 그리기
        drawPath(path);

        // ② 경로를 따라 위험지역 미리 로딩
        await preloadHazardsAlongRoute(path);

        // ★ 경로 포함 지점만 남김
        applyRouteHazardFilter();

        // ③ 위험구간 오버레이(주황/빨강) 즉시 반영
        drawColoredRoute(path);

        // 내비(음성) 준비
        window.currentRouteSteps = extractStepsFromKakao(data);
        window.currentStepIndex  = 0;
        showSmallVoiceUI();
        startNavigationWatch();
    }catch(e){
        console.error('[Directions] error:', e);
        alert('길찾기 오류: '+e.message);
    }
}

/* ───────────────────────────── 경로 이탈 감지 ───────────────────────────── */
function llToMeters(lat, lng) {
    const R = 6378137;
    const x = (lng * Math.PI / 180) * R;
    const y = Math.log(Math.tan(Math.PI / 4 + (lat * Math.PI / 360))) * R;
    return { x, y };
}
function pointSegDistMeters(px, py, ax, ay, bx, by) {
    const abx = bx - ax, aby = by - ay;
    const apx = px - ax, apy = py - ay;
    const ab2 = abx*abx + aby*aby;
    let t = ab2 === 0 ? 0 : (apx*abx + apy*aby) / ab2;
    t = Math.max(0, Math.min(1, t));
    const projx = ax + abx*t, projy = ay + aby*t;
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

/* ───────────────────────────── 경로 포함 필터 유틸 ───────────────────────────── */
function routeRadiusForZone(z) {
    const rad = RISK_RADIUS[(z.riskLevel || 'low').toLowerCase()] || RISK_RADIUS.low;
    return rad + ROUTE_HAZARD_BUFFER_M; // 위험반경 + 여유
}
function hazardsNearRouteOnly(list) {
    if (!SHOW_ONLY_ROUTE_HAZARDS) return list;
    if (!routePolyline || !routePolyline.getPath) return list;
    const path = routePolyline.getPath();
    if (!path || path.length < 2) return list;
    return list.filter(z => distanceToPolylineMeters(z.lat, z.lng, path) <= routeRadiusForZone(z));
}
function applyRouteHazardFilter() {
    if (!Array.isArray(window.dangerousAreas)) return;
    window.dangerousAreas = hazardsNearRouteOnly(window.dangerousAreas);
}

/* ───────────────────────────── 경로 이탈 감지 계속 ───────────────────────────── */
function startNavigationWatch() {
    if (!routePolyline) return;
    const path = routePolyline.getPath();
    if (!path || path.length < 2) return;

    if (gpsWatchId) navigator.geolocation.clearWatch(gpsWatchId);

    gpsWatchId = navigator.geolocation.watchPosition(
        pos=>{
            const { latitude:lat, longitude:lng, accuracy } = pos.coords;
            if (typeof accuracy === 'number' && accuracy > 100) {
                updateCurrentLocationMarker({ lat, lng }); // 표시만
                return;
            }
            updateCurrentLocationMarker({ lat, lng });

            const dist = distanceToPolylineMeters(lat, lng, path);

            if (!hasJoinedRoute) {
                if (dist <= JOIN_THRESHOLD_M) hasJoinedRoute = true;
                return;
            }

            const warn = document.getElementById('offRouteWarning');
            if (dist > OFF_ROUTE_THRESHOLD_M) { if (warn) warn.classList.remove('hidden'); }
            else { if (warn) warn.classList.add('hidden'); }

            onGpsTickForVoice();

            // ★ 주행 중에도 최신 위험지점 반영 + 안내
            ensureFreshHazards(lat, lng, path);
            checkAndNotifyHazard(lat, lng, path);
        },
        err=>{
            console.error('내비게이션 오류:', err);
            alert('내비게이션 오류: ' + err.message);
        },
        { enableHighAccuracy: true, maximumAge: 5000, timeout: 20000 }
    );
}
window.handleReroute = function () {
    const w = document.getElementById('offRouteWarning'); if (w) w.classList.add('hidden');
    hasJoinedRoute = false;
    if (!startMarker || !endMarker) return;
    const s = { lat: startMarker.getPosition().getLat(), lng: startMarker.getPosition().getLng() };
    const e = { lat: endMarker.getPosition().getLat(),   lng: endMarker.getPosition().getLng() };
    drawRoute({ start: s, end: e });
};
window.stopNavigation = function(){
    if (gpsWatchId) navigator.geolocation.clearWatch(gpsWatchId);
    gpsWatchId=null;
    const w = document.getElementById('offRouteWarning'); if (w) w.classList.add('hidden');
};

/* ───────────────────────────── 위험구간 색분할 핵심 ───────────────────────────── */
// 위험 반경 (m)
const RISK_RADIUS = { high: 90, medium: 65, low: 45 };

// 경로를 일정 간격(m)으로 샘플링
function densifyPath(path, spacingM){
    const out = [];
    for(let i=0;i<path.length-1;i++){
        const a = path[i], b = path[i+1];
        const lat1=a.getLat(), lng1=a.getLng(), lat2=b.getLat(), lng2=b.getLng();
        const dist = metersBetween(lat1,lng1,lat2,lng2);
        const steps = Math.max(1, Math.ceil(dist / spacingM));
        for(let s=0;s<=steps;s++){
            const t = s/steps;
            const lat = lat1 + (lat2-lat1)*t;
            const lng = lng1 + (lng2-lng1)*t;
            if (!out.length || metersBetween(out[out.length-1].getLat(), out[out.length-1].getLng(), lat, lng) > 0.1){
                out.push(new kakao.maps.LatLng(lat,lng));
            }
        }
    }
    return out;
}

// 특정 지점의 위험 레벨(0=safe,1=low,2=medium,3=high)
function hazardLevelAt(lat, lng){
    const zones = normalizeDangerAreas(window.dangerousAreas || []);
    let levelNum = 0;
    for(const z of zones){
        const d = metersBetween(lat,lng, z.lat,z.lng);
        const rad = RISK_RADIUS[(z.riskLevel||'low').toLowerCase()] || RISK_RADIUS.low;
        if (d <= rad){
            const n = (z.riskLevel==='high'?3 : z.riskLevel==='medium'?2 : 1);
            if (n > levelNum) levelNum = n;
            if (levelNum === 3) break;
        }
    }
    return levelNum;
}

// 기존 위험 오버레이 제거
function clearHazardSegments(){
    (routeHazardPolylines||[]).forEach(p=>p.setMap(null));
    routeHazardPolylines = [];
}

// 경로 위 위험 구간만 색 오버레이(주황/빨강)로 그리기
function drawColoredRoute(path){
    clearHazardSegments();
    if (!path || path.length < 2) return;

    const pts = densifyPath(path, 15);
    const colorOf = lvl => (lvl>=3 ? '#ef4444' : lvl===2 ? '#f59e0b' : lvl===1 ? '#a3e635' : null);

    let curLvl = 0; // safe
    let bucket = [];
    const flush = ()=>{
        if (!bucket.length) return;
        const c = colorOf(curLvl);
        if (c){
            const poly = new kakao.maps.Polyline({
                map, path: bucket, strokeWeight: 7, strokeColor: c, strokeOpacity: 0.95, zIndex: 55
            });
            routeHazardPolylines.push(poly);
        }
        bucket = [];
    };

    for(const p of pts){
        const lvl = hazardLevelAt(p.getLat(), p.getLng());
        if (!bucket.length){ curLvl=lvl; bucket.push(p); continue; }
        if (lvl === curLvl){ bucket.push(p); }
        else { flush(); curLvl=lvl; bucket.push(p); }
    }
    flush();
}

/* ───────────────────────────── 검색 보조/자동완성 ───────────────────────────── */
function resolvePlace(text, datasetLat, datasetLng) {
    return new Promise((resolve, reject)=>{
        if (isFiniteNumber(datasetLat) && isFiniteNumber(datasetLng)) {
            return resolve({ lat: Number(datasetLat), lng: Number(datasetLng) });
        }
        if (!text || !String(text).trim()) return reject(new Error('검색어가 없습니다.'));
        placesService.keywordSearch(text, (data, status)=>{
            if (status !== kakao.maps.services.Status.OK || !data.length) {
                return reject(new Error('검색 결과가 없습니다.'));
            }
            const t = data[0];
            resolve({ lat: parseFloat(t.y), lng: parseFloat(t.x), name: t.place_name });
        }, { size: 5 });
    });
}
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
    (window.currentRouteSteps || []).forEach((step,i)=>{
        const div = document.createElement('div');
        div.textContent = (i+1)+'. '+_stepText(step);
        itemsEl.appendChild(div);
    });
}
function updateVoiceChip() {
    const chipEl = document.getElementById('voiceChip');
    if (!chipEl) return;
    const next = (window.currentRouteSteps || [])[window.currentStepIndex || 0];
    chipEl.textContent = '다음: ' + (_stepText(next) || '안내 없음');
    chipEl.classList.remove('hidden');
}
window.toggleVoicePanel = function () {
    const panel = document.getElementById('voiceList');
    if (!panel) return;
    panel.classList.toggle('hidden');
};
window.showSmallVoiceUI = function () { renderVoiceList(); updateVoiceChip(); };
window.onGpsTickForVoice = function () { updateVoiceChip(); };

function bindPlaceSearch() {
    const sIn = document.getElementById('startInput');
    const eIn = document.getElementById('endInput');
    const btnS = document.getElementById('searchStart');
    const btnE = document.getElementById('searchEnd');

    [sIn, eIn].forEach((el, idx)=>{
        if (!el) return;
        el.addEventListener('keydown', e=>{
            if (e.key !== 'Enter') return;
            (idx === 0 ? (btnS && btnS.click && btnS.click()) : (btnE && btnE.click && btnE.click()));
        });
    });

    function fillFirstResultOf(inputEl, onDone) {
        const q = inputEl && inputEl.value ? inputEl.value.trim() : '';
        if (!q) { alert('검색어를 입력하세요.'); return; }

        kakaoPlaces.keywordSearch(q, (data, status)=>{
            if (status === kakao.maps.services.Status.OK && data.length) {
                const d = data[0];
                inputEl.dataset.lat = d.y;
                inputEl.dataset.lng = d.x;
                inputEl.value       = d.place_name || inputEl.value;
                onDone && onDone({ lat: parseFloat(d.y), lng: parseFloat(d.x), name: d.place_name });
            } else {
                kakaoGeocoder.addressSearch(q, (a, s2)=>{
                    if (s2 === kakao.maps.services.Status.OK && a.length) {
                        inputEl.dataset.lat = a[0].y;
                        inputEl.dataset.lng = a[0].x;
                        inputEl.value       = (a[0].road_address && a[0].road_address.address_name) || (a[0].address && a[0].address.address_name) || inputEl.value;
                        onDone && onDone({ lat: parseFloat(a[0].y), lng: parseFloat(a[0].x), name: inputEl.value });
                    } else {
                        alert('검색 결과가 없습니다.');
                    }
                });
            }
        });
    }

    if (btnS && !btnS.__wired) {
        btnS.__wired = true;
        btnS.addEventListener('click', ()=>fillFirstResultOf(sIn, setStartMarker));
    }
    if (btnE && !btnE.__wired) {
        btnE.__wired = true;
        btnE.addEventListener('click', ()=>fillFirstResultOf(eIn, setEndMarker));
    }

    window.searchRoute = async function () {
        try {
            const start = await resolvePlace(sIn.value, sIn?.dataset?.lat, sIn?.dataset?.lng);
            const end   = await resolvePlace(eIn.value, eIn?.dataset?.lat, eIn?.dataset?.lng);
            sIn.dataset.lat = start.lat; sIn.dataset.lng = start.lng;
            eIn.dataset.lat = end.lat;   eIn.dataset.lng = end.lng;
            setStartMarker(start);
            setEndMarker(end);

            // ★ 경로찾기 → drawRoute 내부에서 프리로드 + 경로필터 + 색칠 수행
            await drawRoute({ start, end });
        } catch (err) {
            alert('출발지/도착지 해석 실패: ' + err.message);
        }
    };
}

function bindAutocomplete(selector) {
    const input = document.querySelector(selector);
    if (!input) return;

    input.parentElement.classList.add('relative');
    const box = document.createElement('div');
    box.className = 'absolute z-50 left-0 right-0 mt-1 bg-white text-black rounded shadow max-h-56 overflow-auto hidden';
    input.parentElement.appendChild(box);

    let typingTimer = null;

    input.addEventListener('input', function(){
        input.dataset.lat = ''; input.dataset.lng = '';
        const q = input.value.trim();
        if (typingTimer) clearTimeout(typingTimer);
        if (!q) { box.innerHTML = ''; box.classList.add('hidden'); return; }
        typingTimer = setTimeout(()=>runSearch(q, render), 220);
    });

    input.addEventListener('keydown', e=>{
        if (e.key === 'Enter') { e.preventDefault(); const first = box.querySelector('button'); if (first) first.click(); }
    });

    input.addEventListener('focus', ()=>{ if (box.innerHTML) box.classList.remove('hidden'); });
    input.addEventListener('blur',  ()=>{ setTimeout(()=>box.classList.add('hidden'), 150); });

    function runSearch(query, done) {
        const results = [];
        const push = (arr, mapFn) => (arr || []).forEach(x=>{ const r = mapFn(x); if (r && isFiniteNumber(r.lat) && isFiniteNumber(r.lng)) results.push(r); });

        kakaoPlaces.keywordSearch(query, (data, status)=>{
            if (status === kakao.maps.services.Status.OK) {
                push(data.slice(0,5), p => ({ name:p.place_name, lat:parseFloat(p.y), lng:parseFloat(p.x), desc:p.road_address_name || p.address_name || '', src:'place' }));
            }
            kakaoGeocoder.addressSearch(query, (addrData, status2)=>{
                if (status2 === kakao.maps.services.Status.OK) {
                    push(addrData.slice(0,5), a=>{
                        const road = a.road_address && a.road_address.address_name;
                        const jibun = a.address && a.address.address_name;
                        const name = road || jibun; if (!name) return null;
                        return { name, lat:parseFloat(a.y), lng:parseFloat(a.x), desc:(road && jibun) ? ('지번: '+jibun) : '', src:'addr' };
                    });
                }
                done(dedupe(results).slice(0,8));
            });
        });
    }
    function dedupe(items) {
        const set = new Set();
        return items.filter(it=>{
            const k = it.name+'|'+it.lat+'|'+it.lng;
            if (set.has(k)) return false; set.add(k); return true;
        });
    }
    function render(items) {
        if (!items.length) {
            box.innerHTML = '<div class="px-3 py-2 text-sm text-gray-500">검색 결과 없음</div>';
            box.classList.remove('hidden'); return;
        }
        box.innerHTML = '';
        items.forEach(it=>{
            const btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'w-full text-left px-3 py-2 hover:bg-gray-100';
            btn.innerHTML = `<div class="text-sm">${it.name}</div>${it.desc ? `<div class="text-xs text-gray-500">${it.desc}</div>` : ''}`;
            btn.addEventListener('click', ()=>{
                input.value = it.name;
                input.dataset.lat = it.lat; input.dataset.lng = it.lng;
                box.classList.add('hidden');
                try { map.panTo(new kakao.maps.LatLng(it.lat, it.lng)); } catch(_) {}
            });
            box.appendChild(btn);
        });
        box.classList.remove('hidden');
    }
}

/* ───────────────────────────── 자전거 레이어 / URL 스킴 ───────────────────────────── */
(function exposeBikeHelpers(){
    function hasBikeOverlay(){ return window.kakao && kakao.maps && kakao.maps.MapTypeId && 'BICYCLE' in kakao.maps.MapTypeId; }
    let _bikeOn = false;
    window.toggleBikeOverlay = function(){
        if (!hasBikeOverlay()){
            if (typeof window.openKakaoBikeLayer === 'function') return window.openKakaoBikeLayer();
            alert('이 환경에서 자전거 오버레이를 지원하지 않습니다.');
            return;
        }
        if (_bikeOn){ map.removeOverlayMapTypeId(kakao.maps.MapTypeId.BICYCLE); _bikeOn=false; }
        else { map.addOverlayMapTypeId(kakao.maps.MapTypeId.BICYCLE); _bikeOn=true; }
    };
})();
window.openKakaoBikeLayer = function(){
    const scheme = 'kakaomap://open?layer=bike';
    const mobileWeb = 'http://m.map.kakao.com/scheme/open?layer=bike';
    const isMobile = /Android|iPhone|iPad|iPod/i.test(navigator.userAgent);
    if (isMobile) {
        const link = document.createElement('a');
        link.setAttribute('href', scheme);
        document.body.appendChild(link);
        link.click();
        setTimeout(()=>{ try { window.open(mobileWeb, '_blank'); } catch(_) { location.href = mobileWeb; } link.remove(); }, 800);
    } else {
        try { window.open(mobileWeb, '_blank'); } catch(_) { location.href = mobileWeb; }
    }
};

/* ───────────────────────────── RG 전용 다크 UI(버튼/상태카드) ───────────────────────────── */
let RG_UI = { bikeOn:false, trackingOn:false };
const _origStartGPS = window.startGPSTracking;
window.startGPSTracking = function(){ RG_UI.trackingOn = true; setTrackingUi(true); return _origStartGPS?.apply(this, arguments); };
const _origStopGPS = window.stopGPSTracking;
window.stopGPSTracking = function(){ RG_UI.trackingOn = false; setTrackingUi(false); return _origStopGPS?.apply(this, arguments); };

function injectMapUiCss(){
    if (document.getElementById('rg-mapui-style')) return;
    const css = `
  .rg-ui-host{position:absolute; inset:0; pointer-events:none;}
  .rg-ctl{position:absolute; left:12px; top:12px; display:flex; gap:8px; pointer-events:auto;}
  .rg-btn{width:44px;height:44px;border-radius:12px;background:rgba(17,24,39,.92);border:1px solid rgba(255,255,255,.08);color:#fff;display:grid;place-items:center;cursor:pointer;box-shadow:0 8px 24px rgba(0,0,0,.35); transition:.15s}
  .rg-btn:hover{ background:rgba(31,41,55,.95); transform:translateY(-1px); }
  .rg-btn.active{ outline:2px solid #12d2a0; background:rgba(18,210,160,.15); }
  .rg-status{position:absolute; left:12px; bottom:12px; pointer-events:auto;background:rgba(17,24,39,.92); color:#e5e7eb;border:1px solid rgba(255,255,255,.1);border-radius:12px; min-width:220px;box-shadow:0 10px 24px rgba(0,0,0,.35);}
  .rg-status .rg-hd{background:linear-gradient(180deg, rgba(18,210,160,.12), transparent);border-bottom:1px solid rgba(255,255,255,.06);color:#12d2a0; font-weight:900; padding:8px 12px; font-size:14px;}
  .rg-status .rg-bd{ padding:10px 12px; font-size:13px; line-height:1.5; }
  .rg-dot{display:inline-block;width:8px;height:8px;border-radius:50%;margin-right:6px}
  .rg-dot.green{background:#10b981}.rg-dot.gray{background:#6b7280}
  #offRouteWarning{position:absolute; left:50%; top:12px; transform:translateX(-50%); background:#ef4444; color:#fff; padding:8px 12px; border-radius:999px; font-weight:800; box-shadow:0 8px 20px rgba(0,0,0,.35); z-index:1000;}
  `;
    const s = document.createElement('style');
    s.id = 'rg-mapui-style';
    s.textContent = css;
    document.head.appendChild(s);
}
function rgIcon(name, size=20){
    const path = {
        gps:'M12 2a10 10 0 1 0 10 10A10 10 0 0 0 12 2Zm1 5v5l4 2',
        center:'M12 7a5 5 0 1 1-5 5 5 5 0 0 1 5-5Zm0-7v3M12 21v3M0 12h3M21 12h3',
        bike:'M5 16a3 3 0 1 0 3 3 3 3 0 0 0-3-3Zm11 0a3 3 0 1 0 3 3 3 3 0 0 0-3-3Zm-6-6h3l3 6h-3m-3-6-2 6h3',
        kakao:'M4 4h16a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2h-7l-5 5v-5H4a2 2 0 0 1 2-2z',
    }[name] || '';
    return `<svg width="${size}" height="${size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="${path}"/></svg>`;
}
function makeBtn(id, iconName, title, onClick){
    const b = document.createElement('button');
    b.id = id; b.className='rg-btn'; b.type='button'; b.title=title;
    b.innerHTML = rgIcon(iconName, 20);
    b.addEventListener('click', onClick);
    return b;
}
function setTrackingUi(on){
    const el = document.getElementById('rg-status-tracking');
    if (!el) return;
    el.innerHTML = (on
        ? `<span class="rg-dot green"></span>Location tracking <b>on</b>`
        : `<span class="rg-dot gray"></span>Location tracking <b>off</b>`);
}
function setDangerCount(n){
    const el = document.getElementById('rg-status-danger');
    if (!el) return;
    const s = (n|0) === 1 ? 'zone' : 'zones';
    el.innerHTML = `⚠️ <b>${n|0}</b> danger ${s}`;
}
function mountMapUI(){
    const mapEl = document.getElementById('map');
    if (!mapEl) return;

    const host = document.createElement('div');
    host.className = 'rg-ui-host';

    const ctl  = document.createElement('div');
    ctl.className = 'rg-ctl';

    const btnTrack  = makeBtn('rg-btn-track','gps','위치 추적 시작/중지', ()=>{ if (gpsWatchId) window.stopGPSTracking(); else window.startGPSTracking(); });
    const btnCenter = makeBtn('rg-btn-center','center','내 위치로 이동', ()=>{ window.recenterToMe && window.recenterToMe(); });
    const btnBike   = makeBtn('rg-btn-bike','bike','자전거 레이어 토글', ()=>{ window.toggleBikeOverlay?.(); btnBike.classList.toggle('active'); });
    const btnKakao  = makeBtn('rg-btn-kakao','kakao','카카오맵(자전거)으로 열기', ()=>{ window.openKakaoBikeLayer?.(); });

    ctl.appendChild(btnTrack);
    ctl.appendChild(btnCenter);
    ctl.appendChild(btnBike);
    ctl.appendChild(btnKakao);

    const status = document.createElement('div');
    status.className = 'rg-status';
    status.innerHTML = `
    <div class="rg-hd">RIDING GOAT</div>
    <div class="rg-bd">
      <div id="rg-status-tracking"><span class="rg-dot gray"></span>Location tracking <b>off</b></div>
      <div id="rg-status-danger">⚠️ <b>0</b> danger zones</div>
    </div>`;

    host.appendChild(ctl);
    host.appendChild(status);

    const parent = mapEl.parentElement || document.body;
    if (getComputedStyle(parent).position === 'static') parent.style.position = 'relative';
    parent.appendChild(host);

    setTrackingUi(RG_UI.trackingOn);
    setDangerCount((dangerousAreaMarkers||[]).length);
}

/* ───────────────────────────── 위험 알림(선택사항용 훅) ───────────────────────────── */
function ensureFreshHazards(/* lat, lng, path */){ /* 필요 시 주기 기반 갱신 로직 구현 */ }
function checkAndNotifyHazard(/* lat, lng, path */){ /* 필요 시 칩/음성 알림 구현 */ }
