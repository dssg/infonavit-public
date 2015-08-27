//Declare map and layer as global vars so they can be accessed
//in the select_colonia function
var map;
var layer;

//Main funciton, creates the map, adds the basemap
//and adds an empty sublayer
function main() {
  var mapOptions = {
    zoom: 10,
    center: [19.39, -99.14] //Mexico
  };
  map = new L.Map('map', mapOptions);

// Add a basemap to the map object just created
L.tileLayer('http://s.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png', {
  attribution: 'Stamen'
}).addTo(map);

cartodb.createLayer(map, {
  type: 'cartodb',
  user_name: 'edublancas',
  sublayers: [{
    //Dont include an SQL statement here, the map should be empty when
    //the user opens the webpage
    //sql: 'SELECT * FROM colonias WHERE objectid=12893',
    cartocss: '#colonias{polygon-fill: #5CA2D1;polygon-opacity: 0.7;line-color: #FFF;line-width: 0.5;line-opacity: 1;}'
  }]
})
.addTo(map)
.on('done', function(layer_) {
  layer = layer_
})

}

//Execute main function when window is loeaded
window.onload = main;


//Highlight and zoom in to colonia based on its objectid
function select_colonia(objectid){
  var query = "SELECT * FROM colonias WHERE objectid="+objectid;

  layer.getSubLayer(0).setSQL(query);

  var sql = new cartodb.SQL({ user: 'edublancas' });
  sql.getBounds(query).done(function(bounds) {
    map.fitBounds(bounds)
  });
}