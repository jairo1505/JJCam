const urlServer = window.location.origin;

function addDevice() {
    if ($('#deviceName').val() != "" && $('#deviceIP').val() != ""
        && $('#devicePort').val() != "" && $('#deviceUser').val() != ""
        && $('#devicePassword').val() != "" && $('#channels').val() != "" && $('#verificationCode').val() != "") {
        
        var device = {
            deviceProtocol: $('#deviceProtocol').val().toString(),
            name: $('#deviceName').val().toString(),
            ip: $('#deviceIP').val().toString(),
            port: parseInt($('#devicePort').val()),
            user: $('#deviceUser').val().toString(),
            password: $('#devicePassword').val().toString(),
            channels: parseInt($('#channels').val()),
            code: parseInt($('#verificationCode').val())
        }
        
        $.ajax({
            type: "POST",
            url: urlServer+"/api/newDevice",
            crossDomain: true,
                dataType: "JSON",
            data: JSON.stringify(device),
            success: function (data) {
                if(data.status == 200) {
                    $('#bodyCustom').html("<br/><br/><img src='img/successCircle.svg'/><br/><h5 align='center' style='color: white;'>Dispositivo adicionado com sucesso!</h5>");
                }
            },
            error: function (error) {
                json = JSON.parse(error.responseText);
                $('#error').html(json.message);
            }
        });
    } else {
        $('#error').html("Preencha todos os campos!");
    }
}
