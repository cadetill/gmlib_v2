(function () {
  let messageSequence = 0;

  function ensureMessageQueue() {
    window.gmlib = window.gmlib || {};
    window.gmlib.__messageQueue = window.gmlib.__messageQueue || [];
    return window.gmlib.__messageQueue;
  }

  function ensureLibCache() {
    window.gmlib = window.gmlib || {};
    window.gmlib._libs = window.gmlib._libs || {};
    return window.gmlib._libs;
  }

  function getLib(libName) {
    const libs = ensureLibCache();
    if (libs[libName]) {
      return libs[libName];
    }

    if (!window.google || !google.maps || typeof google.maps.importLibrary !== "function") {
      libs[libName] = Promise.resolve(null);
      return libs[libName];
    }

    libs[libName] = google.maps.importLibrary(libName).catch((error) => {
      delete libs[libName];
      throw error;
    });
    return libs[libName];
  }

  function sendEnvelope(envelope) {
    if (!envelope || typeof envelope !== "object") {
      return;
    }
    // Keep a single transport shape for WebView2, CEF and iframe fallback.
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
      return;
    }
  }

  function sendMessage(messageType, targetId, payload) {
    sendEnvelope({ type: messageType, targetId: targetId, payload: payload });
  }

  window.gmlib = window.gmlib || {};
  window.gmlib.__messageQueue = window.gmlib.__messageQueue || [];
  window.gmlib.getLib = getLib;
  window.gmlib.sendEnvelope = sendEnvelope;
  window.gmlib.reportBootstrapError = function (message) {
    sendEnvelope({
      type: "map.load_error",
      targetId: window.gmlib.bootstrapMapId || "",
      payload: String(message || "")
    });
  };
  window.gmlib.infoWindow = {
    instances: {},
    listeners: {},

    extractPosition: function (position) {
      if (!position) { return null; }
      if (typeof position.lat === "function" && typeof position.lng === "function") {
        return { lat: position.lat(), lng: position.lng() };
      }
      if (typeof position.lat === "number" && typeof position.lng === "number") {
        return { lat: position.lat, lng: position.lng };
      }
      return null;
    },

    ensureInstance: function (infoWindowId) {
      let infoWindow = this.instances[infoWindowId];
      if (infoWindow) {
        return infoWindow;
      }

      infoWindow = new google.maps.InfoWindow();
      infoWindow.__gmlibOpen = false;
      infoWindow.__gmlibState = {
        content: "",
        headerContent: "",
        headerDisabled: false,
        zIndex: 0
      };
      this.instances[infoWindowId] = infoWindow;

      this.listeners[infoWindowId] = [
        infoWindow.addListener("close", () => {
          infoWindow.__gmlibOpen = false;
          sendMessage("infowindow.close", infoWindowId, "");
        }),
        infoWindow.addListener("closeclick", () => {
          infoWindow.__gmlibOpen = false;
          sendMessage("infowindow.closeclick", infoWindowId, "");
        }),
        infoWindow.addListener("domready", () => {
          sendMessage("infowindow.domready", infoWindowId, "");
        }),
        infoWindow.addListener("position_changed", () => {
          const position = this.extractPosition(infoWindow.getPosition());
          if (position) {
            sendMessage("infowindow.position_changed", infoWindowId, position);
          }
        }),
        infoWindow.addListener("visible", () => {
          infoWindow.__gmlibOpen = true;
          sendMessage("infowindow.visible", infoWindowId, "");
        })
      ];

      return infoWindow;
    },

    remove: function (infoWindowId) {
      const infoWindow = this.instances[infoWindowId];
      if (!infoWindow) { return; }
      google.maps.event.clearInstanceListeners(infoWindow);
      infoWindow.close();
      delete this.listeners[infoWindowId];
      delete this.instances[infoWindowId];
    },

    open: function (infoWindowId, openOptions) {
      const infoWindow = this.instances[infoWindowId];
      if (!infoWindow || !window.gmlib.map.instance) { return; }
      const resolvedOptions = openOptions || {};
      const anchorId = resolvedOptions.anchorId || "";
      const anchor = anchorId && window.gmlib.marker && window.gmlib.marker.instances
        ? window.gmlib.marker.instances[anchorId] || null
        : null;

      if (anchor) {
        infoWindow.open({
          anchor: anchor,
          map: window.gmlib.map.instance,
          shouldFocus: resolvedOptions.shouldFocus === true
        });
      } else {
        infoWindow.open({
          map: window.gmlib.map.instance,
          shouldFocus: resolvedOptions.shouldFocus === true
        });
      }
      infoWindow.__gmlibOpen = true;
    },

    close: function (infoWindowId) {
      const infoWindow = this.instances[infoWindowId];
      if (!infoWindow) { return; }
      infoWindow.close();
      infoWindow.__gmlibOpen = false;
    },

    focus: function (infoWindowId) {
      const infoWindow = this.instances[infoWindowId];
      if (!infoWindow || infoWindow.__gmlibOpen !== true || typeof infoWindow.focus !== "function") {
        return;
      }
      infoWindow.focus();
    },

    setOptions: function (infoWindowId, options) {
      if (!window.gmlib.map.instance) { return; }
      const infoWindow = this.ensureInstance(infoWindowId);
      const state = infoWindow.__gmlibState || {
        content: "",
        headerContent: "",
        headerDisabled: false
      };
      const nextContent = options.content || "";
      const nextHeaderContent = options.headerContent || "";
      const nextHeaderDisabled = options.headerDisabled === true;
      const nextZIndex = typeof options.zIndex === "number" ? options.zIndex : 0;

      infoWindow.setOptions({
        ariaLabel: options.ariaLabel || "",
        content: nextContent,
        disableAutoPan: options.disableAutoPan === true,
        headerContent: nextHeaderContent,
        headerDisabled: nextHeaderDisabled,
        maxWidth: typeof options.maxWidth === "number" ? options.maxWidth : undefined,
        minWidth: typeof options.minWidth === "number" ? options.minWidth : undefined,
        pixelOffset: options.pixelOffset &&
          typeof options.pixelOffset.width === "number" &&
          typeof options.pixelOffset.height === "number"
            ? new google.maps.Size(options.pixelOffset.width, options.pixelOffset.height)
            : undefined,
        position: options.position || infoWindow.getPosition(),
        zIndex: typeof options.zIndex === "number" ? options.zIndex : undefined
      });

      if (state.content !== nextContent) {
        state.content = nextContent;
        sendMessage("infowindow.content_changed", infoWindowId, nextContent);
      }

      if (state.headerContent !== nextHeaderContent) {
        state.headerContent = nextHeaderContent;
        sendMessage("infowindow.headercontent_changed", infoWindowId, nextHeaderContent);
      }

      if (state.headerDisabled !== nextHeaderDisabled) {
        state.headerDisabled = nextHeaderDisabled;
        sendMessage("infowindow.headerdisabled_changed", infoWindowId, nextHeaderDisabled);
      }

      if (state.zIndex !== nextZIndex) {
        state.zIndex = nextZIndex;
        sendMessage("infowindow.zindex_changed", infoWindowId, String(nextZIndex));
      }

      infoWindow.__gmlibState = state;
    }
  };

  window.gmlib.marker = {
    instances: {},
    library: null,

    buildContent: function (options) {
      const contentMode = options && options.contentMode ? String(options.contentMode) : "default";
      const htmlOptions = options && options.htmlOptions ? options.htmlOptions : {};
      const labelOptions = options && options.labelOptions ? options.labelOptions : {};
      const pinOptions = options && options.pinOptions ? options.pinOptions : {};

      if (contentMode === "html") {
        const wrapper = document.createElement("div");
        if (htmlOptions.cssClassName) {
          wrapper.className = htmlOptions.cssClassName;
        }
        wrapper.innerHTML = htmlOptions.html || "";
        return wrapper;
      }

      if (contentMode === "label") {
        const wrapper = document.createElement("div");
        if (labelOptions.cssClassName) {
          wrapper.className = labelOptions.cssClassName;
        }
        wrapper.textContent = labelOptions.text || "";
        wrapper.style.background = labelOptions.background || "#7c3aed";
        wrapper.style.border = "2px solid " + (labelOptions.borderColor || "#c4b5fd");
        wrapper.style.color = labelOptions.textColor || "#faf5ff";
        wrapper.style.padding = (labelOptions.paddingVertical || 8) + "px " + (labelOptions.paddingHorizontal || 14) + "px";
        wrapper.style.borderRadius = (labelOptions.cornerRadius || 999) + "px";
        wrapper.style.fontSize = (labelOptions.fontSize || 13) + "px";
        wrapper.style.fontWeight = labelOptions.fontBold ? "700" : "400";
        wrapper.style.lineHeight = "1";
        wrapper.style.whiteSpace = "nowrap";
        return wrapper;
      }

      if (contentMode === "pin" && this.library && typeof this.library.PinElement === "function") {
        const pin = new this.library.PinElement({
          background: pinOptions.background || "#0f766e",
          borderColor: pinOptions.borderColor || "#134e4a",
          glyphColor: pinOptions.glyphColor || "#ffffff",
          glyphText: pinOptions.glyphText || "",
          scale: typeof pinOptions.scale === "number" ? pinOptions.scale : 1
        });
        return pin.element || pin;
      }

      return null;
    },

    buildContentSignature: function (options) {
      const contentMode = options && options.contentMode ? String(options.contentMode) : "default";
      const htmlOptions = options && options.htmlOptions ? options.htmlOptions : {};
      const labelOptions = options && options.labelOptions ? options.labelOptions : {};
      const pinOptions = options && options.pinOptions ? options.pinOptions : {};

      return JSON.stringify({
        contentMode: contentMode,
        htmlOptions: htmlOptions,
        labelOptions: labelOptions,
        pinOptions: pinOptions
      });
    },

    extractPosition: function (position) {
      if (!position) { return null; }
      if (typeof position.lat === "function" && typeof position.lng === "function") {
        return { lat: position.lat(), lng: position.lng() };
      }
      if (typeof position.lat === "number" && typeof position.lng === "number") {
        return { lat: position.lat, lng: position.lng };
      }
      return null;
    },

    ensureInstance: function (markerId, options) {
      let marker = this.instances[markerId];
      if (!marker) {
        const nextContent = this.buildContent(options || {});
        const markerOptions = {
          map: options.visible === false ? null : window.gmlib.map.instance,
          position: options.position,
          title: options.title || "",
          gmpClickable: options.gmpClickable !== false,
          gmpDraggable: options.gmpDraggable === true,
          zIndex: typeof options.zIndex === "number" ? options.zIndex : 0
        };
        if (nextContent) {
          markerOptions.content = nextContent;
        }
        marker = new this.library.AdvancedMarkerElement(markerOptions);

        google.maps.event.addListener(marker, "click", () => {
          sendMessage("marker.click", markerId, "");
        });
        if (typeof marker.addListener === "function") {
          marker.addListener("dragstart", () => {
            const position = this.extractPosition(marker.position) ||
              this.extractPosition(marker.getPosition ? marker.getPosition() : null);
            console.log("gmlib.marker.dragstart", markerId, position);
            sendMessage("marker.dragstart", markerId, position || "");
          });
          marker.addListener("drag", () => {
            const position = this.extractPosition(marker.position) ||
              this.extractPosition(marker.getPosition ? marker.getPosition() : null);
            sendMessage("marker.drag", markerId, position || "");
          });
          marker.addListener("dragend", () => {
            const position = this.extractPosition(marker.position) ||
              this.extractPosition(marker.getPosition ? marker.getPosition() : null);
            console.log("gmlib.marker.dragend", markerId, position);
            sendMessage("marker.dragend", markerId, position || "");
          });
        }
        this.instances[markerId] = marker;
        marker.__gmlibContentSignature = this.buildContentSignature(options || {});
      }
      return marker;
    },

    remove: function (markerId) {
      const marker = this.instances[markerId];
      if (!marker) { return; }
      if (typeof marker.setMap === "function") {
        marker.setMap(null);
      } else {
        marker.map = null;
      }
      delete this.instances[markerId];
    },

    applyOptions: function (markerId, options) {
      let marker = this.ensureInstance(markerId, options || {});
      if (!marker) {
        return;
      }
      const nextContentSignature = this.buildContentSignature(options || {});
      if (marker.__gmlibContentSignature !== nextContentSignature) {
        marker.setMap(null);
        delete this.instances[markerId];
        marker = this.ensureInstance(markerId, options || {});
        if (!marker) {
          return;
        }
      }
      const nextContent = this.buildContent(options || {});
      if (nextContent && "content" in marker) {
        marker.content = nextContent;
      }
      if (typeof marker.setPosition === "function") {
        marker.setPosition(options.position || (marker.getPosition ? marker.getPosition() : marker.position));
      } else {
        marker.position = options.position || marker.position;
      }
      if (typeof marker.setTitle === "function") {
        marker.setTitle(options.title || "");
      } else {
        marker.title = options.title || "";
      }
      if (typeof marker.setZIndex === "function") {
        marker.setZIndex(typeof options.zIndex === "number" ? options.zIndex : 0);
      } else {
        marker.zIndex = typeof options.zIndex === "number" ? options.zIndex : 0;
      }
      if (typeof options.gmpClickable === "boolean") {
        marker.gmpClickable = options.gmpClickable;
      }
      if (typeof options.gmpDraggable === "boolean") {
        marker.gmpDraggable = options.gmpDraggable;
      }
      if (typeof marker.setMap === "function") {
        marker.setMap(options.visible === false ? null : window.gmlib.map.instance);
      } else {
        marker.map = options.visible === false ? null : window.gmlib.map.instance;
      }
      marker.__gmlibContentSignature = nextContentSignature;
    },

    setOptions: function (markerId, options) {
      if (!window.gmlib.map.instance) { return; }
      this.applyOptions(markerId, options || {});
    }
  };

  window.gmlib.polyline = {
    instances: {},
    pathListeners: {},

    extractPath: function (polyline) {
      const path = polyline && typeof polyline.getPath === "function" ? polyline.getPath() : null;
      const items = [];
      let index;
      let point;
      if (!path || typeof path.getLength !== "function") {
        return items;
      }

      for (index = 0; index < path.getLength(); index += 1) {
        point = path.getAt(index);
        if (!point) { continue; }
        items.push({ lat: point.lat(), lng: point.lng() });
      }

      return items;
    },

    detachPathListeners: function (polylineId) {
      const listeners = this.pathListeners[polylineId];
      let index;
      if (!listeners) { return; }

      for (index = 0; index < listeners.length; index += 1) {
        google.maps.event.removeListener(listeners[index]);
      }

      delete this.pathListeners[polylineId];
    },

    bindPathListeners: function (polylineId, polyline) {
      const path = polyline && typeof polyline.getPath === "function" ? polyline.getPath() : null;
      const notifyPathChanged = () => {
        if (polyline.__gmlibSyncing === true) {
          return;
        }
        sendMessage("polyline.path_changed", polylineId, this.extractPath(polyline));
      };

      this.detachPathListeners(polylineId);

      if (!path || typeof path.addListener !== "function") {
        return;
      }

      this.pathListeners[polylineId] = [
        path.addListener("insert_at", notifyPathChanged),
        path.addListener("remove_at", notifyPathChanged),
        path.addListener("set_at", notifyPathChanged)
      ];
    },

    ensureInstance: function (polylineId, options) {
      let polyline = this.instances[polylineId];
      if (!polyline) {
        polyline = new google.maps.Polyline({
          map: window.gmlib.map.instance,
          path: options.path || [],
          clickable: options.clickable !== false,
          draggable: options.draggable === true,
          editable: options.editable === true,
          geodesic: options.geodesic === true,
          strokeColor: options.strokeColor || "",
          strokeOpacity: typeof options.strokeOpacity === "number" ? options.strokeOpacity : 1,
          strokeWeight: typeof options.strokeWeight === "number" ? options.strokeWeight : 2,
          zIndex: typeof options.zIndex === "number" ? options.zIndex : 0
        });

        polyline.addListener("click", (event) => {
          if (event && event.latLng) {
            sendMessage("polyline.click", polylineId, {
              lat: event.latLng.lat(),
              lng: event.latLng.lng()
            });
          } else {
            sendMessage("polyline.click", polylineId, "");
          }
        });
        polyline.addListener("contextmenu", (event) => {
          if (event && event.latLng) {
            sendMessage("polyline.contextmenu", polylineId, {
              lat: event.latLng.lat(),
              lng: event.latLng.lng()
            });
          } else {
            sendMessage("polyline.contextmenu", polylineId, "");
          }
        });
        polyline.addListener("dblclick", (event) => {
          if (event && event.latLng) {
            sendMessage("polyline.dblclick", polylineId, {
              lat: event.latLng.lat(),
              lng: event.latLng.lng()
            });
          } else {
            sendMessage("polyline.dblclick", polylineId, "");
          }
        });
        polyline.addListener("dragstart", () => {
          sendMessage("polyline.dragstart", polylineId, "");
        });
        polyline.addListener("drag", () => {
          sendMessage("polyline.drag", polylineId, "");
        });
        polyline.addListener("dragend", () => {
          sendMessage("polyline.path_changed", polylineId, this.extractPath(polyline));
          sendMessage("polyline.dragend", polylineId, "");
        });
        polyline.addListener("mousedown", (event) => {
          if (event && event.latLng) {
            sendMessage("polyline.mousedown", polylineId, {
              lat: event.latLng.lat(),
              lng: event.latLng.lng()
            });
          } else {
            sendMessage("polyline.mousedown", polylineId, "");
          }
        });
        polyline.addListener("mousemove", (event) => {
          if (event && event.latLng) {
            sendMessage("polyline.mousemove", polylineId, {
              lat: event.latLng.lat(),
              lng: event.latLng.lng()
            });
          } else {
            sendMessage("polyline.mousemove", polylineId, "");
          }
        });
        polyline.addListener("mouseout", (event) => {
          if (event && event.latLng) {
            sendMessage("polyline.mouseout", polylineId, {
              lat: event.latLng.lat(),
              lng: event.latLng.lng()
            });
          } else {
            sendMessage("polyline.mouseout", polylineId, "");
          }
        });
        polyline.addListener("mouseover", (event) => {
          if (event && event.latLng) {
            sendMessage("polyline.mouseover", polylineId, {
              lat: event.latLng.lat(),
              lng: event.latLng.lng()
            });
          } else {
            sendMessage("polyline.mouseover", polylineId, "");
          }
        });
        polyline.addListener("mouseup", (event) => {
          if (event && event.latLng) {
            sendMessage("polyline.mouseup", polylineId, {
              lat: event.latLng.lat(),
              lng: event.latLng.lng()
            });
          } else {
            sendMessage("polyline.mouseup", polylineId, "");
          }
        });

        this.instances[polylineId] = polyline;
        this.bindPathListeners(polylineId, polyline);
      }

      return polyline;
    },

    remove: function (polylineId) {
      const polyline = this.instances[polylineId];
      if (!polyline) { return; }
      this.detachPathListeners(polylineId);
      google.maps.event.clearInstanceListeners(polyline);
      polyline.setMap(null);
      delete this.instances[polylineId];
    },

    setOptions: function (polylineId, options) {
      if (!window.gmlib.map.instance) { return; }
      const polyline = this.ensureInstance(polylineId, options || {});
      polyline.__gmlibSyncing = true;
      polyline.setOptions({
        path: options.path || [],
        clickable: options.clickable !== false,
        draggable: options.draggable === true,
        editable: options.editable === true,
        geodesic: options.geodesic === true,
        strokeColor: options.strokeColor || "",
        strokeOpacity: typeof options.strokeOpacity === "number" ? options.strokeOpacity : 1,
        strokeWeight: typeof options.strokeWeight === "number" ? options.strokeWeight : 2,
        zIndex: typeof options.zIndex === "number" ? options.zIndex : 0
      });
      polyline.__gmlibSyncing = false;
      this.bindPathListeners(polylineId, polyline);
      polyline.setMap(options.visible === false || !options.path || options.path.length === 0
        ? null
        : window.gmlib.map.instance);
    }
  };

  window.gmlib.polygon = {
    instances: {},
    pathListeners: {},

    extractPath: function (polygon) {
      const path = polygon && typeof polygon.getPath === "function" ? polygon.getPath() : null;
      const result = [];
      let pointIndex;
      let point;
      if (!path || typeof path.getLength !== "function") {
        return result;
      }

      for (pointIndex = 0; pointIndex < path.getLength(); pointIndex += 1) {
        point = path.getAt(pointIndex);
        if (!point) { continue; }
        result.push({ lat: point.lat(), lng: point.lng() });
      }

      return result;
    },

    detachPathListeners: function (polygonId) {
      const listeners = this.pathListeners[polygonId];
      let index;
      if (!listeners) { return; }

      for (index = 0; index < listeners.length; index += 1) {
        google.maps.event.removeListener(listeners[index]);
      }

      delete this.pathListeners[polygonId];
    },

    bindPathListeners: function (polygonId, polygon) {
      const path = polygon && typeof polygon.getPath === "function" ? polygon.getPath() : null;
      const notifyPathChanged = () => {
        if (polygon.__gmlibSyncing === true) {
          return;
        }
        sendMessage("polygon.path_changed", polygonId, this.extractPath(polygon));
      };

      this.detachPathListeners(polygonId);

      if (!path || typeof path.addListener !== "function") {
        return;
      }

      this.pathListeners[polygonId] = [
        path.addListener("insert_at", notifyPathChanged),
        path.addListener("remove_at", notifyPathChanged),
        path.addListener("set_at", notifyPathChanged)
      ];
    },

    ensureInstance: function (polygonId, options) {
      let polygon = this.instances[polygonId];
      if (!polygon) {
        polygon = new google.maps.Polygon({
          map: window.gmlib.map.instance,
          path: options.path || [],
          clickable: options.clickable !== false,
          draggable: options.draggable === true,
          editable: options.editable === true,
          fillColor: options.fillColor || "",
          fillOpacity: typeof options.fillOpacity === "number" ? options.fillOpacity : 0.35,
          geodesic: options.geodesic === true,
          strokeColor: options.strokeColor || "",
          strokeOpacity: typeof options.strokeOpacity === "number" ? options.strokeOpacity : 1,
          strokeWeight: typeof options.strokeWeight === "number" ? options.strokeWeight : 2,
          zIndex: typeof options.zIndex === "number" ? options.zIndex : 0
        });

        polygon.addListener("click", (event) => {
          if (event && event.latLng) {
            sendMessage("polygon.click", polygonId, {
              lat: event.latLng.lat(),
              lng: event.latLng.lng()
            });
          } else {
            sendMessage("polygon.click", polygonId, "");
          }
        });
        polygon.addListener("contextmenu", (event) => {
          if (event && event.latLng) {
            sendMessage("polygon.contextmenu", polygonId, {
              lat: event.latLng.lat(),
              lng: event.latLng.lng()
            });
          } else {
            sendMessage("polygon.contextmenu", polygonId, "");
          }
        });
        polygon.addListener("dblclick", (event) => {
          if (event && event.latLng) {
            sendMessage("polygon.dblclick", polygonId, {
              lat: event.latLng.lat(),
              lng: event.latLng.lng()
            });
          } else {
            sendMessage("polygon.dblclick", polygonId, "");
          }
        });
        polygon.addListener("dragstart", () => {
          sendMessage("polygon.dragstart", polygonId, "");
        });
        polygon.addListener("drag", () => {
          sendMessage("polygon.drag", polygonId, "");
        });
        polygon.addListener("dragend", () => {
          sendMessage("polygon.path_changed", polygonId, this.extractPath(polygon));
          sendMessage("polygon.dragend", polygonId, "");
        });
        polygon.addListener("mousedown", (event) => {
          if (event && event.latLng) {
            sendMessage("polygon.mousedown", polygonId, {
              lat: event.latLng.lat(),
              lng: event.latLng.lng()
            });
          } else {
            sendMessage("polygon.mousedown", polygonId, "");
          }
        });
        polygon.addListener("mousemove", (event) => {
          if (event && event.latLng) {
            sendMessage("polygon.mousemove", polygonId, {
              lat: event.latLng.lat(),
              lng: event.latLng.lng()
            });
          } else {
            sendMessage("polygon.mousemove", polygonId, "");
          }
        });
        polygon.addListener("mouseout", (event) => {
          if (event && event.latLng) {
            sendMessage("polygon.mouseout", polygonId, {
              lat: event.latLng.lat(),
              lng: event.latLng.lng()
            });
          } else {
            sendMessage("polygon.mouseout", polygonId, "");
          }
        });
        polygon.addListener("mouseover", (event) => {
          if (event && event.latLng) {
            sendMessage("polygon.mouseover", polygonId, {
              lat: event.latLng.lat(),
              lng: event.latLng.lng()
            });
          } else {
            sendMessage("polygon.mouseover", polygonId, "");
          }
        });
        polygon.addListener("mouseup", (event) => {
          if (event && event.latLng) {
            sendMessage("polygon.mouseup", polygonId, {
              lat: event.latLng.lat(),
              lng: event.latLng.lng()
            });
          } else {
            sendMessage("polygon.mouseup", polygonId, "");
          }
        });

        this.instances[polygonId] = polygon;
        this.bindPathListeners(polygonId, polygon);
      }

      return polygon;
    },

    remove: function (polygonId) {
      const polygon = this.instances[polygonId];
      if (!polygon) { return; }
      this.detachPathListeners(polygonId);
      google.maps.event.clearInstanceListeners(polygon);
      polygon.setMap(null);
      delete this.instances[polygonId];
    },

    setOptions: function (polygonId, options) {
      if (!window.gmlib.map.instance) { return; }
      options = options || {};
      const polygon = this.ensureInstance(polygonId, options);
      const hasPath = Array.isArray(options.path) && options.path.length > 0;
      polygon.__gmlibSyncing = true;
      polygon.setOptions({
        path: options.path || [],
        clickable: options.clickable !== false,
        draggable: options.draggable === true,
        editable: options.editable === true,
        fillColor: options.fillColor || "",
        fillOpacity: typeof options.fillOpacity === "number" ? options.fillOpacity : 0.35,
        geodesic: options.geodesic === true,
        strokeColor: options.strokeColor || "",
        strokeOpacity: typeof options.strokeOpacity === "number" ? options.strokeOpacity : 1,
        strokeWeight: typeof options.strokeWeight === "number" ? options.strokeWeight : 2,
        zIndex: typeof options.zIndex === "number" ? options.zIndex : 0
      });
      polygon.__gmlibSyncing = false;
      this.bindPathListeners(polygonId, polygon);
      polygon.setMap(options.visible === false || !hasPath
        ? null
        : window.gmlib.map.instance);
    }
  };

  window.gmlib.rectangle = {
    instances: {},

    ensureInstance: function (rectangleId, options) {
      let rectangle = this.instances[rectangleId];
      if (!rectangle) {
        rectangle = new google.maps.Rectangle({
          map: window.gmlib.map.instance,
          bounds: options.bounds || null,
          clickable: options.clickable !== false,
          draggable: options.draggable === true,
          editable: options.editable === true,
          fillColor: options.fillColor || "#FF0000",
          fillOpacity: typeof options.fillOpacity === "number" ? options.fillOpacity : 0.35,
          strokeColor: options.strokeColor || "#FF0000",
          strokeOpacity: typeof options.strokeOpacity === "number" ? options.strokeOpacity : 1,
          strokeWeight: typeof options.strokeWeight === "number" ? options.strokeWeight : 2,
          zIndex: typeof options.zIndex === "number" ? options.zIndex : 0
        });

        rectangle.addListener("click", (event) => {
          if (event && event.latLng) {
            sendMessage("rectangle.click", rectangleId, {
              lat: event.latLng.lat(),
              lng: event.latLng.lng()
            });
          } else {
            sendMessage("rectangle.click", rectangleId, "");
          }
        });

        rectangle.addListener("bounds_changed", () => {
          const bounds = rectangle.getBounds();
          if (bounds) {
            sendMessage("rectangle.bounds_changed", rectangleId, bounds.toJSON());
          }
        });

        rectangle.addListener("dragstart", () => {
          sendMessage("rectangle.dragstart", rectangleId, "");
        });

        rectangle.addListener("drag", () => {
          sendMessage("rectangle.drag", rectangleId, "");
        });

        rectangle.addListener("dragend", () => {
          sendMessage("rectangle.dragend", rectangleId, "");
        });

        this.instances[rectangleId] = rectangle;
      }

      return rectangle;
    },

    remove: function (rectangleId) {
      const rectangle = this.instances[rectangleId];
      if (!rectangle) { return; }
      google.maps.event.clearInstanceListeners(rectangle);
      rectangle.setMap(null);
      delete this.instances[rectangleId];
    },

    setOptions: function (rectangleId, options) {
      if (!window.gmlib.map.instance) { return; }
      options = options || {};
      const rectangle = this.ensureInstance(rectangleId, options);
      const hasBounds = options.bounds && options.bounds.north != null;
      rectangle.setOptions({
        bounds: options.bounds || null,
        clickable: options.clickable !== false,
        draggable: options.draggable === true,
        editable: options.editable === true,
        fillColor: options.fillColor || "#FF0000",
        fillOpacity: typeof options.fillOpacity === "number" ? options.fillOpacity : 0.35,
        strokeColor: options.strokeColor || "#FF0000",
        strokeOpacity: typeof options.strokeOpacity === "number" ? options.strokeOpacity : 1,
        strokeWeight: typeof options.strokeWeight === "number" ? options.strokeWeight : 2,
        zIndex: typeof options.zIndex === "number" ? options.zIndex : 0
      });
      rectangle.setMap(options.visible === false || !hasBounds
        ? null
        : window.gmlib.map.instance);
    }
  };

  window.gmlib.circle = {
    instances: {},

    extractCenter: function (circle) {
      if (!circle) { return null; }
      const center = circle.getCenter();
      if (!center) { return null; }
      if (typeof center.lat === "function" && typeof center.lng === "function") {
        return { lat: center.lat(), lng: center.lng() };
      }
      if (typeof center.lat === "number" && typeof center.lng === "number") {
        return { lat: center.lat, lng: center.lng };
      }
      return null;
    },

    ensureInstance: function (circleId, options) {
      let circle = this.instances[circleId];
      if (!circle) {
        console.log("gmlib.circle.ensureInstance", circleId, options);
        circle = new google.maps.Circle({
          map: window.gmlib.map.instance,
          center: options.center || { lat: 0, lng: 0 },
          radius: typeof options.radius === "number" ? options.radius : 1000,
          clickable: options.clickable !== false,
          draggable: options.draggable === true,
          editable: options.editable === true,
          fillColor: options.fillColor || "#FF0000",
          fillOpacity: typeof options.fillOpacity === "number" ? options.fillOpacity : 0.35,
          strokeColor: options.strokeColor || "#FF0000",
          strokeOpacity: typeof options.strokeOpacity === "number" ? options.strokeOpacity : 1,
          strokeWeight: typeof options.strokeWeight === "number" ? options.strokeWeight : 2,
          visible: options.visible !== false,
          zIndex: typeof options.zIndex === "number" ? options.zIndex : 0
        });

        circle.addListener("click", (event) => {
          if (event && event.latLng) {
            sendMessage("circle.click", circleId, {
              lat: event.latLng.lat(),
              lng: event.latLng.lng()
            });
          } else {
            sendMessage("circle.click", circleId, "");
          }
        });

        circle.addListener("center_changed", () => {
          const center = this.extractCenter(circle);
          if (center) {
            sendMessage("circle.center_changed", circleId, center);
          }
        });

        circle.addListener("radius_changed", () => {
          const radius = circle.getRadius();
          sendMessage("circle.radius_changed", circleId, String(radius));
        });

        circle.addListener("dragstart", () => {
          sendMessage("circle.dragstart", circleId, "");
        });

        circle.addListener("drag", () => {
          sendMessage("circle.drag", circleId, "");
        });

        circle.addListener("dragend", () => {
          const center = this.extractCenter(circle);
          if (center) {
            sendMessage("circle.center_changed", circleId, center);
          }
          const radius = circle.getRadius();
          sendMessage("circle.radius_changed", circleId, String(radius));
          sendMessage("circle.dragend", circleId, "");
        });

        circle.addListener("contextmenu", (event) => {
          if (event && event.latLng) {
            sendMessage("circle.contextmenu", circleId, {
              lat: event.latLng.lat(),
              lng: event.latLng.lng()
            });
          }
        });

        circle.addListener("dblclick", (event) => {
          if (event && event.latLng) {
            sendMessage("circle.dblclick", circleId, {
              lat: event.latLng.lat(),
              lng: event.latLng.lng()
            });
          }
        });

        circle.addListener("mousedown", (event) => {
          if (event && event.latLng) {
            sendMessage("circle.mousedown", circleId, {
              lat: event.latLng.lat(),
              lng: event.latLng.lng()
            });
          }
        });

        circle.addListener("mousemove", (event) => {
          if (event && event.latLng) {
            sendMessage("circle.mousemove", circleId, {
              lat: event.latLng.lat(),
              lng: event.latLng.lng()
            });
          }
        });

        circle.addListener("mouseout", (event) => {
          if (event && event.latLng) {
            sendMessage("circle.mouseout", circleId, {
              lat: event.latLng.lat(),
              lng: event.latLng.lng()
            });
          }
        });

        circle.addListener("mouseover", (event) => {
          if (event && event.latLng) {
            sendMessage("circle.mouseover", circleId, {
              lat: event.latLng.lat(),
              lng: event.latLng.lng()
            });
          }
        });

        circle.addListener("mouseup", (event) => {
          if (event && event.latLng) {
            sendMessage("circle.mouseup", circleId, {
              lat: event.latLng.lat(),
              lng: event.latLng.lng()
            });
          }
        });

        this.instances[circleId] = circle;
      }

      return circle;
    },

    remove: function (circleId) {
      const circle = this.instances[circleId];
      if (!circle) { return; }
      google.maps.event.clearInstanceListeners(circle);
      circle.setMap(null);
      delete this.instances[circleId];
    },

setOptions: function (circleId, options) {
      if (!window.gmlib.map.instance) { return; }
      options = options || {};
      const circle = this.ensureInstance(circleId, options);
      const hasCenter = options.center && options.center.lat != null && options.center.lng != null;
      if (hasCenter) {
        circle.setCenter(options.center);
      }
      if (typeof options.radius === "number") {
        circle.setRadius(options.radius);
      }
      circle.setOptions({
        clickable: options.clickable !== false,
        draggable: options.draggable === true,
        editable: options.editable === true,
        fillColor: options.fillColor || "#FF0000",
        fillOpacity: typeof options.fillOpacity === "number" ? options.fillOpacity : 0.35,
        strokeColor: options.strokeColor || "#FF0000",
        strokeOpacity: typeof options.strokeOpacity === "number" ? options.strokeOpacity : 1,
        strokeWeight: typeof options.strokeWeight === "number" ? options.strokeWeight : 2,
        visible: options.visible !== false,
        zIndex: typeof options.zIndex === "number" ? options.zIndex : 0
      });
      circle.setMap(options.visible === false
        ? null
        : window.gmlib.map.instance);
      console.log("gmlib.circle.afterSetOptions", circleId, {
        map: !!circle.getMap(),
        center: this.extractCenter(circle),
        radius: circle.getRadius()
      });
    }
  };

  window.gmlib.groundOverlay = {
    instances: {},

    extractLatLng: function (latLng) {
      if (!latLng) { return null; }
      if (typeof latLng.lat === "function" && typeof latLng.lng === "function") {
        return { lat: latLng.lat(), lng: latLng.lng() };
      }
      if (typeof latLng.lat === "number" && typeof latLng.lng === "number") {
        return { lat: latLng.lat, lng: latLng.lng };
      }
      return null;
    },

    remove: function (groundOverlayId) {
      const overlay = this.instances[groundOverlayId];
      if (!overlay) { return; }
      google.maps.event.clearInstanceListeners(overlay);
      overlay.setMap(null);
      delete this.instances[groundOverlayId];
    },

    setOptions: function (groundOverlayId, options) {
      if (!window.gmlib.map.instance) { return; }
      options = options || {};
      const hasBounds = options.bounds &&
        options.bounds.north != null &&
        options.bounds.south != null &&
        options.bounds.east != null &&
        options.bounds.west != null;
      if (!options.url || !hasBounds) {
        this.remove(groundOverlayId);
        return;
      }

      this.remove(groundOverlayId);

      const overlay = new google.maps.GroundOverlay(options.url, options.bounds, {
        clickable: options.clickable !== false,
        opacity: typeof options.opacity === "number" ? options.opacity : 1
      });

      overlay.addListener("click", (event) => {
        const latLng = event && event.latLng ? this.extractLatLng(event.latLng) : null;
        if (latLng) {
          sendMessage("groundoverlay.click", groundOverlayId, latLng);
        } else {
          sendMessage("groundoverlay.click", groundOverlayId, "");
        }
      });

      overlay.addListener("dblclick", (event) => {
        const latLng = event && event.latLng ? this.extractLatLng(event.latLng) : null;
        if (latLng) {
          sendMessage("groundoverlay.dblclick", groundOverlayId, latLng);
        } else {
          sendMessage("groundoverlay.dblclick", groundOverlayId, "");
        }
      });

      overlay.setMap(options.visible === false ? null : window.gmlib.map.instance);
      this.instances[groundOverlayId] = overlay;
    }
  };

  window.gmlib.layers = {
    traffic: null,
    transit: null,
    bicycling: null,
    kml: null,

    removeTraffic: function () {
      if (!this.traffic) { return; }
      if (typeof this.traffic.setMap === "function") {
        this.traffic.setMap(null);
      }
      this.traffic = null;
    },

    removeTransit: function () {
      if (!this.transit) { return; }
      if (typeof this.transit.setMap === "function") {
        this.transit.setMap(null);
      }
      this.transit = null;
    },

    removeBicycling: function () {
      if (!this.bicycling) { return; }
      if (typeof this.bicycling.setMap === "function") {
        this.bicycling.setMap(null);
      }
      this.bicycling = null;
    },

    removeKml: function () {
      if (!this.kml) { return; }
      google.maps.event.clearInstanceListeners(this.kml);
      if (typeof this.kml.setMap === "function") {
        this.kml.setMap(null);
      }
      this.kml = null;
    },

    setTraffic: function (options) {
      if (!window.gmlib.map.instance) { return; }
      options = options || {};
      if (options.visible === false) {
        this.removeTraffic();
        return;
      }
      if (!this.traffic) {
        this.traffic = new google.maps.TrafficLayer();
      }
      if (typeof this.traffic.setOptions === "function") {
        this.traffic.setOptions({
          autoRefresh: options.autoRefresh === true
        });
      }
      this.traffic.setMap(window.gmlib.map.instance);
    },

    setTransit: function (options) {
      if (!window.gmlib.map.instance) { return; }
      options = options || {};
      if (options.visible === false) {
        this.removeTransit();
        return;
      }
      if (!this.transit) {
        this.transit = new google.maps.TransitLayer();
      }
      this.transit.setMap(window.gmlib.map.instance);
    },

    setBicycling: function (options) {
      if (!window.gmlib.map.instance) { return; }
      options = options || {};
      if (options.visible === false) {
        this.removeBicycling();
        return;
      }
      if (!this.bicycling) {
        this.bicycling = new google.maps.BicyclingLayer();
      }
      this.bicycling.setMap(window.gmlib.map.instance);
    },

    setKml: function (options) {
      if (!window.gmlib.map.instance) { return; }
      options = options || {};
      if (options.visible === false || !options.url) {
        this.removeKml();
        return;
      }

      this.removeKml();

      const layer = new google.maps.KmlLayer({
        clickable: options.clickable !== false,
        preserveViewport: options.preserveViewport === true,
        screenOverlays: options.screenOverlays !== false,
        suppressInfoWindows: options.suppressInfoWindows === true,
        url: options.url,
        zIndex: typeof options.zIndex === "number" ? options.zIndex : 0
      });

      layer.addListener("click", (event) => {
        const latLng = event && event.latLng ? (window.gmlib.groundOverlay ? window.gmlib.groundOverlay.extractLatLng(event.latLng) : null) : null;
        sendMessage("kml.click", window.gmlib.map.mapId || "", latLng || "");
      });

      layer.addListener("status_changed", () => {
        sendMessage("kml.status_changed", window.gmlib.map.mapId || "", String(layer.getStatus ? layer.getStatus() : ""));
      });

      layer.addListener("defaultviewport_changed", () => {
        sendMessage("kml.defaultviewport_changed", window.gmlib.map.mapId || "", "");
      });

      layer.setMap(window.gmlib.map.instance);
      this.kml = layer;
    },

    remove: function () {
      this.removeTraffic();
      this.removeTransit();
      this.removeBicycling();
      this.removeKml();
    }
  };

  window.gmlib.geocode = {
    geocoder: null,
    geocoderPromise: null,

    ensureGeocoder: function () {
      if (this.geocoder) {
        return Promise.resolve(this.geocoder);
      }

      if (this.geocoderPromise) {
        return this.geocoderPromise;
      }

      this.geocoderPromise = getLib("geocoding")
        .then((library) => {
          const Geocoder = library && library.Geocoder ? library.Geocoder : google.maps.Geocoder;
          this.geocoder = new Geocoder();
          return this.geocoder;
        });
      if (this.geocoderPromise && typeof this.geocoderPromise.catch === "function") {
        this.geocoderPromise = this.geocoderPromise.catch((error) => {
          this.geocoderPromise = null;
          throw error;
        });
      }

      return this.geocoderPromise;
    },

    normalizeLocation: function (location) {
      if (!location) { return null; }
      if (typeof location.lat === "function" && typeof location.lng === "function") {
        return { lat: location.lat(), lng: location.lng() };
      }
      if (typeof location.lat === "number" && typeof location.lng === "number") {
        return { lat: location.lat, lng: location.lng };
      }
      return null;
    },

    normalizeResult: function (result) {
      const geometry = result && result.geometry ? result.geometry : null;
      return {
        formattedAddress: result.formatted_address || result.formattedAddress || "",
        placeId: result.place_id || result.placeId || "",
        locationType: geometry && geometry.location_type ? String(geometry.location_type) : "",
        location: geometry ? this.normalizeLocation(geometry.location) : null,
        types: Array.isArray(result.types) ? result.types.slice() : [],
        partialMatch: result.partial_match === true || result.partialMatch === true
      };
    },

    geocodeAddress: function (mapId, requestId, request) {
      if (!window.gmlib.map.instance) { return; }
      this.ensureGeocoder()
        .then((geocoder) => geocoder.geocode(request))
        .then((response) => {
          const payload = {
            requestId: requestId,
            status: response && response.status ? String(response.status) : "OK",
            errorMessage: "",
            results: (response && response.results ? response.results : []).map((item) => this.normalizeResult(item))
          };
          sendMessage("geocode.result", mapId, payload);
        })
        .catch((error) => {
          sendMessage("geocode.error", mapId, {
            requestId: requestId,
            status: error && error.code ? String(error.code) : "ERROR",
            errorMessage: error && error.message ? error.message : String(error),
            results: []
          });
        });
    },

    geocodePlaceId: function (mapId, requestId, request) {
      return this.geocodeAddress(mapId, requestId, request);
    },

    reverseGeocode: function (mapId, requestId, request) {
      return this.geocodeAddress(mapId, requestId, request);
    }
  };

  window.gmlib.elevation = {
    service: null,
    servicePromise: null,

    ensureService: function () {
      if (this.service) {
        return Promise.resolve(this.service);
      }

      if (this.servicePromise) {
        return this.servicePromise;
      }

      this.servicePromise = getLib("elevation")
        .then((library) => {
          const ElevationService = library && library.ElevationService ? library.ElevationService : google.maps.ElevationService;
          this.service = new ElevationService();
          return this.service;
        });
      if (this.servicePromise && typeof this.servicePromise.catch === "function") {
        this.servicePromise = this.servicePromise.catch((error) => {
          this.servicePromise = null;
          throw error;
        });
      }

      return this.servicePromise;
    },

    normalizeLocation: function (location) {
      if (!location) { return null; }
      if (typeof location.lat === "function" && typeof location.lng === "function") {
        return { lat: location.lat(), lng: location.lng() };
      }
      if (typeof location.lat === "number" && typeof location.lng === "number") {
        return { lat: location.lat, lng: location.lng };
      }
      return null;
    },

    normalizeResult: function (result) {
      const location = result && result.location ? this.normalizeLocation(result.location) : null;
      return {
        latitude: location ? location.lat : Number(result && result.latitude ? result.latitude : 0),
        longitude: location ? location.lng : Number(result && result.longitude ? result.longitude : 0),
        elevation: result && result.elevation ? Number(result.elevation) : 0,
        resolution: result && result.resolution ? Number(result.resolution) : 0
      };
    },

    sendResult: function (mapId, requestId, response) {
      const payload = {
        requestId: requestId,
        status: response && response.status ? String(response.status) : "OK",
        errorMessage: "",
        results: (response && response.results ? response.results : []).map((item) => this.normalizeResult(item))
      };
      sendMessage("elevation.result", mapId, payload);
    },

    sendError: function (mapId, requestId, error) {
      sendMessage("elevation.error", mapId, {
        requestId: requestId,
        status: error && error.code ? String(error.code) : "ERROR",
        errorMessage: error && error.message ? error.message : String(error),
        results: []
      });
    },

    getElevationsAlongPath: function (mapId, requestId, request) {
      if (!window.gmlib.map.instance) { return; }
      this.ensureService()
        .then((service) => service.getElevationAlongPath(request))
        .then((response) => {
          this.sendResult(mapId, requestId, response);
        })
        .catch((error) => {
          this.sendError(mapId, requestId, error);
        });
    },

    getElevationsForLocations: function (mapId, requestId, request) {
      if (!window.gmlib.map.instance) { return; }
      this.ensureService()
        .then((service) => service.getElevationForLocations(request))
        .then((response) => {
          this.sendResult(mapId, requestId, response);
        })
        .catch((error) => {
          this.sendError(mapId, requestId, error);
        });
    }
  };

  window.gmlib.routes = {
    routeClassPromise: null,

    ensureRouteClass: function () {
      if (this.routeClassPromise) {
        return this.routeClassPromise;
      }

      this.routeClassPromise = getLib("routes")
        .then((library) => {
          const RouteClass = library && library.Route
            ? library.Route
            : (google.maps.routes && google.maps.routes.Route ? google.maps.routes.Route : null);
          if (!RouteClass || typeof RouteClass.computeRoutes !== "function") {
            throw new Error("Routes library is not available.");
          }
          return RouteClass;
        });
      if (this.routeClassPromise && typeof this.routeClassPromise.catch === "function") {
        this.routeClassPromise = this.routeClassPromise.catch((error) => {
          this.routeClassPromise = null;
          throw error;
        });
      }

      return this.routeClassPromise;
    },

    normalizeRoute: function (route) {
      if (!route) {
        return {};
      }
      if (typeof route.toJSON === "function") {
        return route.toJSON();
      }
      return route;
    },

    sendResult: function (mapId, requestId, response) {
      const routes = response && response.routes ? response.routes : [];
      sendMessage("routes.result", mapId, {
        requestId: requestId,
        status: "OK",
        errorMessage: "",
        results: routes.map((item) => this.normalizeRoute(item))
      });
    },

    sendError: function (mapId, requestId, error) {
      sendMessage("routes.error", mapId, {
        requestId: requestId,
        status: error && error.code ? String(error.code) : "ERROR",
        errorMessage: error && error.message ? error.message : String(error),
        results: []
      });
    },

    compute: function (mapId, requestId, request) {
      this.ensureRouteClass()
        .then((RouteClass) => RouteClass.computeRoutes(request))
        .then((response) => {
          this.sendResult(mapId, requestId, response);
        })
        .catch((error) => {
          this.sendError(mapId, requestId, error);
        });
    }
  };

  window.gmlib.map = {
    instance: null,
    boundsChangeTimer: null,
    mapId: "map_1",
    centerChangeTimer: null,
    lastBoundsSignature: "",
    lastCenterSignature: "",
    lastMapTypeIdValue: "",
    lastHeadingValue: null,
    lastRenderingTypeValue: "",
    lastTiltValue: null,
    lastZoomValue: null,
    pendingCommands: [],

    executeQueuedCommands: function () {
      if (!this.instance || this.pendingCommands.length === 0) {
        return;
      }

      while (this.pendingCommands.length > 0) {
        const queuedCommand = this.pendingCommands.shift();
        try {
          // Commands arrive as JS snippets produced by Delphi.
          // Execute them only after the map instance exists.
          (new Function(queuedCommand))();
        } catch (error) {
          console.error("gmlib.map.executeQueuedCommands failed", error, queuedCommand);
        }
      }
    },

    receiveCommand: function (command) {
      if (!command) { return; }

      if (!this.instance) {
        this.pendingCommands.push(command);
        return;
      }

      try {
        (new Function(command))();
      } catch (error) {
        console.error("gmlib.map.receiveCommand failed", error, command);
      }
    },

    notifyReady: function () {
      sendMessage("map.ready", this.mapId, "");
    },

    notifyCenterChanged: function () {
      if (!this.instance) { return; }
      const center = this.instance.getCenter();
      if (!center) { return; }
      const lat = Number(center.lat().toFixed(6));
      const lng = Number(center.lng().toFixed(6));
      const signature = lat.toFixed(6) + "," + lng.toFixed(6);
      if (signature === this.lastCenterSignature) { return; }
      this.lastCenterSignature = signature;
      sendMessage("map.center_changed", this.mapId, { lat: lat, lng: lng });
    },

    notifyBoundsChanged: function () {
      if (!this.instance) { return; }
      const bounds = this.instance.getBounds();
      if (!bounds) { return; }
      const northEast = bounds.getNorthEast();
      const southWest = bounds.getSouthWest();
      if (!northEast || !southWest) { return; }
      const north = Number(northEast.lat().toFixed(6));
      const east = Number(northEast.lng().toFixed(6));
      const south = Number(southWest.lat().toFixed(6));
      const west = Number(southWest.lng().toFixed(6));
      const signature = north.toFixed(6) + "," + south.toFixed(6) + "," + east.toFixed(6) + "," + west.toFixed(6);
      if (signature === this.lastBoundsSignature) { return; }
      this.lastBoundsSignature = signature;
      sendMessage("map.bounds_changed", this.mapId, {
        north: north,
        south: south,
        east: east,
        west: west
      });
    },

    notifyZoomChanged: function () {
      if (!this.instance) { return; }
      const zoom = this.instance.getZoom();
      if (zoom === this.lastZoomValue) { return; }
      this.lastZoomValue = zoom;
      sendMessage("map.zoom_changed", this.mapId, String(zoom));
    },

    notifyMapTypeIdChanged: function () {
      if (!this.instance) { return; }
      const mapTypeId = this.instance.getMapTypeId() || "roadmap";
      if (mapTypeId === this.lastMapTypeIdValue) { return; }
      this.lastMapTypeIdValue = mapTypeId;
      sendMessage("map.maptypeid_changed", this.mapId, mapTypeId);
    },

    notifyHeadingChanged: function () {
      if (!this.instance) { return; }
      const heading = this.instance.getHeading();
      const normalizedHeading = heading == null ? 0 : Number(heading);
      if (normalizedHeading === this.lastHeadingValue) { return; }
      this.lastHeadingValue = normalizedHeading;
      sendMessage("map.heading_changed", this.mapId, String(normalizedHeading));
    },

    notifyTiltChanged: function () {
      if (!this.instance) { return; }
      const tilt = this.instance.getTilt();
      const normalizedTilt = tilt == null ? 0 : Number(tilt);
      if (normalizedTilt === this.lastTiltValue) { return; }
      this.lastTiltValue = normalizedTilt;
      sendMessage("map.tilt_changed", this.mapId, String(normalizedTilt));
    },

    notifyRenderingTypeChanged: function () {
      if (!this.instance || typeof this.instance.getRenderingType !== "function") { return; }
      const renderingType = this.instance.getRenderingType();
      const normalizedRenderingType = renderingType ? String(renderingType).toLowerCase() : "";
      if (!normalizedRenderingType || normalizedRenderingType === this.lastRenderingTypeValue) { return; }
      this.lastRenderingTypeValue = normalizedRenderingType;
      sendMessage("map.renderingtype_changed", this.mapId, normalizedRenderingType);
    },

    buildMousePayload: function (event) {
      if (!event || !event.latLng) { return null; }
      return {
        lat: event.latLng.lat(),
        lng: event.latLng.lng(),
        placeId: event.placeId || ""
      };
    },

    scheduleCenterChanged: function () {
      if (this.centerChangeTimer) {
        clearTimeout(this.centerChangeTimer);
      }
      this.centerChangeTimer = window.setTimeout(() => {
        this.centerChangeTimer = null;
        this.notifyCenterChanged();
      }, 150);
    },

    scheduleBoundsChanged: function () {
      if (this.boundsChangeTimer) {
        clearTimeout(this.boundsChangeTimer);
      }
      this.boundsChangeTimer = window.setTimeout(() => {
        this.boundsChangeTimer = null;
        this.notifyBoundsChanged();
      }, 150);
    },

    setCenter: function (lat, lng) {
      if (this.instance) { this.instance.setCenter({ lat: lat, lng: lng }); }
    },

    fitBounds: function (north, south, east, west) {
      if (!this.instance) { return; }
      this.instance.fitBounds({
        north: north,
        south: south,
        east: east,
        west: west
      });
    },

    setZoom: function (zoom) {
      if (this.instance) { this.instance.setZoom(zoom); }
    },

    setMapTypeId: function (mapTypeId) {
      if (this.instance) { this.instance.setMapTypeId(mapTypeId); }
    },

    setOptions: function (options) {
      if (this.instance) { this.instance.setOptions(options); }
    },

    initialize: async function (config) {
      const mapElement = document.getElementById("gmlib-map");
      const mapLibrary = await getLib("maps");
      window.gmlib.marker.library = await getLib("marker");
      this.mapId = config.mapId || "map_1";
      this.instance = new mapLibrary.Map(mapElement, config.options || {});
      this.instance.setOptions(config.options || {});

      this.lastCenterSignature = "";
      this.lastBoundsSignature = "";
      this.lastMapTypeIdValue = "";
      this.lastHeadingValue = null;
      this.lastRenderingTypeValue = "";
      this.lastTiltValue = null;
      this.lastZoomValue = null;

      this.instance.addListener("zoom_changed", () => {
        this.notifyZoomChanged();
      });

      this.instance.addListener("center_changed", () => {
        this.scheduleCenterChanged();
      });

      this.instance.addListener("bounds_changed", () => {
        this.scheduleBoundsChanged();
      });

      this.instance.addListener("maptypeid_changed", () => {
        this.notifyMapTypeIdChanged();
      });

      this.instance.addListener("heading_changed", () => {
        this.notifyHeadingChanged();
      });

      this.instance.addListener("tilt_changed", () => {
        this.notifyTiltChanged();
      });

      this.instance.addListener("renderingtype_changed", () => {
        this.notifyRenderingTypeChanged();
      });

      this.instance.addListener("projection_changed", () => {
        sendMessage("map.projection_changed", this.mapId, "");
      });

      this.instance.addListener("dragstart", () => {
        sendMessage("map.dragstart", this.mapId, "");
      });

      this.instance.addListener("drag", () => {
        sendMessage("map.drag", this.mapId, "");
      });

      this.instance.addListener("dragend", () => {
        sendMessage("map.dragend", this.mapId, "");
      });

      this.instance.addListener("idle", () => {
        sendMessage("map.idle", this.mapId, "");
this.notifyReady();
      });

      this.instance.addListener("tilesloaded", () => {
        sendMessage("map.tilesloaded", this.mapId, "");
      });

      this.instance.addListener("click", (event) => {
        const payload = this.buildMousePayload(event);
        if (payload) {
          sendMessage("map.click", this.mapId, payload);
        }
      });

      this.instance.addListener("contextmenu", (event) => {
        const payload = this.buildMousePayload(event);
        if (payload) {
          sendMessage("map.contextmenu", this.mapId, payload);
        }
      });

      this.instance.addListener("dblclick", (event) => {
        sendMessage("map.dblclick", this.mapId, { lat: event.latLng.lat(), lng: event.latLng.lng() });
      });

      this.instance.addListener("mousemove", (event) => {
        sendMessage("map.mousemove", this.mapId, { lat: event.latLng.lat(), lng: event.latLng.lng() });
      });

      this.instance.addListener("mouseover", (event) => {
        if (event && event.latLng) {
          sendMessage("map.mouseover", this.mapId, { lat: event.latLng.lat(), lng: event.latLng.lng() });
        }
      });

      this.instance.addListener("mouseout", (event) => {
        if (event && event.latLng) {
          sendMessage("map.mouseout", this.mapId, { lat: event.latLng.lat(), lng: event.latLng.lng() });
        }
      });

      this.notifyReady();
      this.notifyBoundsChanged();
      this.notifyCenterChanged();
      this.notifyMapTypeIdChanged();
      this.notifyHeadingChanged();
      this.notifyRenderingTypeChanged();
      this.notifyTiltChanged();
      this.notifyZoomChanged();
      window.setTimeout(() => { this.notifyReady(); }, 100);
      window.setTimeout(() => {
        this.notifyBoundsChanged();
        this.notifyCenterChanged();
        this.notifyMapTypeIdChanged();
        this.notifyHeadingChanged();
        this.notifyRenderingTypeChanged();
        this.notifyTiltChanged();
        this.notifyZoomChanged();
      }, 200);

      this.executeQueuedCommands();
    }
  };

  window.gmlib.receiveCommand = function (command) {
    window.gmlib.map.receiveCommand(command);
  };
}());
