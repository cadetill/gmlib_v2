(function () {
  if (window.osmlib) {
    return;
  }

  window.osmlib = {
    map: null,

    bootstrap: function (config) {
      var host = document.getElementById('osmlib-map');
      if (!host || typeof maplibregl === 'undefined') {
        return;
      }

      this.map = new maplibregl.Map({
        container: host,
        style: config.styleUrl,
        center: [0, 0],
        zoom: 1
      });
    }
  };
})();
