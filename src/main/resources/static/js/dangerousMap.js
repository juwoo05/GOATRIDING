// dangerousMap.js

const SEOUL_CITY_HALL = { lat: 37.567948201449, lng: 126.816864614312 };

let map;
let currentLocationMarker;
let dangerousAreaMarkers = [];
let watchId;
let isTracking = false;
let lastHoveredPolygon = null;

function initMap() {
    map = new google.maps.Map(document.getElementById("map"), {

        center: SEOUL_CITY_HALL,
        zoom: 15,
        mapTypeId: 'terrain',
        zoomControl: true,
        mapTypeControl: false,
        scaleControl: true,
        streetViewControl: false,
        rotateControl: false,
        fullscreenControl: true,
        styles: [
            { featureType: "all", stylers: [{ saturation: -80 }] },
            { featureType: "road.arterial", elementType: "geometry", stylers: [{ color: "#2c3e50" }] },
            { featureType: "road.highway", elementType: "geometry", stylers: [{ color: "#34495e" }] },
            { featureType: "water", elementType: "geometry", stylers: [{ color: "#1e3a5f" }] },
        ],
    });
    // Add click event for testing
    map.addListener("click", (event) => {
        console.log("Map clicked at:", event.latLng.lat(), event.latLng.lng());
    });

    // Define the LatLng coordinates for the polygon's path.
    var circleCoords = [
        { lat: 37.5679482, lng: 126.81866124 },
        { lat: 37.56767038, lng: 126.81862672 },
        { lat: 37.56740323, lng: 126.81852448 },
        { lat: 37.56715703, lng: 126.81835846 },
        { lat: 37.56694123, lng: 126.81813502 },
        { lat: 37.56676413, lng: 126.81786277 },
        { lat: 37.56663253, lng: 126.81755216 },
        { lat: 37.56655149, lng: 126.81721512 },
        { lat: 37.56652412, lng: 126.81686461 },
        { lat: 37.56655149, lng: 126.81651411 },
        { lat: 37.56663253, lng: 126.81617707 },
        { lat: 37.56676413, lng: 126.81586646 },
        { lat: 37.56694123, lng: 126.8155942 },
        { lat: 37.56715703, lng: 126.81537077 },
        { lat: 37.56740323, lng: 126.81520474 },
        { lat: 37.56767038, lng: 126.81510251 },
        { lat: 37.5679482, lng: 126.81506798 },
        { lat: 37.56822602, lng: 126.81510251 },
        { lat: 37.56849317, lng: 126.81520474 },
        { lat: 37.56873937, lng: 126.81537077 },
        { lat: 37.56895516, lng: 126.8155942 },
        { lat: 37.56913226, lng: 126.81586646 },
        { lat: 37.56926385, lng: 126.81617707 },
        { lat: 37.56934489, lng: 126.81651411 },
        { lat: 37.56937225, lng: 126.81686461 },
        { lat: 37.56934489, lng: 126.81721512 },
        { lat: 37.56926385, lng: 126.81755216 },
        { lat: 37.56913226, lng: 126.81786277 },
        { lat: 37.56895516, lng: 126.81813502 },
        { lat: 37.56873937, lng: 126.81835846 },
        { lat: 37.56849317, lng: 126.81852448 },
        { lat: 37.56822602, lng: 126.81862672 },
        { lat: 37.5679482, lng: 126.81866124 }
    ];

    // Construct the polygon.
    var dangerousCircle = new google.maps.Polygon({
        paths: circleCoords,
        strokeColor: '#FF0000',
        strokeOpacity: 0.8,
        strokeWeight: 2,
        fillColor: '#FF0000',
        fillOpacity: 0.35,
    });
    dangerousCircle.setMap(map);

    // 사용자 정의 ID 부여
    dangerousCircle.customId = "juwoo";

    // 클릭 이벤트에 적용
    dangerousCircle.addListener("click", function (e) {
        lastClickedFeatureIds = [this.customId]  // this는 클릭된 polygon
        styleClicked(this); // 폴리곤에 직접 스타일 적용하는 함수
        infowindow.open(map);
    });

    // 마우스가 폴리곤 위에 있을 때
    dangerousCircle.addListener("mousemove", function (e) {
        if (lastHoveredPolygon !== this) {
            // 이전 폴리곤 초기화
            if (lastHoveredPolygon) {
                styleDefault(lastHoveredPolygon);
            }
            // 현재 폴리곤 스타일 적용
            lastHoveredPolygon = this;
            styleMouseMove(this);
        }
    });

    // 마우스가 폴리곤 밖으로 나갔을 때
    map.addListener("mousemove", function (e) {
        if (lastHoveredPolygon) {
            // 마우스가 어떤 폴리곤에도 안 올라간 상태로 감지되었을 때 초기화 d
            styleDefault(lastHoveredPolygon);
            lastHoveredPolygon = null;
        }
    });

    const contentString =
        '<div id="content" style="color:black;">' +
        '<div id="siteNotice">' +
        "</div>" +
        '<h1 id="firstHeading" class="firstHeading">사건건수:8</h1>' +
        '<div id="bodyContent">' +
        "<p>사장자: 5 " +
        "사망자: 0 " +
        "중상자: 3 " +
        "</p>" +
        "</div>" +
        "</div>";

    // const contentString =
    //     '<div id="content">' +
    //     '<div id="siteNotice">' +
    //     "</div>" +
    //     '<h1 id="firstHeading" class="firstHeading">Uluru</h1>' +
    //     '<div id="bodyContent">' +
    //     "<p><b>Uluru</b>, also referred to as <b>Ayers Rock</b>, is a large " +
    //     "sandstone rock formation in the southern part of the " +
    //     "Northern Territory, central Australia. It lies 335&#160;km (208&#160;mi) " +
    //     "south west of the nearest large town, Alice Springs; 450&#160;km " +
    //     "(280&#160;mi) by road. Kata Tjuta and Uluru are the two major " +
    //     "features of the Uluru - Kata Tjuta National Park. Uluru is " +
    //     "sacred to the Pitjantjatjara and Yankunytjatjara, the " +
    //     "Aboriginal people of the area. It has many springs, waterholes, " +
    //     "rock caves and ancient paintings. Uluru is listed as a World " +
    //     "Heritage Site.</p>" +
    //     '<p>Attribution: Uluru, <a href="https://en.wikipedia.org/w/index.php?title=Uluru&oldid=297882194">' +
    //     "https://en.wikipedia.org/w/index.php?title=Uluru</a> " +
    //     "(last visited June 22, 2009).</p>" +
    //     "</div>" +
    //     "</div>";

    const infowindow = new google.maps.InfoWindow({
        content: contentString,
        position : { lat: 37.567948201449, lng: 126.816864614312 }
    });


    getCurrentLocation();
    updateDangerousAreaMarkers();
}

