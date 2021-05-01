const urlServer = window.location.origin;
var token = "";

function init() {
    $('#authenticate').show();
    $('#titlePage').html("Autenticação");
}

function authenticate() {
    if ($('#verificationCode').val() != "") {
        var authenticate = {
            code: parseInt($('#verificationCode').val())
        }
        $.ajax({
            type: "POST",
            url: urlServer+"/api/authenticate",
            crossDomain: true,
            dataType: "JSON",
            data: JSON.stringify(authenticate),
            success: function (data) {
                if(data.status == 200) {
                    token = data.token;
                    $('#authenticate').hide();
                    $('#titlePage').html("Adicionar dispositivo");
                    $('#bodyCustom').show();
                    getData();
                }
            },
            error: function (error) {
                json = JSON.parse(error.responseText);
                $('#errorAuthenticate').html(json.message);
            }
        });
    } else {
        $('#errorAuthenticate').html("Preencha o campo!");
    }
}

function getData() {
    $.ajax({
        type: "POST",
        url: urlServer+"/api/getDevice",
        crossDomain: true,
        success: function (data) {
            json = JSON.parse(data)
            if(json.status == 200 && json.action == "edit") {
                $('#titlePage').html("Editar " + json.name);
                $('#deviceProtocol').val(json.deviceProtocol);
                $('#deviceName').val(json.name);
                $('#deviceIP').val(json.ip);
                $('#devicePort').val(json.port);
                $('#deviceUser').val(json.user);
                $('#devicePassword').val(json.password);
                $('#channels').val(json.channels);
                $('#channels').prop('disabled', true);
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
        && $('#devicePassword').val() != "" && $('#channels').val() != "") {
        
        var device = {
            deviceProtocol: $('#deviceProtocol').val().toString(),
            name: $('#deviceName').val().toString(),
            ip: $('#deviceIP').val().toString(),
            port: parseInt($('#devicePort').val()),
            user: $('#deviceUser').val().toString(),
            password: $('#devicePassword').val().toString(),
            channels: parseInt($('#channels').val()),
            token: token
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

init();
