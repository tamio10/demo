require 'json'

def lines
  s = ''
  s += <<-EOS
  map.addLayer({
    'id': 'AP030-lines',
    'type': 'line',
    'source': 'globalmaps-vt',
    'source-layer': 'AP030',
    'layout': {
      'line-join': 'round',
      'line-cap': 'round'
    },
    'paint': {
      'line-color': randomColor(),
      'line-width': 1
    }
  });
  EOS
  s
end

def mapboxgl(country, version)
  dst_path = "mapboxgl/#{country}#{version}.html"
  metadata = JSON::parse(File.read("../gm#{country}#{version}vt/metadata.json"))
  center = metadata['center']
  tiles_path = "https://globalmaps-vt.github.io/gm#{country}#{version}vt" +
    "/{z}/{x}/{y}.mvt"
  File.open(dst_path, 'w') {|w|
    w.print <<-EOS
<!DOCTYPE html>
<html>
<head>
<meta charset='utf-8' />
<title></title>
<meta name='viewport' content='initial-scale=1,maximum-scale=1,user-scalable=no' />
<script src='https://api.tiles.mapbox.com/mapbox-gl-js/v0.26.0/mapbox-gl.js'></script>
<link href='https://api.tiles.mapbox.com/mapbox-gl-js/v0.26.0/mapbox-gl.css' rel='stylesheet' />
<link href='https://www.mapbox.com/base/latest/base.css' rel='stylesheet' />
<style>
body { margin:0; padding:0; }
#map { position:absolute; top:0; bottom:0; width:100%; }
</style>
</head>
<body>
<div id='map'></div>
<script>
mapboxgl.accessToken = 'pk.eyJ1IjoiaGZ1IiwiYSI6ImlRSGJVUTAifQ.rTx380smyvPc1gUfZv1cmw';
map = new mapboxgl.Map({
  container: 'map', style: 'mapbox://styles/mapbox/dark-v9',
  center: [#{center[0]},  #{center[1]}], zoom: #{center[2]}, hash: true, maxZoom: 10
});
colors = [
  'FC49A3', 'CC66FF', '66CCFF', '66FFCC',
  '00FF00', 'FFCC66', 'FF6666', 'FF0000',
  'FF8000', 'FFFF66', '00FFFF'
];
function randomColor() {
  return '#' + colors[parseInt(Math.random() * colors.length)];
}
map.on('load', function () {
  map.addSource('globalmaps-vt', {
    tiles: ['#{tiles_path}'],
    type: 'vector', maxzoom: 8
  });
#{lines}
});
</script>
</body>
</html>
    EOS
  }
end

def tangram(country, version)
end

Dir.glob('../*vt') {|path|
  next unless /^gm(.*?)(\d\d)vt$/.match File.basename(path)
  (country, version) = [$1, $2]
  mapboxgl(country, version)
  tangram(country, version)
}
