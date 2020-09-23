
$(document).ready(function() {

    $("[id^='hide_']").on(
        'click',
        function() {
            $('#view_archive').empty();
        }
    );

});