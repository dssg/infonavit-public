//callback handler for form submit
$("#prediction_form").submit(function(e)
{
    var postData = $(this).serializeArray();
    var formURL = $(this).attr("action");

    $.ajax(
    {
        url : formURL,
        type: "POST",
        data : postData,
        success:function(data, textStatus, jqXHR) 
        {
            //If no data was found for the selected coloniaid
            //show the alert and a message
            if (data.alert){
                $("#alert").css("display", "block")
                $("#alert-div-text").text(data.alert)
                $("#alert").effect("shake", {distance: 3})
            }else{
                $("#alert").css("display", "none")
                $("#alert-div-text").text("")

            }

            //Modify DOM elements acordingly
            $("#pred-bar").css("width", data.prediction)
            $("#prediction").text(data.prediction)
            $("#db_data").text(data.db_data)
            $("#subtitle").text(data.colonia_info)
            
            var table_body_html = '';
            $.each(data.top_factors, function (i, item) {
                table_body_html += '<tr><th scope="row">' + item[0] +
                         '</td><td>' + item[1] +
                         '</td></tr>';
            });

            $('#table_body').html(table_body_html).hide().fadeIn('slow');

            //Execute function to highlight and zoom in to colonia
            //Function declared on map_handler.js
            select_colonia(data.colonia_id)
        },
        error: function(jqXHR, textStatus, errorThrown) 
        {
            //if fails 
            console.log("An error ocurred: "+errorThrown)
        }
    });
    e.preventDefault(); //STOP default action
    e.unbind(); //unbind. to stop multiple form submit.
});