function styleClicked(polygon) {
    polygon.setOptions({
        strokeColor: "blue",
        fillColor: "blue",
        fillOpacity: 0.5,
    });
}

function styleMouseMove(polygon) {
    polygon.setOptions({
        strokeWeight: 4.0
    })
}

function styleDefault(polygon) {
    polygon.setOptions({
        strokeWeight: 2
    })
}
// const styleClicked = {
//     ...styleDefault,
//     strokeColor: "blue",
//     fillColor: "blue",
//     fillOpacity: 0.5,
// };
// const styleMouseMove = {
//     ...styleDefault,
// };

function getCurrentLocation() {
    if (!navigator.geolocation) {
        alert("Geolocation is not supported.");
        return;
    }

    navigator.geolocation.getCurrentPosition(
        (position) => {
            const location = {
                lat: position.coords.latitude,
                lng: position.coords.longitude,
            };
            updateCurrentLocationMarker(location);
        },
        (error) => {
            alert("Failed to get current location: " + error.message);
        },
        { enableHighAccuracy: true, timeout: 10000, maximumAge: 60000 }
    );
}

function updateCurrentLocationMarker(location) {
    if (currentLocationMarker) {
        currentLocationMarker.setMap(null);
    }

    currentLocationMarker = new google.maps.Marker({
        position: location,
        map: map,
        icon: {
            path: google.maps.SymbolPath.CIRCLE,
            scale: 8,
            fillColor: "#4285F4",
            fillOpacity: 1,
            strokeColor: "#ffffff",
            strokeWeight: 2,
        },
        title: "Current Location",
        zIndex: 1000,
    });

    new google.maps.Circle({
        strokeColor: "#4285F4",
        strokeOpacity: 0.8,
        strokeWeight: 1,
        fillColor: "#4285F4",
        fillOpacity: 0.15,
        map: map,
        center: location,
        radius: 100,
    });

    map.setCenter(location);
}

