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
    return message;
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
    popups: {},

    normalizePopupOptions: function (payload) {
      const position = payload && typeof payload.position === "object" ? payload.position : {};
      return {
        objectId: typeof payload.objectId === "string" ? payload.objectId : "",
        anchorObjectId: typeof payload.anchorObjectId === "string" ? payload.anchorObjectId : "",
        content: typeof payload.content === "string" ? payload.content : "",
        contentType: typeof payload.contentType === "string" ? payload.contentType : "html",
        cssClass: typeof payload.cssClass === "string" ? payload.cssClass : "",
        closeButton: safeBoolean(payload.closeButton, true),
        closeOnClick: safeBoolean(payload.closeOnClick, true),
        closeOnMove: safeBoolean(payload.closeOnMove, false),
        maxWidth: safeNumber(payload.maxWidth, 0),
        visible: safeBoolean(payload.visible, false),
        position: {
          lat: safeNumber(position.lat, 0),
          lng: safeNumber(position.lng, 0)
        }
      };
    },

    normalizeMarkerOptions: function (payload) {
      const rawKind = typeof payload.kind === "string" ? payload.kind.toLowerCase() : "standard";
      const markerKind = (rawKind === "pin" || rawKind === "dot") ? rawKind : "standard";
      return {
        objectId: typeof payload.objectId === "string" ? payload.objectId : "",
        lat: safeNumber(payload.lat, 0),
        lng: safeNumber(payload.lng, 0),
        title: typeof payload.title === "string" ? payload.title : "",
        visible: safeBoolean(payload.visible, true),
        draggable: safeBoolean(payload.draggable, false),
        color: typeof payload.color === "string" ? payload.color : "",
        backgroundColor: typeof payload.backgroundColor === "string" ? payload.backgroundColor : "",
        borderColor: typeof payload.borderColor === "string" ? payload.borderColor : "",
        borderWidth: safeNumber(payload.borderWidth, 0),
        scale: safeNumber(payload.scale, 1),
        glyphText: typeof payload.glyphText === "string" ? payload.glyphText : "",
        glyphTextColor: typeof payload.glyphTextColor === "string" ? payload.glyphTextColor : "#ffffff",
        glyphFontSize: safeNumber(payload.glyphFontSize, 0),
        glyphOffsetX: safeNumber(payload.glyphOffsetX, 0),
        glyphOffsetY: safeNumber(payload.glyphOffsetY, 0),
        opacity: safeNumber(payload.opacity, 1),
        zIndex: safeNumber(payload.zIndex, 0),
        rotation: safeNumber(payload.rotation, 0),
        anchorX: safeNumber(payload.anchorX, 0),
        anchorY: safeNumber(payload.anchorY, 0),
        popupEnabled: safeBoolean(payload.popupEnabled, true),
        popupText: typeof payload.popupText === "string" ? payload.popupText : "",
        hideDefaultCenterDot: safeBoolean(payload.hideDefaultCenterDot, false),
        useDefaultMapLibreShape: safeBoolean(payload.useDefaultMapLibreShape, true),
        useGlyph: safeBoolean(payload.useGlyph, true),
        shadowEnabled: safeBoolean(payload.shadowEnabled, false),
        shadowColor: typeof payload.shadowColor === "string" ? payload.shadowColor : "rgba(0, 0, 0, 0.35)",
        shadowBlur: safeNumber(payload.shadowBlur, 8),
        shapeVariant: typeof payload.shapeVariant === "string" ? payload.shapeVariant : "",
        cornerStyle: typeof payload.cornerStyle === "string" ? payload.cornerStyle : "",
        padding: safeNumber(payload.padding, 0),
        minWidth: safeNumber(payload.minWidth, 0),
        minHeight: safeNumber(payload.minHeight, 0),
        pointerLength: safeNumber(payload.pointerLength, 0),
        pointerWidth: safeNumber(payload.pointerWidth, 0),
        radius: safeNumber(payload.radius, 0),
        diameter: safeNumber(payload.diameter, 0),
        pulseEnabled: safeBoolean(payload.pulseEnabled, false),
        pulseColor: typeof payload.pulseColor === "string" ? payload.pulseColor : "",
        pulseRadius: safeNumber(payload.pulseRadius, 0),
        pulseDuration: safeNumber(payload.pulseDuration, 1.8),
        kind: markerKind
      };
    },

    ensureMarkerStyles: function () {
      if (document.getElementById("osmlib-marker-styles")) {
        return;
      }

      const style = document.createElement("style");
      style.id = "osmlib-marker-styles";
      style.textContent = [
        "@keyframes osmlib-dot-pulse {",
        "  0% { transform: translate(-50%, -50%) scale(0.85); opacity: 0.65; }",
        "  100% { transform: translate(-50%, -50%) scale(1.8); opacity: 0; }",
        "}"
      ].join("\n");
      document.head.appendChild(style);
    },

    ensurePopupStyles: function () {
      if (document.getElementById("osmlib-popup-styles")) {
        return;
      }

      const style = document.createElement("style");
      style.id = "osmlib-popup-styles";
      style.textContent = [
        ".osm-popup-note .maplibregl-popup-content {",
        "  background: #fffdf5;",
        "  border: 1px solid #e8d9a8;",
        "  color: #3f3520;",
        "  box-shadow: 0 12px 28px rgba(90, 74, 28, 0.18);",
        "}",
        ".osm-popup-note .maplibregl-popup-tip {",
        "  border-top-color: #fffdf5;",
        "  border-bottom-color: #fffdf5;",
        "}",
        ".osm-popup-warning .maplibregl-popup-content {",
        "  background: #fff4e8;",
        "  border: 1px solid #f2b36d;",
        "  color: #7a3412;",
        "  box-shadow: 0 12px 28px rgba(164, 84, 22, 0.2);",
        "}",
        ".osm-popup-warning .maplibregl-popup-tip {",
        "  border-top-color: #fff4e8;",
        "  border-bottom-color: #fff4e8;",
        "}",
        ".osm-popup-dark .maplibregl-popup-content {",
        "  background: #1f2937;",
        "  border: 1px solid #111827;",
        "  color: #f9fafb;",
        "  box-shadow: 0 14px 30px rgba(0, 0, 0, 0.35);",
        "}",
        ".osm-popup-dark .maplibregl-popup-tip {",
        "  border-top-color: #1f2937;",
        "  border-bottom-color: #1f2937;",
        "}",
        ".osm-popup-success .maplibregl-popup-content {",
        "  background: #ecfdf3;",
        "  border: 1px solid #86efac;",
        "  color: #166534;",
        "  box-shadow: 0 12px 28px rgba(22, 101, 52, 0.18);",
        "}",
        ".osm-popup-success .maplibregl-popup-tip {",
        "  border-top-color: #ecfdf3;",
        "  border-bottom-color: #ecfdf3;",
        "}"
      ].join("\n");
      document.head.appendChild(style);
    },

    buildMarkerPopup: function (options) {
      if (!options || !options.popupEnabled) {
        return null;
      }

      const popupText = options.popupText || options.title;
      if (!popupText) {
        return null;
      }

      return new maplibregl.Popup({ offset: 25 }).setText(popupText);
    },

    resolvePopupOffset: function (options) {
      if (!options || !options.anchorObjectId) {
        return null;
      }

      const markerEntry = this.markers[options.anchorObjectId];
      const markerElement = markerEntry && markerEntry.marker &&
        typeof markerEntry.marker.getElement === "function"
          ? markerEntry.marker.getElement()
          : null;

      const markerHeight = markerElement && markerElement.offsetHeight > 0
        ? markerElement.offsetHeight
        : 30;

      // Keep the popup visually above the marker instead of centered on it.
      return [0, -Math.round(markerHeight)];
    },

    buildPopup: function (options) {
      this.ensurePopupStyles();
      const popupOptions = {
        closeButton: options.closeButton,
        closeOnClick: options.closeOnClick,
        closeOnMove: options.closeOnMove
      };
      if (options.anchorObjectId) {
        popupOptions.anchor = "bottom";
        popupOptions.offset = this.resolvePopupOffset(options);
      }
      if (options.cssClass) {
        popupOptions.className = options.cssClass;
      }
      if (options.maxWidth > 0) {
        popupOptions.maxWidth = String(options.maxWidth) + "px";
      }

      const popup = new maplibregl.Popup(popupOptions);
      if (options.contentType === "text") {
        popup.setText(options.content || "");
      } else {
        popup.setHTML(options.content || "");
      }
      return popup;
    },

    resolvePopupLngLat: function (options) {
      const markerEntry = options.anchorObjectId ? this.markers[options.anchorObjectId] : null;
      if (markerEntry && markerEntry.marker && typeof markerEntry.marker.getLngLat === "function") {
        return markerEntry.marker.getLngLat();
      }

      return {
        lat: safeNumber(options.position && options.position.lat, 0),
        lng: safeNumber(options.position && options.position.lng, 0)
      };
    },

    buildCustomMarkerElement: function (options) {
      this.ensureMarkerStyles();
      const scale = Number.isFinite(options.scale) && options.scale > 0 ? options.scale : 1;
      const color = options.color || options.backgroundColor || "#000000";
      const borderColor = options.borderColor || "#000000";
      const borderWidth = Math.max(0, safeNumber(options.borderWidth, 0));
      const element = document.createElement("div");
      const glyph = document.createElement("span");

      element.className = "osmlib-marker-custom osmlib-marker-" + options.kind;
      element.style.position = "relative";
      element.style.pointerEvents = "auto";
      element.style.userSelect = "none";
      element.style.cursor = "pointer";

      glyph.className = "osmlib-marker-glyph";
      glyph.style.position = "absolute";
      glyph.style.left = "50%";
      glyph.style.pointerEvents = "none";
      glyph.style.fontWeight = "700";
      glyph.style.fontFamily = "Segoe UI, Arial, sans-serif";
      glyph.style.color = options.glyphTextColor || "#ffffff";
      glyph.style.textShadow = "0 1px 2px rgba(0, 0, 0, 0.45)";
      glyph.style.transform = "translate(-50%, -50%)";
      glyph.style.fontSize = String(
        Number.isFinite(options.glyphFontSize) && options.glyphFontSize > 0
          ? Math.round(options.glyphFontSize)
          : Math.max(10, Math.round(11 * scale))
      ) + "px";

      if (options.kind === "standard") {
        const size = Math.max(
          20,
          Math.round(
            Math.max(options.minWidth || 0, options.minHeight || 0, 28 * scale)
          )
        );
        element.style.width = String(size) + "px";
        element.style.height = String(size) + "px";
        element.style.borderRadius = "50%";
        element.style.background = color;
        if (borderWidth > 0) {
          element.style.border = String(borderWidth) + "px solid " + borderColor;
        }
        if (options.shadowEnabled) {
          element.style.boxShadow = "0 2px " + String(Math.max(2, options.shadowBlur || 8)) +
            "px " + (options.shadowColor || "rgba(0, 0, 0, 0.35)");
        }
        glyph.style.left = "50%";
        glyph.style.top = "50%";
      } else if (options.kind === "dot") {
        const diameter = options.diameter > 0
          ? options.diameter
          : (options.radius > 0 ? options.radius * 2 : Math.max(18, Math.round(28 * scale)));
        const size = Math.max(8, Math.round(diameter));
        element.style.width = String(size) + "px";
        element.style.height = String(size) + "px";
        element.style.borderRadius = "50%";
        element.style.background = color;
        if (borderWidth > 0) {
          element.style.border = String(borderWidth) + "px solid " + borderColor;
        }
        if (options.shadowEnabled) {
          element.style.boxShadow = "0 2px " + String(Math.max(2, options.shadowBlur || 8)) +
            "px " + (options.shadowColor || "rgba(0, 0, 0, 0.35)");
        }
        if (options.pulseEnabled) {
          const pulse = document.createElement("div");
          pulse.className = "osmlib-marker-pulse";
          pulse.style.position = "absolute";
          pulse.style.left = "50%";
          pulse.style.top = "50%";
          pulse.style.width = "100%";
          pulse.style.height = "100%";
          pulse.style.borderRadius = "50%";
          pulse.style.background = options.pulseColor || color;
          pulse.style.pointerEvents = "none";
          pulse.style.animation = "osmlib-dot-pulse " + String(Math.max(0.2, options.pulseDuration || 1.8)) + "s infinite";
          if (options.pulseRadius > 0) {
            pulse.style.width = String(Math.round(options.pulseRadius * 2)) + "px";
            pulse.style.height = String(Math.round(options.pulseRadius * 2)) + "px";
          }
          element.appendChild(pulse);
        }
        glyph.style.left = "50%";
        glyph.style.top = "50%";
      } else {
        const padding = Math.max(0, Math.round(options.padding || 0));
        const pointerLength = Math.max(8, Math.round(options.pointerLength || (12 * scale)));
        const pointerWidth = Math.max(8, Math.round(options.pointerWidth || (14 * scale)));
        const width = Math.max(22, Math.round(Math.max(options.minWidth || 0, 28 * scale) + padding * 2));
        const bodyHeight = Math.max(20, Math.round(Math.max(options.minHeight || 0, 22 * scale) + padding * 2));
        const height = bodyHeight + pointerLength;
        const pinBody = document.createElement("div");
        const pinTail = document.createElement("div");
        const shapeVariant = options.shapeVariant || "classic";

        element.style.width = String(width) + "px";
        element.style.height = String(height) + "px";

        pinBody.className = "osmlib-marker-body";
        pinBody.style.position = "absolute";
        pinBody.style.left = "50%";
        pinBody.style.top = "0";
        pinBody.style.width = String(width) + "px";
        pinBody.style.height = String(bodyHeight) + "px";
        pinBody.style.background = color;
        if (borderWidth > 0) {
          pinBody.style.border = String(borderWidth) + "px solid " + borderColor;
        }
        pinBody.style.transform = "translateX(-50%)";
        pinBody.style.borderRadius = options.cornerStyle === "square"
          ? "4px"
          : (options.cornerStyle === "pill" || shapeVariant === "pill"
            ? String(Math.round(bodyHeight / 2)) + "px"
            : (shapeVariant === "bubble" ? "18px" : (shapeVariant === "tag" ? "10px 16px 16px 10px" : "12px")));
        if (options.shadowEnabled) {
          pinBody.style.boxShadow = "0 2px " + String(Math.max(2, options.shadowBlur || 8)) +
            "px " + (options.shadowColor || "rgba(0, 0, 0, 0.35)");
        }

        pinTail.className = "osmlib-marker-tail";
        pinTail.style.position = "absolute";
        pinTail.style.left = "50%";
        pinTail.style.bottom = "0";
        pinTail.style.width = "0";
        pinTail.style.height = "0";
        pinTail.style.transform = "translateX(-50%)";
        pinTail.style.borderLeft = String(Math.round(pointerWidth / 2)) + "px solid transparent";
        pinTail.style.borderRight = String(Math.round(pointerWidth / 2)) + "px solid transparent";
        pinTail.style.borderTop = String(pointerLength) + "px solid " + color;

        if (shapeVariant === "bubble") {
          pinTail.style.display = "none";
          element.style.height = String(bodyHeight) + "px";
        } else if (shapeVariant === "tag") {
          pinTail.style.borderLeft = String(Math.round(pointerWidth * 0.35)) + "px solid transparent";
          pinTail.style.borderRight = String(Math.round(pointerWidth * 0.65)) + "px solid transparent";
        } else if (shapeVariant === "pill") {
          pinTail.style.borderLeft = String(Math.round(pointerWidth * 0.45)) + "px solid transparent";
          pinTail.style.borderRight = String(Math.round(pointerWidth * 0.45)) + "px solid transparent";
        }

        element.appendChild(pinBody);
        if (shapeVariant !== "bubble") {
          element.appendChild(pinTail);
        }
        glyph.style.left = "50%";
        glyph.style.top = String(Math.round(bodyHeight / 2)) + "px";
      }

      element.appendChild(glyph);
      return element;
    },

    applyMarkerVisibility: function (entry) {
      if (!entry || !entry.marker) {
        return;
      }

      const element = entry.marker.getElement();
      if (!element) {
        return;
      }

      element.style.display = entry.options.visible ? "" : "none";
    },

    refreshPopupsAnchoredToMarker: function (objectId) {
      const popupIds = Object.keys(this.popups);
      for (let i = 0; i < popupIds.length; i += 1) {
        const entry = this.popups[popupIds[i]];
        if (!entry || !entry.options || entry.options.anchorObjectId !== objectId) {
          continue;
        }

        const lngLat = this.resolvePopupLngLat(entry.options);
        if (lngLat) {
          entry.popup.setLngLat(lngLat);
        }
      }
    },

    closePopupsAnchoredToMarker: function (objectId) {
      const popupIds = Object.keys(this.popups);
      for (let i = 0; i < popupIds.length; i += 1) {
        const popupId = popupIds[i];
        const entry = this.popups[popupId];
        if (!entry || !entry.options || entry.options.anchorObjectId !== objectId) {
          continue;
        }

        // When the anchor disappears, close the popup instead of leaving it orphaned.
        entry.options.visible = false;
        if (entry.popup && entry.popup.isOpen()) {
          entry.popup.remove();
        }
      }
    },

    applyMarkerTitle: function (entry) {
      if (!entry || !entry.marker) {
        return;
      }

      const element = entry.marker.getElement();
      if (!element) {
        return;
      }

      const title = entry.options && typeof entry.options.title === "string"
        ? entry.options.title
        : "";

      element.title = title;
      if (title) {
        element.setAttribute("aria-label", title);
      } else {
        element.removeAttribute("aria-label");
      }
    },

    applyMarkerGlyph: function (entry) {
      if (!entry || !entry.marker) {
        return;
      }

      const element = entry.marker.getElement();
      if (!element) {
        return;
      }

      const svg = element.querySelector("svg");
      if (svg && entry.options.kind === "standard") {
        const circles = svg.querySelectorAll("circle");
        circles.forEach((circle) => {
          circle.style.opacity = entry.options.hideDefaultCenterDot ? "0" : "";
        });
      }

      let glyphElement = element.querySelector(".osmlib-marker-glyph");
      if (!entry.options.glyphText || (entry.options.kind === "standard" && !entry.options.useGlyph)) {
        if (glyphElement && glyphElement.parentNode) {
          glyphElement.parentNode.removeChild(glyphElement);
        }
        return;
      }

      if (!glyphElement) {
        glyphElement = document.createElement("span");
        glyphElement.className = "osmlib-marker-glyph";
        glyphElement.style.position = "absolute";
        glyphElement.style.pointerEvents = "none";
        glyphElement.style.fontWeight = "700";
        glyphElement.style.fontFamily = "Segoe UI, Arial, sans-serif";
        glyphElement.style.color = "#ffffff";
        glyphElement.style.textShadow = "0 1px 2px rgba(0, 0, 0, 0.45)";
        element.appendChild(glyphElement);
      }

      if (entry.options.kind === "dot") {
        glyphElement.style.left = "50%";
        glyphElement.style.top = "50%";
        glyphElement.style.width = "";
        glyphElement.style.textAlign = "";
        glyphElement.style.transform = "translate(-50%, -50%)";
      } else if (entry.options.kind === "pin") {
        glyphElement.style.left = "50%";
        glyphElement.style.top = "50%";
        glyphElement.style.width = "";
        glyphElement.style.textAlign = "";
        glyphElement.style.transform = "translate(-50%, -50%)";
      } else {
        glyphElement.style.left = "0";
        glyphElement.style.top = "50%";
        glyphElement.style.width = "100%";
        glyphElement.style.textAlign = "center";
        glyphElement.style.transform = "translateY(-50%)";
      }

      glyphElement.textContent = entry.options.glyphText;
      glyphElement.style.fontSize = String(
        Number.isFinite(entry.options.glyphFontSize) && entry.options.glyphFontSize > 0
          ? Math.round(entry.options.glyphFontSize)
          : Math.max(10, Math.round(11 * entry.options.scale))
      ) + "px";
      glyphElement.style.color = entry.options.glyphTextColor || "#ffffff";
      glyphElement.style.marginLeft = String(Math.round(entry.options.glyphOffsetX || 0)) + "px";
      glyphElement.style.marginTop = String(Math.round(entry.options.glyphOffsetY || 0)) + "px";
    },

    applyMarkerPresentation: function (entry) {
      if (!entry || !entry.marker) {
        return;
      }

      const element = entry.marker.getElement();
      if (!element) {
        return;
      }

      const svg = element.querySelector("svg");
      const markerOpacity = String(Math.max(0, Math.min(1, entry.options.opacity)));
      element.style.opacity = markerOpacity;
      element.style.zIndex = String(Math.round(entry.options.zIndex || 0));
      if (svg) {
        svg.style.opacity = markerOpacity;
      }

      if (typeof entry.marker.setRotation === "function") {
        entry.marker.setRotation(entry.options.rotation || 0);
      }

      if (entry.options.kind === "standard" && entry.options.useDefaultMapLibreShape) {
        if (entry.options.borderWidth > 0) {
          element.style.outline = String(entry.options.borderWidth) + "px solid " + (entry.options.borderColor || "#000000");
          element.style.outlineOffset = "0";
          if (svg) {
            svg.style.outline = element.style.outline;
            svg.style.outlineOffset = "0";
          }
        } else {
          element.style.outline = "";
          if (svg) {
            svg.style.outline = "";
          }
        }

        if (entry.options.shadowEnabled) {
          element.style.filter = "drop-shadow(0 2px 6px rgba(0, 0, 0, 0.35))";
          if (svg) {
            svg.style.filter = element.style.filter;
          }
        } else {
          element.style.filter = "";
          if (svg) {
            svg.style.filter = "";
          }
        }
      }
    },

    hasMarkerStructureChange: function (previousOptions, nextOptions) {
      const structuralKeys = [
        "kind",
        "color",
        "backgroundColor",
        "borderColor",
        "borderWidth",
        "scale",
        "useDefaultMapLibreShape",
        "shapeVariant",
        "cornerStyle",
        "padding",
        "minWidth",
        "minHeight",
        "pointerLength",
        "pointerWidth",
        "radius",
        "diameter",
        "pulseEnabled",
        "pulseColor",
        "pulseRadius",
        "pulseDuration",
        "shadowEnabled",
        "shadowColor",
        "shadowBlur",
        "anchorX",
        "anchorY"
      ];

      return structuralKeys.some((key) => previousOptions[key] !== nextOptions[key]);
    },

    registerMarkerEvents: function (entry) {
      const marker = entry.marker;
      const objectId = entry.options.objectId;

      const sendMarkerPositionEvent = (eventName) => {
        const markerLngLat = marker.getLngLat();
        sendMessage("marker.event." + eventName, this.mapId, {
          objectId: objectId,
          latLng: {
            lat: safeNumber(markerLngLat ? markerLngLat.lat : entry.options.lat, entry.options.lat),
            lng: safeNumber(markerLngLat ? markerLngLat.lng : entry.options.lng, entry.options.lng)
          }
        });
      };

      const element = marker.getElement();
      element.style.cursor = "pointer";
      element.addEventListener("click", (ev) => {
        ev.stopPropagation();
        sendMarkerPositionEvent("click");
        const popup = marker.getPopup();
        if (popup) {
          popup.setLngLat(marker.getLngLat());
          if (popup.isOpen()) {
            popup.remove();
          } else {
            popup.addTo(this.map);
          }
        }
      });
      element.addEventListener("dblclick", (ev) => {
        ev.stopPropagation();
        sendMarkerPositionEvent("dblclick");
      });
      element.addEventListener("mouseenter", () => sendMarkerPositionEvent("mouseenter"));
      element.addEventListener("mouseleave", () => sendMarkerPositionEvent("mouseleave"));
      element.addEventListener("mousedown", () => sendMarkerPositionEvent("mousedown"));
      element.addEventListener("mouseup", () => sendMarkerPositionEvent("mouseup"));

      marker.on("dragstart", () => sendMarkerPositionEvent("dragstart"));
      marker.on("drag", () => {
        this.refreshPopupsAnchoredToMarker(objectId);
        sendMarkerPositionEvent("drag");
      });
      marker.on("dragend", () => {
        this.refreshPopupsAnchoredToMarker(objectId);
        sendMarkerPositionEvent("dragend");
      });
    },

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
      if (typeof payload.minPitch === "number") {
        this.map.setMinPitch(payload.minPitch);
      }
      if (typeof payload.maxPitch === "number") {
        this.map.setMaxPitch(payload.maxPitch);
      }
      if (Object.prototype.hasOwnProperty.call(payload, "maxBounds")) {
        if (payload.maxBounds && typeof payload.maxBounds === "object") {
          this.map.setMaxBounds([
            [safeNumber(payload.maxBounds.west, 0), safeNumber(payload.maxBounds.south, 0)],
            [safeNumber(payload.maxBounds.east, 0), safeNumber(payload.maxBounds.north, 0)]
          ]);
        } else {
          this.map.setMaxBounds(null);
        }
      }
      if (typeof payload.renderWorldCopies === "boolean") {
        this.map.setRenderWorldCopies(payload.renderWorldCopies);
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
          minPitch: safeNumber(config.minPitch, 0),
          maxPitch: safeNumber(config.maxPitch, 60),
          maxBounds: config.maxBounds ? [
            [safeNumber(config.maxBounds.west, 0), safeNumber(config.maxBounds.south, 0)],
            [safeNumber(config.maxBounds.east, 0), safeNumber(config.maxBounds.north, 0)]
          ] : null,
          renderWorldCopies: safeBoolean(config.renderWorldCopies, true),
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
      try {
        const options = this.normalizeMarkerOptions(payload);
        const objectId = options.objectId;
        if (!objectId) {
          return;
        }

      this.removeMarker(objectId);

        const markerOptions = {
          draggable: options.draggable
        };
        if (Number.isFinite(options.rotation)) {
          markerOptions.rotation = options.rotation;
        }
        if ((options.anchorX !== 0) || (options.anchorY !== 0)) {
          markerOptions.offset = [options.anchorX, options.anchorY];
        }
        if (options.kind === "standard" && options.useDefaultMapLibreShape) {
          if (options.color) {
            markerOptions.color = options.color;
          }
          if (Number.isFinite(options.scale) && options.scale > 0) {
            markerOptions.scale = options.scale;
          }
        } else {
          markerOptions.element = this.buildCustomMarkerElement(options);
          markerOptions.anchor = (options.kind === "dot" || (options.kind === "standard" && !options.useDefaultMapLibreShape))
            ? "center"
            : "bottom";
        }

        const marker = new maplibregl.Marker(markerOptions).setLngLat([options.lng, options.lat]);
        const popup = this.buildMarkerPopup(options);
        if (popup) {
          marker.setPopup(popup);
        }

        marker.addTo(this.map);
        const entry = { marker: marker, options: options };
        this.registerMarkerEvents(entry);
        this.applyMarkerVisibility(entry);
        this.applyMarkerTitle(entry);
        this.applyMarkerGlyph(entry);
        this.applyMarkerPresentation(entry);

        this.markers[objectId] = entry;
        this.refreshPopupsAnchoredToMarker(objectId);
      } catch (error) {
        sendMessage("map.event.error", this.mapId, {
          message: "OSM marker add failed: " + (error && error.message ? error.message : String(error))
        });
      }
    },

    updateMarkerOptions: function (payload) {
      if (!this.map || !payload) {
        return;
      }
      try {
        const options = this.normalizeMarkerOptions(payload);
        const objectId = options.objectId;
        const entry = this.markers[objectId];

        if (!objectId) {
          return;
        }
        if (!entry) {
          this.addMarker(options);
          return;
        }

        const requiresRecreate = this.hasMarkerStructureChange(entry.options, options);

        if (requiresRecreate) {
          this.addMarker(options);
          return;
        }

        entry.options = options;
        entry.marker.setLngLat([options.lng, options.lat]);
        entry.marker.setDraggable(options.draggable);
        entry.marker.setPopup(this.buildMarkerPopup(options));
        this.applyMarkerVisibility(entry);
        this.applyMarkerTitle(entry);
        this.applyMarkerGlyph(entry);
        this.applyMarkerPresentation(entry);
        this.refreshPopupsAnchoredToMarker(objectId);
      } catch (error) {
        sendMessage("map.event.error", this.mapId, {
          message: "OSM marker update failed: " + (error && error.message ? error.message : String(error))
        });
      }
    },

    removeMarker: function (objectId) {
      if (!objectId || !this.markers[objectId]) {
        return;
      }
      this.closePopupsAnchoredToMarker(objectId);
      this.markers[objectId].marker.remove();
      delete this.markers[objectId];
    },

    clearMarkers: function () {
      const ids = Object.keys(this.markers);
      for (let i = 0; i < ids.length; i += 1) {
        this.removeMarker(ids[i]);
      }
    },

    addPopup: function (payload) {
      if (!this.map || !payload) {
        return;
      }

      const options = this.normalizePopupOptions(payload);
      const objectId = options.objectId;
      if (!objectId) {
        return;
      }

      this.removePopup(objectId, true);

      const popup = this.buildPopup(options);
      popup.__osmlibObjectId = objectId;
      popup.setLngLat(this.resolvePopupLngLat(options));
      popup.on("open", () => {
        const entry = this.popups[objectId];
        if (entry) {
          entry.options.visible = true;
        }
        sendMessage("popup.event.open", this.mapId, { objectId: objectId });
      });
      popup.on("close", () => {
        const entry = this.popups[objectId];
        if (entry) {
          entry.options.visible = false;
          if (entry.silentClose) {
            entry.silentClose = false;
            return;
          }
        }
        sendMessage("popup.event.close", this.mapId, { objectId: objectId });
      });

      if (options.visible) {
        popup.addTo(this.map);
      }

      this.popups[objectId] = { popup: popup, options: options };
    },

    updatePopupOptions: function (payload) {
      if (!this.map || !payload) {
        return;
      }

      const options = this.normalizePopupOptions(payload);
      const objectId = options.objectId;
      if (!objectId) {
        return;
      }

      const entry = this.popups[objectId];
      if (!entry) {
        this.addPopup(options);
        return;
      }

      if (entry.options.anchorObjectId !== options.anchorObjectId ||
          entry.options.contentType !== options.contentType ||
          entry.options.cssClass !== options.cssClass ||
          entry.options.closeButton !== options.closeButton ||
          entry.options.closeOnClick !== options.closeOnClick ||
          entry.options.closeOnMove !== options.closeOnMove) {
        this.addPopup(options);
        return;
      }

      const popup = entry.popup;
      entry.options = options;
      if (options.contentType === "text") {
        popup.setText(options.content || "");
      } else {
        popup.setHTML(options.content || "");
      }
      popup.setLngLat(this.resolvePopupLngLat(options));
      if (options.maxWidth > 0) {
        popup.setMaxWidth(String(options.maxWidth) + "px");
      } else {
        popup.setMaxWidth("none");
      }

      if (options.visible) {
        if (!popup.isOpen()) {
          popup.addTo(this.map);
        }
      } else if (popup.isOpen()) {
        popup.remove();
      }
    },

    removePopup: function (objectId, silent) {
      if (!objectId || !this.popups[objectId]) {
        return;
      }

      const entry = this.popups[objectId];
      entry.silentClose = !!silent;
      if (entry.popup && entry.popup.isOpen()) {
        entry.popup.remove();
      }
      delete this.popups[objectId];
    },

    clearPopups: function () {
      const ids = Object.keys(this.popups);
      for (let i = 0; i < ids.length; i += 1) {
        this.removePopup(ids[i], true);
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
    } else if (envelope.type === "marker.set_options") {
      window.osmlib.updateMarkerOptions(payload);
    } else if (envelope.type === "popup.add") {
      window.osmlib.addPopup(payload);
    } else if (envelope.type === "popup.clear") {
      window.osmlib.clearPopups();
    } else if (envelope.type === "popup.remove") {
      window.osmlib.removePopup(payload.objectId, true);
    } else if (envelope.type === "popup.set_options") {
      window.osmlib.updatePopupOptions(payload);
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
