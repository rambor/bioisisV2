import "jquery.ui.widget/jquery.ui.widget";
require ('blueimp-file-upload/js/jquery.fileupload.js');
require ('blueimp-tmpl/js/tmpl.js');

$(document).ready(function () {

    $('#archive_zip_file').fileupload({
        dataType: 'script',
        add: function(e,data){
            let strLength = $("#archive_description").val().length;
            let types = /(\.|\/)(zip|gzip)$/i;
            let file = data.files[0];
            if (strLength > 49 && (types.test(file.type) || types.test(file.name))) {
                //data.context = $(tmpl("template-upload", file));
                $('.upload').empty();
                $('<h2 class="fileStatus" id="fileStatus">Uploading</h2>').appendTo( "div.upload" );
                data.context = $('<p class="file">')
                    .append($('<a id="uploading" target="_blank">').text(data.files[0].name))
                    .appendTo('.upload');
                //$('#archive_zip_file').append(data.context);
                data.submit();
            } else if (strLength < 50) {
                alert("Please provide suitable description before uploading file.");
            } else {
                alert("#{data.files[0].name} is not a compress file");
            }
        },

        progress: function(e, data) {
            let progress = parseInt((data.loaded / data.total) * 100, 10);
            data.context.css("background-position-x", 100 - progress + "%");
        },

        done: function(e, data) {
            $('h2#fileStatus').text( "Finished Uploading" );
            $('a#back_or_update').text("Back");
            $('#archive_description').val("");
            $('#charcount').text(0);
            data.context.addClass("done").find("a").prop("href", "");
        }

    });

    $("#archive_description").keyup(function() {
        let length = $(this).val().length;
        let vars = $('#charcount');
        vars.text(length);
        if (length < 50){
            vars.css("color", "red");
        } else {
            vars.css("color", "white");
        }
    });
});