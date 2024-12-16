$(document).ready(function() {
    $('.reference-funnel').click(function() {
      $('.reference-funnel').removeClass('selected');
      $(this).addClass('selected');

      let rf = $(this).data('id');
      $('#rf').val(rf);
    });
});
