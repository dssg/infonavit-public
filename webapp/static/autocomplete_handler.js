var suggested_colonia_names = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace,
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  remote: {
    url: '/colonias/%QUERY',
    wildcard: '%QUERY',
    filter: function (response) {return response.colonias;}
  }
});

$('#remote .typeahead').typeahead(null, {
  name: 'colonia-names',
  //display: customfun,
  source: suggested_colonia_names
});