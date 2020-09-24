import $ from 'jquery';

$(function(){
    // always pass csrf tokens on ajax calls
    $.ajaxSetup({
        headers: { 'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content') }
    });
});

$(document).ready(function() {

    $("input[value='LookUpDOI']").on(
        'click',
        function() {
            let divs = $("input#experiment_publication_doi");
            let vars = divs.serialize() + '&experiment_id=' + $('#experiment_id').val();
            $.get("doi_lookup",vars, null, "script");
            return false;
        }
    );

    $("input[value='AddContributor']").on(
        'click',
        function() {
            let divs = $("input[name^='contributor']");
            let lastname = $('#contributor_last_name');
            let givens = $('#contributor_given_names');
            if (lastname.val().length > 0 && givens.val().length > 0){
                $.post("contributors", divs.serialize(), null, "script");
            } else {
                alert("Both Last and Given names must be completed");
            }
            return false;
        }
    );

});