function updateDangerousAreaMarkers() {
    // Dummy data for now. You should replace this with actual data from server or JSP context.
    const dangerousAreas = window.dangerousAreas || [
        {
            id: "1",
            name: "Intersection 1",
            lat: 37.5667,
            lng: 126.9784,
            riskLevel: "high",
            description: "Frequent accidents due to traffic merging.",
            incidents: 8,
        },
        {
            id: "2",
            name: "Tunnel Exit",
            lat: 37.567,
            lng: 126.979,
            riskLevel: "medium",
            description: "Low visibility zone.",
            incidents: 5,
        },
    ];

    dangerousAreaMarkers.forEach((marker) => marker.setMap(null));
    dangerousAreaMarkers = [];

    dangerousAreas.forEach((area) => {
        const color =
            area.riskLevel === "high"
                ? "#ef4444"
                : area.riskLevel === "medium"
                    ? "#f59e0b"
                    : "#10b981";

        const marker = new google.maps.Marker({
            position: { lat: area.lat, lng: area.lng },
            map: map,
            icon: {
                path: "M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z",
                scale: 1.5,
                fillColor: color,
                fillOpacity: 1,
                strokeColor: "#ffffff",
                strokeWeight: 1,
            },
            title: area.name,
        });

        const infoWindow = new google.maps.InfoWindow({
            content: `
        <div style="padding: 8px;">
          <h3 style="margin: 0 0 8px 0; color: ${color};">${area.name}</h3>
          <p style="margin: 4px 0; color: #666;">${area.description}</p>
          <div style="display: flex; gap: 12px; margin-top: 8px; font-size: 12px;">
            <span style="color: ${color}; font-weight: bold;">
              ${area.riskLevel.toUpperCase()} RISK
            </span>
            <span style="color: #666;">
              ${area.incidents} incidents
            </span>
          </div>
        </div>
      `,
        });

        marker.addListener("click", () => {
            infoWindow.open(map, marker);
        });

        dangerousAreaMarkers.push(marker);
    });
}

function startTracking() {
    if (!navigator.geolocation) {
        alert("Geolocation is not supported");
        return;
    }

    if (isTracking) {
        stopTracking();
        return;
    }

    isTracking = true;
    watchId = navigator.geolocation.watchPosition(
        (position) => {
            const location = {
                lat: position.coords.latitude,
                lng: position.coords.longitude,
            };
            updateCurrentLocationMarker(location);
        },
        (error) => {
            alert("Tracking error: " + error.message);
        },
        { enableHighAccuracy: true, timeout: 10000, maximumAge: 5000 }
    );
}

function stopTracking() {
    if (watchId) {
        navigator.geolocation.clearWatch(watchId);
        watchId = null;
    }
    isTracking = false;
}
function toggleRoutes() {
    alert("경로 보기 기능은 추후 구현 예정입니다.");
    // 또는 실제 길찾기 로직 연결 가능
}

window.initMap = initMap;