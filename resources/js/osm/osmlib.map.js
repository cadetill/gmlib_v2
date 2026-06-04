(function () {
  if (window.osmlib) {
    return;
  }

  let messageSequence = 0;
  let bootstrapMapId = "";

  function ensureMessageQueue() {
    window.maplib = window.maplib || {};
    window.maplib.__messageQueue = window.maplib.__messageQueue || [];
    return window.maplib.__messageQueue;
  }

  function sendEnvelope(envelope) {
    if (!envelope || typeof envelope !== "object") {
      return;
    }
    ensureMessageQueue().push(envelope);
    if (window.chrome && window.chrome.webview && typeof window.chrome.webview.postMessage === "function") {
      window.chrome.webview.postMessage(JSON.stringify(envelope));
      return;
    }
    if (document && document.documentElement) {
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

  function safeBoolean(value, fallbackValue) {
    if (typeof value === "boolean") {
      return value;
    }
    return fallbackValue;
  }

  window.maplib = window.maplib || {};
  window.maplib.__messageQueue = window.maplib.__messageQueue || [];
  window.gmlib = window.gmlib || {};
  window.gmlib.__messageQueue = window.gmlib.__messageQueue || [];

  window.osmlib = {
    map: null,
    mapId: "",
    markers: {},

    buildViewPayload: function () {
      if (!this.map) {
        return {};
      }

      const center = this.map.getCenter();
      return {
        center: {
          lat: safeNumber(center && center.lat, 0),
          lng: safeNumber(center && center.lng, 0)
        },
        zoom: safeNumber(this.map.getZoom(), 0),
        bearing: safeNumber(this.map.getBearing(), 0),
        pitch: safeNumber(this.map.getPitch(), 0)
      };
    },

    buildBoundsPayload: function () {
      if (!this.map) {
        return {};
      }

      const bounds = this.map.getBounds();
      if (!bounds) {
        return {};
      }

      return {
        north: safeNumber(bounds.getNorth(), 0),
        south: safeNumber(bounds.getSouth(), 0),
        east: safeNumber(bounds.getEast(), 0),
        west: safeNumber(bounds.getWest(), 0)
      };
    },

    sendViewEvent: function (eventName) {
      sendMessage("map.event." + eventName, this.mapId, this.buildViewPayload());
    },

    sendSimpleEvent: function (eventName) {
      sendMessage("map.event." + eventName, this.mapId, {});
    },

    registerMapEvents: function () {
      if (!this.map) {
        return;
      }

      const coordinateEvents = [
        "click",
        "contextmenu",
        "dblclick",
        "mousedown",
        "mousemove",
        "mouseout",
        "mouseover",
        "mouseup"
      ];
      const viewEvents = [
        "movestart",
        "move",
        "moveend",
        "dragstart",
        "drag",
        "dragend",
        "zoomstart",
        "zoom",
        "zoomend",
        "rotatestart",
        "rotate",
        "rotateend",
        "pitchstart",
        "pitch",
        "pitchend"
      ];
      const simpleEvents = [
        "touchcancel",
        "touchend",
        "touchmove",
        "touchstart",
        "boxzoomstart",
        "boxzoomend",
        "boxzoomcancel",
        "resize",
        "render",
        "idle",
        "load",
        "data",
        "dataloading",
        "dataabort",
        "sourcedata",
        "sourcedataloading",
        "sourcedataabort",
        "styledata",
        "styledataloading",
        "styleimagemissing",
        "terrain",
        "projectiontransition",
        "webglcontextlost",
        "webglcontextrestored",
        "wheel"
      ];

      coordinateEvents.forEach((eventName) => {
        this.map.on(eventName, (e) => {
          sendMessage("map.event." + eventName, this.mapId, {
            latLng: {
              lat: safeNumber(e && e.lngLat && e.lngLat.lat, 0),
              lng: safeNumber(e && e.lngLat && e.lngLat.lng, 0)
            }
          });
        });
      });

      viewEvents.forEach((eventName) => {
        this.map.on(eventName, () => {
          this.sendViewEvent(eventName);
          if (eventName === "moveend") {
            sendMessage("map.event.boundschanged", this.mapId, this.buildBoundsPayload());
          }
        });
      });

      simpleEvents.forEach((eventName) => {
        this.map.on(eventName, () => {
          this.sendSimpleEvent(eventName);
        });
      });

      this.map.on("cooperativegestureprevented", () => {
        this.sendSimpleEvent("cooperativegestureprevented");
      });

      this.map.on("error", (e) => {
        const message = e && e.error && e.error.message ? e.error.message : JSON.stringify(e || {});
        sendMessage("map.event.error", this.mapId, { message: "OSM map error: " + message });
      });
    },

    applyInteractionFlag: function (handlerName, enabled) {
      if (!this.map || !this.map[handlerName]) {
        return;
      }

      if (enabled) {
        this.map[handlerName].enable();
      } else {
        this.map[handlerName].disable();
      }
    },

    applyMapOptions: function (payload) {
      if (!this.map || !payload) {
        return;
      }

      if (typeof payload.minZoom === "number") {
        this.map.setMinZoom(payload.minZoom);
      }
      if (typeof payload.maxZoom === "number") {
        this.map.setMaxZoom(payload.maxZoom);
      }

      this.applyInteractionFlag("dragPan", safeBoolean(payload.dragPanEnabled, true));
      this.applyInteractionFlag("dragRotate", safeBoolean(payload.dragRotateEnabled, true));
      this.applyInteractionFlag("doubleClickZoom", safeBoolean(payload.doubleClickZoomEnabled, true));
      this.applyInteractionFlag("scrollZoom", safeBoolean(payload.scrollZoomEnabled, true));
      this.applyInteractionFlag("keyboard", safeBoolean(payload.keyboardEnabled, true));
      this.applyInteractionFlag("touchZoomRotate", safeBoolean(payload.touchZoomRotateEnabled, true));
      this.applyInteractionFlag("touchPitch", safeBoolean(payload.touchPitchEnabled, true));
    },

    setView: function (payload) {
      if (!this.map || !payload) {
        return;
      }

      const center = payload.center || {};
      this.map.jumpTo({
        center: [
          safeNumber(center.lng, this.map.getCenter().lng),
          safeNumber(center.lat, this.map.getCenter().lat)
        ],
        zoom: safeNumber(payload.zoom, this.map.getZoom()),
        bearing: safeNumber(payload.bearing, this.map.getBearing()),
        pitch: safeNumber(payload.pitch, this.map.getPitch())
      });
    },

    setStyle: function (payload) {
      if (!this.map || !payload) {
        return;
      }

      let styleConfig = payload.styleJson || payload.styleUrl;
      if (typeof styleConfig === "string" && styleConfig.trim().startsWith("{")) {
        styleConfig = JSON.parse(styleConfig);
      }
      if (!styleConfig) {
        return;
      }

      this.map.setStyle(styleConfig);
    },

    fitBounds: function (payload) {
      if (!this.map || !payload) {
        return;
      }

      this.map.fitBounds([
        [safeNumber(payload.west, 0), safeNumber(payload.south, 0)],
        [safeNumber(payload.east, 0), safeNumber(payload.north, 0)]
      ]);
    },

    bootstrap: function (config) {
      const host = document.getElementById("osmlib-map");
      this.mapId = (config && config.mapId) ? String(config.mapId) : "";
      bootstrapMapId = this.mapId;

      reportBootstrap("bootstrap entered");
      reportBootstrap(
        "entered. styleUrl=" + String((config && config.styleUrl) || "") +
        " styleJsonLength=" + String((config && config.styleJson) ? config.styleJson.length : 0)
      );

      if (!host) {
        sendMessage("map.event.error", this.mapId, { message: "OSM bootstrap failed: host element #osmlib-map not found." });
        return;
      }
      if (typeof maplibregl === "undefined") {
        sendMessage("map.event.error", this.mapId, { message: "OSM bootstrap failed: maplibregl is undefined." });
        return;
      }

      try {
        let styleConfig = config && config.styleJson ? config.styleJson : config.styleUrl;
        if (typeof styleConfig === "string" && styleConfig.trim().startsWith("{")) {
          try {
            styleConfig = JSON.parse(styleConfig);
          } catch (parseError) {
            sendMessage(
              "map.event.error",
              this.mapId,
              { message: "OSM bootstrap failed: invalid styleJson: " + (parseError && parseError.message ? parseError.message : String(parseError)) }
            );
            return;
          }
        }

        reportBootstrap("creating map with " + (config && config.styleJson ? "styleJson" : "styleUrl"));
        this.map = new maplibregl.Map({
          container: host,
          style: styleConfig,
          center: [config.center.lng, config.center.lat],
          zoom: config.zoom,
          bearing: safeNumber(config.bearing, 0),
          pitch: safeNumber(config.pitch, 0),
          minZoom: safeNumber(config.minZoom, 0),
          maxZoom: safeNumber(config.maxZoom, 22),
          cooperativeGestures: safeBoolean(config.cooperativeGesturesEnabled, false)
        });

        this.applyMapOptions(config);
        this.registerMapEvents();

        this.map.on("load", () => {
          reportBootstrap("map load");
          sendMessage("map.ready", this.mapId, "");
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
      }).setLngLat([lng, lat]);

      if (title) {
        marker.setPopup(new maplibregl.Popup({ offset: 25 }).setText(title));
      }

      marker.addTo(this.map);

      const sendMarkerPositionEvent = (eventName) => {
        const markerLngLat = marker.getLngLat();
        sendMessage("marker.event." + eventName, this.mapId, {
          objectId: objectId,
          latLng: {
            lat: safeNumber(markerLngLat ? markerLngLat.lat : lat, lat),
            lng: safeNumber(markerLngLat ? markerLngLat.lng : lng, lng)
          }
        });
      };

      const element = marker.getElement();
      element.style.cursor = "pointer";
      element.addEventListener("click", (ev) => {
        ev.stopPropagation();
        sendMarkerPositionEvent("click");
      });

      marker.on("dragstart", () => sendMarkerPositionEvent("dragstart"));
      marker.on("drag", () => sendMarkerPositionEvent("drag"));
      marker.on("dragend", () => sendMarkerPositionEvent("dragend"));

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

  window.maplib.receiveCommand = window.gmlib.receiveCommand = function (messageEnvelope) {
    if (!window.osmlib) {
      return;
    }

    const envelope = typeof messageEnvelope === "string" ? JSON.parse(messageEnvelope) : messageEnvelope;
    if (!envelope || typeof envelope.type !== "string") {
      return;
    }

    const payload = typeof envelope.payload === "string" && envelope.payload
      ? JSON.parse(envelope.payload)
      : (envelope.payload || {});

    if (envelope.type === "marker.add") {
      window.osmlib.addMarker(payload);
    } else if (envelope.type === "marker.clear") {
      window.osmlib.clearMarkers();
    } else if (envelope.type === "marker.remove") {
      window.osmlib.removeMarker(payload.objectId);
    } else if (envelope.type === "map.set_view") {
      window.osmlib.setView(payload);
    } else if (envelope.type === "map.set_style") {
      window.osmlib.setStyle(payload);
    } else if (envelope.type === "map.fit_bounds") {
      window.osmlib.fitBounds(payload);
    } else if (envelope.type === "map.set_options") {
      window.osmlib.applyMapOptions(payload);
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
