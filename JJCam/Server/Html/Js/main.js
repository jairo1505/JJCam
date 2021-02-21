const urlServer = window.location.origin;

function getData() {
    $.ajax({
        type: "POST",
        url: urlServer+"/api/getDevice",
        crossDomain: true,
        success: function (data) {
            json = JSON.parse(data)
            if(json.status == 200 && json.action == "edit") {
                $('#titlePage').html("Editar " + json.name);
                $('#deviceProtocol').val(json.deviceProtocol)
                $('#deviceName').val(json.name)
                $('#deviceIP').val(json.ip)
                $('#devicePort').val(json.port)
                $('#deviceUser').val(json.user)
                $('#channels').val(json.channels)
            }
        },
        error: function (error) {
            $('#bodyCustom').html("<br/><br/><h5 align='center' style='color: white;'>😕<br/>Ops, tivemos um problema!</h5>");
        }
    });
}

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
            url: urlServer+"/api/saveDevice",
            crossDomain: true,
                dataType: "JSON",
            data: JSON.stringify(device),
            success: function (data) {
                if(data.status == 200) {
                    $('#bodyCustom').html("<br/><br/><img src='img/successCircle.svg'/><br/><h5 align='center' style='color: white;'>Dispositivo salvo com sucesso!</h5>");
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

getData();
