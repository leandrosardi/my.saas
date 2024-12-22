$(document).ready(function() {
    /*
     * Manage for when user choose a template.
     *
     */
    $('.reference-funnel').click(function() {
      $('.reference-funnel').removeClass('selected');
      $(this).addClass('selected');

      let rf = $(this).data('id');
      $('#rf').val(rf);
    });
});
