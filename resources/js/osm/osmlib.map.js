(function () {
  if (window.osmlib) {
    return;
  }

  let messageSequence = 0;
  let bootstrapMapId = "";

  function sendEnvelope(envelope) {
    if (window.chrome && window.chrome.webview && typeof window.chrome.webview.postMessage === "function") {
      window.chrome.webview.postMessage(JSON.stringify(envelope));
      return;
    }
    // Fallback for other browsers if needed
    const bridgeFrame = document.createElement("iframe");
    bridgeFrame.style.display = "none";
    messageSequence += 1;
    bridgeFrame.src = "https://gmlib.local/__gmlib_message__?data=" +
      encodeURIComponent(JSON.stringify(envelope)) +
      "&seq=" + String(messageSequence);
    document.documentElement.appendChild(bridgeFrame);
    window.setTimeout(() => {
      if (bridgeFrame.parentNode) {
        bridgeFrame.parentNode.removeChild(bridgeFrame);
      }
    }, 0);
  }

  function sendMessage(messageType, targetId, payload) {
    sendEnvelope({ type: messageType, targetId: targetId || "", payload: payload });
  }

  function reportBootstrap(message) {
    sendMessage("map.event.error", bootstrapMapId, { message: "OSM bootstrap: " + message });
  }

  function safeNumber(value, fallbackValue) {
    if (typeof value === "number" && Number.isFinite(value)) {
      return value;
    }
    return fallbackValue;
  }

  // Define commands receiver for maximum compatibility with both gmlib and maplib namespaces
  window.maplib = window.maplib || {};
  window.gmlib = window.gmlib || {};

  window.maplib.receiveCommand = window.gmlib.receiveCommand = function (messageEnvelope) {
    if (!window.osmlib) {
      return;
    }
    const envelope = typeof messageEnvelope === "string" ? JSON.parse(messageEnvelope) : messageEnvelope;
    if (!envelope || typeof envelope.type !== "string") {
      return;
    }

    const payload = typeof envelope.payload === "string" && envelope.payload ? JSON.parse(envelope.payload) : (envelope.payload || {});

    if (envelope.type === "marker.add") {
      window.osmlib.addMarker(payload);
    } else if (envelope.type === "marker.clear") {
      window.osmlib.clearMarkers();
    } else if (envelope.type === "marker.remove") {
      window.osmlib.removeMarker(payload.objectId);
    }
  };

  window.osmlib = {
    map: null,
    mapId: "",
    markers: {},

    bootstrap: function (config) {
      const host = document.getElementById('osmlib-map');
      this.mapId = (config && config.mapId) ? String(config.mapId) : "";
      bootstrapMapId = this.mapId;

      reportBootstrap(
        "entered. styleUrl=" + String((config && config.styleUrl) || "") +
        " styleJsonLength=" + String((config && config.styleJson) ? config.styleJson.length : 0)
      );

      if (!host) {
        sendMessage("map.event.error", this.mapId, { message: "OSM bootstrap failed: host element #osmlib-map not found." });
        return;
      }
      if (typeof maplibregl === 'undefined') {
        sendMessage("map.event.error", this.mapId, { message: "OSM bootstrap failed: maplibregl is undefined." });
        return;
      }

      try {
        let styleConfig = config && config.styleJson ? config.styleJson : config.styleUrl;
        if (typeof styleConfig === "string" && styleConfig.trim().startsWith("{")) {
          styleConfig = JSON.parse(styleConfig);
        }
        reportBootstrap("creating map with " + (config && config.styleJson ? "styleJson" : "styleUrl"));
        this.map = new maplibregl.Map({
          container: host,
          style: styleConfig,
          center: [config.center.lng, config.center.lat],
          zoom: config.zoom
        });

        this.map.on('error', (e) => {
          const message = e && e.error && e.error.message ? e.error.message : JSON.stringify(e || {});
          sendMessage("map.event.error", this.mapId, { message: "OSM map error: " + message });
        });

        this.map.on('load', () => {
          reportBootstrap("map load");
          sendMessage("map.ready", this.mapId, "");
        });

        // Forward map clicks to Delphi with the required latLng format
        this.map.on('click', (e) => {
          const payload = {
            latLng: {
              lat: e.lngLat.lat,
              lng: e.lngLat.lng
            }
          };
          sendMessage("map.event.click", this.mapId, payload);
        });

      } catch (e) {
        sendMessage("map.event.error", this.mapId, { message: "OSM bootstrap failed: " + (e.message || e.toString()) });
      }
    },

    addMarker: function (payload) {
      if (!this.map || !payload) {
        return;
      }
      const objectId = typeof payload.objectId === "string" ? payload.objectId : "";
      if (!objectId) {
        return;
      }

      this.removeMarker(objectId);

      const lat = safeNumber(payload.lat, 0);
      const lng = safeNumber(payload.lng, 0);
      const title = typeof payload.title === "string" ? payload.title : "";

      const marker = new maplibregl.Marker({
        draggable: typeof payload.draggable === "boolean" ? payload.draggable : false
      })
        .setLngLat([lng, lat]);

      if (title) {
        marker.setPopup(new maplibregl.Popup({ offset: 25 }).setText(title));
      }

      marker.addTo(this.map);

      // Setup click on marker events
      const element = marker.getElement();
      element.style.cursor = "pointer";
      element.addEventListener("click", (ev) => {
        ev.stopPropagation();
        const markerLngLat = marker.getLngLat();
        sendMessage("marker.event.click", this.mapId, {
          objectId: objectId,
          latLng: {
            lat: safeNumber(markerLngLat ? markerLngLat.lat : lat, lat),
            lng: safeNumber(markerLngLat ? markerLngLat.lng : lng, lng)
          }
        });
      });

      this.markers[objectId] = marker;
    },

    removeMarker: function (objectId) {
      if (!objectId || !this.markers[objectId]) {
        return;
      }
      this.markers[objectId].remove();
      delete this.markers[objectId];
    },

    clearMarkers: function () {
      const ids = Object.keys(this.markers);
      for (let i = 0; i < ids.length; i += 1) {
        this.removeMarker(ids[i]);
      }
    }
  };

  window.osmlibBootstrapError = function () {
    reportBootstrap("maplibre script failed to load");
  };

  window.addEventListener("error", function (event) {
    const message = event && event.message ? event.message : "unknown error";
    reportBootstrap("window error: " + message);
  });

  window.addEventListener("unhandledrejection", function (event) {
    const reason = event && event.reason ? String(event.reason) : "unknown rejection";
    reportBootstrap("unhandled rejection: " + reason);
  });
})();
