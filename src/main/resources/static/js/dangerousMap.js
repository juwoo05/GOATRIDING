// dangerousMap.js

const SEOUL_CITY_HALL = { lat: 37.5665, lng: 126.9780 };

let map;
let currentLocationMarker;
let dangerousAreaMarkers = [];
let watchId;
let isTracking = false;

function initMap() {
    map = new google.maps.Map(document.getElementById("map"), {

        center: SEOUL_CITY_HALL,
        zoom: 15,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
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

    getCurrentLocation();
    updateDangerousAreaMarkers();
}

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