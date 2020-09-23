import $ from "jquery";
$(function(){
    // always pass csrf tokens on ajax calls
    $.ajaxSetup({
        headers: { 'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content') }
    });
});

$(document).ready(function() {

    $("input#bioisis_id").keyup(function() {
        let text = $(this).val();
        const regex = /[^A-Za-z0-9]|\s/;
        let bid_length = $(this).val().length;
        $('#messages').empty();

        if (regex.test(text)) {
            $('div.bid_search_result').empty().append('<span>Use letters and numbers only, no spaces '  + bid_length + '</span>');
            $(this).val("");
            return false;
        } else if (bid_length > 6) {
            $('div.bid_search_result').empty().append('<span>Too long, 6 characters please '+ bid_length+'</span>');
            return false;
        } else if (bid_length < 6) {
            $('div.bid_search_result').empty().append('<span>Too short, 6 characters please '+ bid_length+'</span>');
            return false;
        } else if (bid_length === 6) {
            $.post("bid_lookup", $("input#bioisis_id").serialize(), null, "script");
            return false;
        } else {
            $('div.bid_search_result').empty();
            return false;
        }
    });

    $("input#release_date").on("input", function(){
        let today = new Date();
        let release_it = new Date($(this).val());
        if (release_it < today){
            alert("Date must be after today");
            $(this).val(today.toString());
        }
    });

});